import 'dart:io';

import 'package:dataroid_plugin_flutter/dataroid_plugin_flutter.dart';
import 'package:dataroid_plugin_flutter/logger/dataroid_internal_logger.dart';

/// Returns a privacy-safe message for a Dio error suitable for analytics.
///
/// `DioException.message` (and `DioException.error.toString()`) often carries
/// the remote IP and port when the underlying error is a `SocketException`,
/// `HandshakeException`, or `TlsException`. IP addresses are PII, so for
/// those cases we report only the wrapped exception's runtime type name.
///
/// For all other error types we fall back to a generic `'DioException'`
/// label rather than `error.message`. Application-layer messages (4xx/5xx
/// responses) frequently carry server-generated strings like
/// `"User john.doe@example.com not found"` that contain emails, user ids,
/// or tokens, so passing them through would bypass the redaction we apply
/// to every other identifier in the SDK.
String? _safeDioErrorMessage(dynamic error) {
  Object? inner;
  try {
    inner = error.error;
  } catch (_) {
    inner = null;
  }
  if (inner is SocketException ||
      inner is HandshakeException ||
      inner is TlsException ||
      inner is HttpException) {
    return inner.runtimeType.toString();
  }
  final raw = error.message?.toString() ?? '';
  if (raw.contains('SocketException') ||
      raw.contains('HandshakeException') ||
      raw.contains('TlsException') ||
      raw.contains('CERTIFICATE')) {
    return inner?.runtimeType.toString() ?? 'DioException';
  }
  return raw.isEmpty ? null : 'DioException';
}

typedef DioResponse = dynamic;
typedef DioRequestOptions = dynamic;
typedef DioError = dynamic;

class DataroidDioInterceptorConfig {
  final List<String> trackedDomains;
  final List<Pattern> ignoredUrls;
  final bool capturePayloadSize;

  const DataroidDioInterceptorConfig({
    this.trackedDomains = const [],
    this.ignoredUrls = const [],
    this.capturePayloadSize = true,
  });
}

class _PayloadSizes {
  final double? request;
  final double? response;
  const _PayloadSizes(this.request, this.response);
}

class DataroidDioInterceptor {
  static const _requestIdKey = '_dataroidRequestId';
  static const _maxTrackedRequests = 1000;

  final DataroidDioInterceptorConfig _config;
  final DataroidPluginFlutter _sdk = DataroidPluginFlutter();
  final Map<int, DateTime> _requestTimestamps = {};
  int _nextRequestId = 0;

  DataroidDioInterceptor({DataroidDioInterceptorConfig? config})
      : _config = config ?? const DataroidDioInterceptorConfig();

