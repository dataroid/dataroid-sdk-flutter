/*
 * 
 * dataroid_internal_logger.dart
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

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dataroid_sdk_platform_interface/dataroid_sdk_platform_interface.dart';
import 'package:dataroid_sdk_platform_interface/models/log_level.dart';

/// Internal logger for the Dataroid Flutter SDK.
/// 
/// This logger is for SDK internal use only and is NOT exposed to host applications.
/// It forwards logs to the native SDKs (Android/iOS) which handle the actual logging.
/// 
/// On web platforms, logs are printed to console since there's no native SDK.
class DataroidInternalLogger {
  static const String _source = "Flutter";
  static final DataroidSdkPlatform _platform = DataroidSdkPlatform.instance;

  /// Log a verbose message.
  /// 
  /// Use for detailed debug information that is typically not needed
  /// unless debugging a specific issue.
  static void verbose(String message) {
    _log(LogLevel.verbose, message);
  }

  /// Log a debug message.
  /// 
  /// Use for general debugging information during development.
  static void debug(String message) {
    _log(LogLevel.debug, message);
  }

  /// Log an info message.
  /// 
  /// Use for informational messages that highlight the progress
  /// of the SDK at a coarse-grained level.
  static void info(String message) {
    _log(LogLevel.info, message);
  }

  /// Log a warning message.
  /// 
  /// Use for potentially harmful situations or deprecated API usage.
  static void warning(String message) {
    _log(LogLevel.warning, message);
  }

  /// Log an error message.
  /// 
  /// Use for error events that might still allow the SDK to continue running.
  static void error(String message) {
    _log(LogLevel.error, message);
  }

  /// Internal method to handle logging across platforms
  static void _log(LogLevel level, String message) {
    if (kIsWeb) {
      // On web, just print to console with appropriate formatting
      final levelName = level.name.toUpperCase();
      print('[DATAROID/$levelName] $message');
    } else {
      // On mobile platforms, forward to native SDKs
      try {
        _platform.logExternal(level.value, _source, message);
      } catch (e) {
        // If logging fails, don't crash the SDK - just silently fail
        // We can't use print here as it would create infinite loop if print was being logged
      }
    }
  }
}

