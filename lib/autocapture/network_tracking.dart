import 'dart:convert';
import 'dart:io';

import 'package:dataroid_plugin_flutter/dataroid_plugin_flutter.dart';
import 'package:dataroid_plugin_flutter/logger/dataroid_internal_logger.dart';

/// Returns a privacy-safe URL string for analytics payloads.
///
/// Query parameters and fragments routinely carry session tokens, API keys,
/// user identifiers, and other PII; including them verbatim in
/// `APMHTTPRecord.url` / `APMNetworkRecord.url` would forward that data to
/// the analytics backend. Only the scheme, host, port, and path are kept.
String _redactedRecordUrl(Uri uri) {
  return Uri(
    scheme: uri.scheme.isEmpty ? null : uri.scheme,
    host: uri.host.isEmpty ? null : uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  ).toString();
}

/// Returns a privacy-safe message for [error] suitable for analytics payloads.
///
/// `Object.toString()` on common network exceptions includes the remote IP,
/// host, and port (e.g. `SocketException: ..., address = 10.0.0.1, port = 8080`).
/// IP addresses are PII and must not be sent to the analytics backend, so for
/// network-related exception types we report only the runtime type name.
String _safeErrorMessage(Object error) {
  if (error is SocketException ||
      error is HandshakeException ||
      error is TlsException ||
      error is HttpException) {
    return error.runtimeType.toString();
  }
  return error.toString();
}

class DataroidNetworkTrackingConfig {
  final List<String> trackedDomains;
  final List<Pattern> ignoredUrls;
  final bool capturePayloadSize;

  const DataroidNetworkTrackingConfig({
    this.trackedDomains = const [],
    this.ignoredUrls = const [],
    this.capturePayloadSize = true,
  });
}

class DataroidHttpOverrides extends HttpOverrides {
  final HttpOverrides? _previous;
  final DataroidNetworkTrackingConfig _config;

  DataroidHttpOverrides({
    DataroidNetworkTrackingConfig? config,
  })  : _previous = HttpOverrides.current,
        _config = config ?? const DataroidNetworkTrackingConfig();

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = _previous != null
        ? _previous!.createHttpClient(context)
        : super.createHttpClient(context);
    return _DataroidTrackingHttpClient(client, _config);
  }
}

class _DataroidTrackingHttpClient implements HttpClient {
  final HttpClient _inner;
  final DataroidNetworkTrackingConfig _config;
  final DataroidPluginFlutter _sdk = DataroidPluginFlutter();

  _DataroidTrackingHttpClient(this._inner, this._config);

  bool _shouldTrack(Uri uri) {
    final url = uri.toString();
    final host = uri.host;
    for (final pattern in _config.ignoredUrls) {
      if (pattern is RegExp && pattern.hasMatch(url)) {
        return false;
      }
      if (pattern is String && url.contains(pattern)) {
        return false;
      }
    }
    if (_config.trackedDomains.isEmpty) {
      return true;
    }
    for (final domain in _config.trackedDomains) {
      if (host == domain || host.endsWith('.$domain')) {
        return true;
      }
    }
    return false;
  }

  /// Best-effort URI used **only before** `_inner.open(host, port, path)`
  /// returns: for `_shouldTrack` matching and for connection-error reports
  /// when the inner request never materialises. Successful requests rebuild
  /// the URI from `HttpClientRequest.uri` in `_wrapOpen`, so the scheme
  /// guess here does not surface in normal-path APM data.
  static Uri _uriForHostPath(String host, int port, String path) {
    return Uri(
      scheme: port == 443 ? 'https' : 'http',
      host: host,
      port: port,
      path: path,
    );
  }

