import 'package:flutter/widgets.dart';
import 'package:dataroid_plugin_flutter/dataroid_plugin_flutter.dart';
import 'package:dataroid_plugin_flutter/logger/dataroid_internal_logger.dart';

typedef ScreenNameExtractor = String? Function(RouteSettings settings);

String? _defaultScreenNameExtractor(RouteSettings settings) {
  return settings.name;
}

class DataroidNavigatorObserverConfig {
  final ScreenNameExtractor screenNameExtractor;
  final List<Pattern> ignoredRoutes;

  /// When `true`, route arguments (only `Map<String, dynamic>` payloads) are
  /// stringified and forwarded as screen attributes to the SDK.
  ///
  /// Route arguments often carry user IDs, session tokens, or other sensitive
  /// data. Only enable this if you control every navigator route in your app
  /// and have explicitly verified the arguments do not contain PII. Prefer
  /// passing pre-sanitized maps over raw user input.
  final bool trackRouteParams;

  const DataroidNavigatorObserverConfig({
    this.screenNameExtractor = _defaultScreenNameExtractor,
    this.ignoredRoutes = const [],
    this.trackRouteParams = false,
  });
}

class DataroidNavigatorObserver extends NavigatorObserver {
  final DataroidNavigatorObserverConfig _config;
  final DataroidPluginFlutter _sdk = DataroidPluginFlutter();
  String? _currentScreen;

  DataroidNavigatorObserver({DataroidNavigatorObserverConfig? config})
      : _config = config ?? const DataroidNavigatorObserverConfig();

  bool _isIgnored(String? name) {
    if (name == null) return true;
    for (final pattern in _config.ignoredRoutes) {
      if (pattern is RegExp && pattern.hasMatch(name)) return true;
      // Substring containment to match the semantics of
      // `DataroidDioInterceptorConfig.ignoredUrls` and
      // `DataroidNetworkTrackingConfig.ignoredUrls`. Use a `RegExp` pattern
      // for exact-match semantics (e.g. `RegExp(r'^/login$')`).
      if (pattern is String && name.contains(pattern)) return true;
    }
    return false;
  }

  String? _extractScreenName(Route<dynamic>? route) {
    if (route == null || route.settings.name == null) return null;
    return _config.screenNameExtractor(route.settings);
  }

  void _stopCurrentScreen() {
    if (_currentScreen != null) {
      _sdk.stopTracking(ScreenTracker(
        label: _currentScreen!,
        viewClass: _currentScreen!,
      ));
      DataroidInternalLogger.debug(
          'DataroidNavigatorObserver: viewStopped $_currentScreen');
    }
  }

  void _startScreen(String name, {Map<String, dynamic>? params}) {
    _currentScreen = name;
    _sdk.startTracking(ScreenTracker(
      label: name,
      viewClass: name,
      attributes: _config.trackRouteParams && params != null
          ? params.map((k, v) => MapEntry(k, v.toString()))
          : const {},
    ));
    DataroidInternalLogger.debug(
        'DataroidNavigatorObserver: viewStarted $name');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final screenName = _extractScreenName(route);
    if (screenName == null || _isIgnored(screenName)) return;

    _stopCurrentScreen();
    _startScreen(
      screenName,
      params: route.settings.arguments is Map<String, dynamic>
          ? route.settings.arguments as Map<String, dynamic>
          : null,
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _stopCurrentScreen();

    final screenName = _extractScreenName(previousRoute);
    if (screenName != null && !_isIgnored(screenName)) {
      _startScreen(screenName);
    } else {
      _currentScreen = null;
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _stopCurrentScreen();

    final screenName = _extractScreenName(newRoute);
    if (screenName != null && !_isIgnored(screenName)) {
      _startScreen(screenName);
    } else {
      _currentScreen = null;
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    final removedName = _extractScreenName(route);
    if (removedName == _currentScreen) {
      _stopCurrentScreen();
      final screenName = _extractScreenName(previousRoute);
      if (screenName != null && !_isIgnored(screenName)) {
        _startScreen(screenName);
      } else {
        _currentScreen = null;
      }
    }
  }

  String? get currentScreen => _currentScreen;
}