  bool _shouldTrack(String url) {
    final uri = Uri.tryParse(url);
    final host = uri?.host ?? url;
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

  HTTPMethod _parseMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HTTPMethod.GET;
      case 'POST':
        return HTTPMethod.POST;
      case 'PUT':
        return HTTPMethod.PUT;
      case 'DELETE':
        return HTTPMethod.DELETE;
      case 'PATCH':
        return HTTPMethod.PATCH;
      case 'HEAD':
        return HTTPMethod.HEAD;
      case 'OPTIONS':
        return HTTPMethod.OPTIONS;
      default:
        // HTTPMethod has no `unknown` variant, but silently misclassifying as
        // GET hides real misconfiguration. Log a warning so the analytics
        // mismatch is visible in app logs.
        DataroidInternalLogger.warning(
          'DataroidDioInterceptor: unrecognised HTTP method "$method", '
          'reporting as GET',
        );
        return HTTPMethod.GET;
    }
  }

  int? _assignRequestId(dynamic options) {
    final id = _nextRequestId++;
    try {
      final extra = options.extra;
      if (extra is Map) {
        extra[_requestIdKey] = id;
        return id;
      }
    } catch (_) {
      // Some test doubles or Dio-like objects may not expose an extra map.
    }
    return null;
  }

  int? _readRequestId(dynamic options) {
    try {
      final extra = options.extra;
      if (extra is Map) {
        final id = extra[_requestIdKey];
        if (id is int) {
          return id;
        }
      }
    } catch (_) {
      // Some test doubles or Dio-like objects may not expose an extra map.
    }
    return null;
  }

  int _elapsed(dynamic options) {
    final requestId = _readRequestId(options);
    if (requestId == null) {
      return 0;
    }
    final startTime = _requestTimestamps.remove(requestId);
    if (startTime == null) {
      return 0;
    }
    return DateTime.now().difference(startTime).inMilliseconds;
  }

  _PayloadSizes _calculatePayloadSizes(dynamic response) {
    if (!_config.capturePayloadSize) {
      return const _PayloadSizes(null, null);
    }

    double? requestSize;
    final requestData = response.requestOptions.data;
    if (requestData is String) {
      requestSize = requestData.length.toDouble();
    }

    double? responseSize;
    try {
      final responseHeaders = response.headers;
      if (responseHeaders != null) {
        final contentLength = responseHeaders.value('content-length');
        if (contentLength != null) {
          responseSize = double.tryParse(contentLength);
        }
      }
    } catch (_) {
      // Missing or malformed headers leave responseSize as null.
    }

    return _PayloadSizes(requestSize, responseSize);
  }

  static ErrorType _classifyErrorType(dynamic error) {
    final errorMessage = error.message?.toString() ?? '';
    final typeStr = error.type.toString();

    if (errorMessage.contains('SocketException') ||
        typeStr.contains('connectionError')) {
      return ErrorType.noConnection;
    }
    if (errorMessage.contains('HandshakeException') ||
        errorMessage.contains('CERTIFICATE')) {
      return ErrorType.ssl;
    }
    if (typeStr.contains('connectionTimeout') ||
        typeStr.contains('receiveTimeout') ||
        typeStr.contains('sendTimeout')) {
      return ErrorType.timeout;
    }
    if (typeStr.contains('cancel')) {
      return ErrorType.cancelled;
    }
    // String matching against `DioExceptionType.toString()` is fragile: a
    // future Dio enum rename would silently bucket every error as `unknown`.
    // Log so the regression is visible instead of degrading APM data
    // quality without warning. The proper fix is to import `package:dio`
    // and switch to typed enum checks (tracked as a follow-up).
    DataroidInternalLogger.warning(
      'DataroidDioInterceptor: unrecognised DioException type "$typeStr" '
      '(message="$errorMessage"); reporting as ErrorType.unknown',
    );
    return ErrorType.unknown;
  }

  void onRequest(dynamic options, dynamic handler) {
    try {
      final requestId = _assignRequestId(options);
      if (requestId != null) {
        _requestTimestamps[requestId] = DateTime.now();
        _evictOldRequestTimestamps();
      }
    } catch (e) {
      DataroidInternalLogger.error(
          'DataroidDioInterceptor.onRequest error: $e');
    }
    handler.next(options);
  }

  void _evictOldRequestTimestamps() {
    while (_requestTimestamps.length > _maxTrackedRequests) {
      _requestTimestamps.remove(_requestTimestamps.keys.first);
    }
  }

  /// Strips query parameters and fragments from a URL before it is shipped
  /// to the analytics backend. Query strings frequently carry session
  /// tokens, API keys, and user identifiers, so we record only the
  /// scheme/host/port/path component on `APMHTTPRecord` / `APMNetworkRecord`.
  /// `_shouldTrack` continues to match against the full URL so callers can
  /// still write `ignoredUrls` patterns that target query parameters.
  static String _redactedRecordUrl(Uri uri) {
    return Uri(
      scheme: uri.scheme.isEmpty ? null : uri.scheme,
      host: uri.host.isEmpty ? null : uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
    ).toString();
  }

  void onResponse(dynamic response, dynamic handler) {
    try {
      final uri = response.requestOptions.uri as Uri;
      final url = uri.toString();
      if (_shouldTrack(url)) {
        final duration = _elapsed(response.requestOptions);
        final statusCode = response.statusCode ?? 0;
        final success = statusCode >= 200 && statusCode < 400;
        final sizes = _calculatePayloadSizes(response);

        final record = APMHTTPRecord(
          url: _redactedRecordUrl(uri),
          method: _parseMethod(response.requestOptions.method),
          statusCode: statusCode,
          duration: duration,
          success: success,
          requestSize: sizes.request,
          responseSize: sizes.response,
          errorCode: success ? null : statusCode.toString(),
          resourceType: ResourceType.XHR,
        );

        _sdk.collectAPMHTTPRecord(record);
      }
    } catch (e) {
      DataroidInternalLogger.error(
          'DataroidDioInterceptor.onResponse error: $e');
    }
    handler.next(response);
  }

  void onError(dynamic error, dynamic handler) {
    try {
      final uri = error.requestOptions.uri as Uri;
      final url = uri.toString();
      if (_shouldTrack(url)) {
        final duration = _elapsed(error.requestOptions);
        final recordUrl = _redactedRecordUrl(uri);

        if (error.response != null) {
          _recordHttpError(error, recordUrl, duration);
        } else {
          _recordNetworkError(error, recordUrl, duration);
        }
      }
    } catch (e) {
      DataroidInternalLogger.error('DataroidDioInterceptor.onError error: $e');
    }
    handler.next(error);
  }

  void _recordHttpError(dynamic error, String url, int duration) {
    final statusCode = error.response!.statusCode ?? 0;
    final record = APMHTTPRecord(
      url: url,
      method: _parseMethod(error.requestOptions.method),
      statusCode: statusCode,
      duration: duration,
      success: false,
      errorType: error.type?.toString(),
      errorCode: statusCode.toString(),
      errorMessage: _safeDioErrorMessage(error),
      resourceType: ResourceType.XHR,
    );
    _sdk.collectAPMHTTPRecord(record);
  }

  void _recordNetworkError(dynamic error, String url, int duration) {
    final record = APMNetworkRecord(
      url: url,
      method: _parseMethod(error.requestOptions.method),
      duration: duration,
      exception: error.type?.toString() ?? 'DioException',
      type: _classifyErrorType(error),
      message: _safeDioErrorMessage(error) ?? '',
    );
    _sdk.collectAPMNetworkErrorRecord(record);
  }
}