  Future<HttpClientRequest> _wrapOpen(String method, Uri uri,
      Future<HttpClientRequest> Function() opener) async {
    if (!_shouldTrack(uri)) {
      return opener();
    }

    final startTime = DateTime.now();
    try {
      final request = await opener();
      // Prefer the URI Dart hands back on the actual `HttpClientRequest`,
      // because `_uriForHostPath` cannot infer the scheme from a bare
      // host+port (e.g. `client.get('staging', 8443, '/x')` would otherwise
      // be reported as `http://...`). The fallback `uri` only kicks in if
      // the inner client did not populate `request.uri`. Read once so we
      // do not perturb mocks that count getter accesses in tests.
      final innerUri = request.uri;
      final reportingUri =
          innerUri.hasScheme && innerUri.host.isNotEmpty ? innerUri : uri;
      // Pass `startTime` through so success-path durations include DNS/TCP
      // setup just like the error path does. Otherwise success durations are
      // measured from after `opener()` returns, making them systematically
      // shorter than error durations and skewing APM dashboards.
      return _DataroidTrackingRequest(
        request,
        method,
        reportingUri,
        _config,
        startTime: startTime,
      );
    } catch (error) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _reportConnectionError(method, uri, error, duration);
      rethrow;
    }
  }

  void _reportConnectionError(
      String method, Uri uri, Object error, int duration) {
    try {
      final methodEnum = HTTPMethod.values.firstWhere(
        (m) => m.name == method.toUpperCase(),
        orElse: () => HTTPMethod.GET,
      );

      ErrorType errorType = ErrorType.unknown;
      if (error is SocketException) {
        errorType = ErrorType.noConnection;
      } else if (error is HandshakeException || error is TlsException) {
        errorType = ErrorType.ssl;
      } else if (error.toString().contains('timeout')) {
        errorType = ErrorType.timeout;
      }

      final record = APMNetworkRecord(
        url: _redactedRecordUrl(uri),
        method: methodEnum,
        duration: duration,
        exception: error.runtimeType.toString(),
        type: errorType,
        message: _safeErrorMessage(error),
      );

      _sdk.collectAPMNetworkErrorRecord(record);
    } catch (e) {
      DataroidInternalLogger.error(
          'DataroidHttpOverrides: failed to report connection error: $e');
    }
  }

  @override
  Future<HttpClientRequest> open(
          String method, String host, int port, String path) =>
      _wrapOpen(method, _uriForHostPath(host, port, path),
          () => _inner.open(method, host, port, path));

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _wrapOpen(method, url, () => _inner.openUrl(method, url));

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      _wrapOpen('GET', _uriForHostPath(host, port, path),
          () => _inner.get(host, port, path));

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      _wrapOpen('GET', url, () => _inner.getUrl(url));

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      _wrapOpen('POST', _uriForHostPath(host, port, path),
          () => _inner.post(host, port, path));

  @override
  Future<HttpClientRequest> postUrl(Uri url) =>
      _wrapOpen('POST', url, () => _inner.postUrl(url));

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      _wrapOpen('PUT', _uriForHostPath(host, port, path),
          () => _inner.put(host, port, path));

  @override
  Future<HttpClientRequest> putUrl(Uri url) =>
      _wrapOpen('PUT', url, () => _inner.putUrl(url));

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _wrapOpen('DELETE', _uriForHostPath(host, port, path),
          () => _inner.delete(host, port, path));

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) =>
      _wrapOpen('DELETE', url, () => _inner.deleteUrl(url));

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _wrapOpen('PATCH', _uriForHostPath(host, port, path),
          () => _inner.patch(host, port, path));

  @override
  Future<HttpClientRequest> patchUrl(Uri url) =>
      _wrapOpen('PATCH', url, () => _inner.patchUrl(url));

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      _wrapOpen('HEAD', _uriForHostPath(host, port, path),
          () => _inner.head(host, port, path));

  @override
  Future<HttpClientRequest> headUrl(Uri url) =>
      _wrapOpen('HEAD', url, () => _inner.headUrl(url));

  @override
  set autoUncompress(bool value) => _inner.autoUncompress = value;
  @override
  bool get autoUncompress => _inner.autoUncompress;
  @override
  set connectionTimeout(Duration? value) => _inner.connectionTimeout = value;
  @override
  Duration? get connectionTimeout => _inner.connectionTimeout;
  @override
  set idleTimeout(Duration value) => _inner.idleTimeout = value;
  @override
  Duration get idleTimeout => _inner.idleTimeout;
  @override
  set maxConnectionsPerHost(int? value) => _inner.maxConnectionsPerHost = value;
  @override
  int? get maxConnectionsPerHost => _inner.maxConnectionsPerHost;
  @override
  set userAgent(String? value) => _inner.userAgent = value;
  @override
  String? get userAgent => _inner.userAgent;
  @override
  set authenticate(
          Future<bool> Function(Uri url, String scheme, String? realm)? f) =>
      _inner.authenticate = f;
  @override
  set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String? realm)?
              f) =>
      _inner.authenticateProxy = f;
  @override
  set badCertificateCallback(
          bool Function(X509Certificate cert, String host, int port)?
              callback) =>
      _inner.badCertificateCallback = callback;
  @override
  set connectionFactory(
          Future<ConnectionTask<Socket>> Function(
                  Uri url, String? proxyHost, int? proxyPort)?
              f) =>
      _inner.connectionFactory = f;
  @override
  set findProxy(String Function(Uri url)? f) => _inner.findProxy = f;
  @override
  set keyLog(Function(String line)? callback) => _inner.keyLog = callback;
  @override
  void addCredentials(
          Uri url, String realm, HttpClientCredentials credentials) =>
      _inner.addCredentials(url, realm, credentials);
  @override
  void addProxyCredentials(String host, int port, String realm,
          HttpClientCredentials credentials) =>
      _inner.addProxyCredentials(host, port, realm, credentials);
  @override
  void close({bool force = false}) => _inner.close(force: force);
}

