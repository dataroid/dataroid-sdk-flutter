/*
 * 
 * log_level.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 15/12/2024.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

/// Log levels for internal SDK logging
/// Maps to native SDK log levels on Android and iOS
enum LogLevel {
  /// Verbose logging - most detailed
  /// Android: VERBOSE (2), iOS: verbose
  verbose(2),
  
  /// Debug logging
  /// Android: DEBUG (3), iOS: debug
  debug(3),
  
  /// Info logging
  /// Android: DEBUG (3), iOS: info
  info(4),
  
  /// Warning logging
  /// Android: WARN (5), iOS: warning
  warning(5),
  
  /// Error logging
  /// Android: ERROR (6), iOS: error
  error(6);

  /// The integer value for this log level
  /// Used when communicating with native platforms
  final int value;

  const LogLevel(this.value);

  /// Get the method name for iOS native calls
  String get iosMethodName {
    switch (this) {
      case LogLevel.verbose:
        return 'verbose';
      case LogLevel.debug:
        return 'debug';
      case LogLevel.info:
        return 'info';
      case LogLevel.warning:
        return 'warning';
      case LogLevel.error:
        return 'error';
    }
  }
}