class _DataroidTrackingRequest implements HttpClientRequest {
  final HttpClientRequest _inner;
  final String _method;
  final Uri _uri;
  final DataroidNetworkTrackingConfig _config;
  final DateTime _startTime;
  final DataroidPluginFlutter _sdk = DataroidPluginFlutter();
  int _requestSize = 0;

  _DataroidTrackingRequest(
    this._inner,
    this._method,
    this._uri,
    this._config, {
    DateTime? startTime,
  }) : _startTime = startTime ?? DateTime.now();

  @override
  Future<HttpClientResponse> close() async {
    // Duration must be captured AFTER the await: `_inner.close()` is the
    // call that actually flushes the request and waits for the response
    // headers, so the entire server round-trip happens here. Sampling
    // before the await measured only how long the caller spent writing
    // the body (microseconds for in-memory data) and made every APM
    // record's `duration` meaningless.
    try {
      final response = await _inner.close();
      final duration = DateTime.now().difference(_startTime).inMilliseconds;
      _reportSuccess(response, duration);
      return response;
    } catch (e) {
      final duration = DateTime.now().difference(_startTime).inMilliseconds;
      _reportError(e, duration);
      rethrow;
    }
  }

  void _reportSuccess(HttpClientResponse response, int duration) {
    try {
      final statusCode = response.statusCode;
      final success = statusCode >= 200 && statusCode < 400;
      final methodEnum = HTTPMethod.values.firstWhere(
        (m) => m.name == _method.toUpperCase(),
        orElse: () => HTTPMethod.GET,
      );

      final record = APMHTTPRecord(
        url: _redactedRecordUrl(_uri),
        method: methodEnum,
        statusCode: statusCode,
        duration: duration,
        success: success,
        requestSize:
            _config.capturePayloadSize ? _requestSize.toDouble() : null,
        responseSize: _config.capturePayloadSize && response.contentLength > 0
            ? response.contentLength.toDouble()
            : null,
        errorCode: success ? null : statusCode.toString(),
        errorMessage: success ? null : response.reasonPhrase,
        resourceType: ResourceType.XHR,
      );

      _sdk.collectAPMHTTPRecord(record);
    } catch (e) {
      DataroidInternalLogger.error(
          'DataroidHttpOverrides: failed to report HTTP success: $e');
    }
  }

  void _reportError(Object error, int duration) {
    try {
      final methodEnum = HTTPMethod.values.firstWhere(
        (m) => m.name == _method.toUpperCase(),
        orElse: () => HTTPMethod.GET,
      );

      ErrorType errorType = ErrorType.unknown;
      if (error is SocketException) {
        errorType = ErrorType.noConnection;
      } else if (error is HandshakeException || error is TlsException) {
        errorType = ErrorType.ssl;
      } else if (error.toString().contains('timeout')) {
        errorType = ErrorType.timeout;
      }

      final record = APMNetworkRecord(
        url: _redactedRecordUrl(_uri),
        method: methodEnum,
        duration: duration,
        exception: error.runtimeType.toString(),
        type: errorType,
        message: _safeErrorMessage(error),
      );

      _sdk.collectAPMNetworkErrorRecord(record);
    } catch (e) {
      DataroidInternalLogger.error(
          'DataroidHttpOverrides: failed to report network error: $e');
    }
  }

  @override
  void add(List<int> data) {
    _requestSize += data.length;
    _inner.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _inner.addError(error, stackTrace);
  @override
  Future addStream(Stream<List<int>> stream) {
    final counted = stream.map((chunk) {
      _requestSize += chunk.length;
      return chunk;
    });
    return _inner.addStream(counted);
  }

  @override
  void write(Object? object) {
    _requestSize += utf8.encode(object.toString()).length;
    _inner.write(object);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    _requestSize += utf8.encode(objects.join(separator)).length;
    _inner.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    _requestSize += utf8.encode(String.fromCharCode(charCode)).length;
    _inner.writeCharCode(charCode);
  }

  @override
  void writeln([Object? object = ""]) {
    _requestSize += utf8.encode('$object\n').length;
    _inner.writeln(object);
  }

  @override
  Future flush() => _inner.flush();

  // `IOSink.done` is a passive getter: returns a Future that completes when
  // the sink is closed. Anything that performs work here (e.g. calling
  // `close()`) would silently trigger a request dispatch when callers like
  // `dart:io` or Dio's adapter `await request.done` to wait for completion,
  // and would double-call `_inner.close()` when the caller later closes the
  // request explicitly. Tracking is wired up in our `close()` override
  // instead; this getter just delegates.
  @override
  Future<HttpClientResponse> get done => _inner.done;
  @override
  Encoding get encoding => _inner.encoding;
  @override
  set encoding(Encoding value) => _inner.encoding = value;
  @override
  bool get bufferOutput => _inner.bufferOutput;
  @override
  set bufferOutput(bool value) => _inner.bufferOutput = value;
  @override
  int get contentLength => _inner.contentLength;
  @override
  set contentLength(int value) => _inner.contentLength = value;
  @override
  bool get followRedirects => _inner.followRedirects;
  @override
  set followRedirects(bool value) => _inner.followRedirects = value;
  @override
  int get maxRedirects => _inner.maxRedirects;
  @override
  set maxRedirects(int value) => _inner.maxRedirects = value;
  @override
  bool get persistentConnection => _inner.persistentConnection;
  @override
  set persistentConnection(bool value) => _inner.persistentConnection = value;
  @override
  HttpHeaders get headers => _inner.headers;
  @override
  List<Cookie> get cookies => _inner.cookies;
  @override
  HttpConnectionInfo? get connectionInfo => _inner.connectionInfo;
  @override
  String get method => _inner.method;
  @override
  Uri get uri => _inner.uri;
  @override
  void abort([Object? exception, StackTrace? stackTrace]) =>
      _inner.abort(exception, stackTrace);
}

void enableDataroidNetworkTracking({DataroidNetworkTrackingConfig? config}) {
  // Unwrap any previous DataroidHttpOverrides first so re-entrant calls
  // (e.g. host app calling enable() in main() and again after sign-in, or
  // a hot-restart flow) cannot stack tracking layers and double-report
  // every request.
  disableDataroidNetworkTracking();
  HttpOverrides.global = DataroidHttpOverrides(config: config);
  DataroidInternalLogger.debug('DataroidNetworkTracking: enabled');
}

void disableDataroidNetworkTracking() {
  final current = HttpOverrides.current;
  if (current is DataroidHttpOverrides) {
    HttpOverrides.global = current._previous;
  }
  DataroidInternalLogger.debug('DataroidNetworkTracking: disabled');
}
