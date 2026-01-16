/*
 * 
 * dataroid_plugin_config.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 27/11/2020.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';

/// [iOS] Goal configuration
class DataroidGoalConfig {
  /// [iOS] Application group identifier that is shared among app extensions.
  final String appGroupIdentifier;

  DataroidGoalConfig({
    required this.appGroupIdentifier,
  });

  Map<String, dynamic> get toJSON => {
        ArgumentName.appGroupIdentifier: appGroupIdentifier,
      };
}

class DataroidSnapshotConfig {
  /// Whether the recording is enabled or not.
  final bool recordingEnabled;

  /// The bundle identifiers (package names) that will use the feature.
  final List<String> enabledBundleIDs;

  DataroidSnapshotConfig({
    required this.recordingEnabled,
    required this.enabledBundleIDs,
  });

  Map<String, dynamic> get toJSON => {
        ArgumentName.recordingEnabled: recordingEnabled,
        ArgumentName.enabledBundleIDs: enabledBundleIDs,
      };
}

class DataroidInAppMessagingConfig {
  /// Whether the feature is enabled or not.
  final bool inAppMessagingEnabled;

  DataroidInAppMessagingConfig({
    required this.inAppMessagingEnabled,
  });

  Map<String, dynamic> get toJSON => {
        ArgumentName.inAppMessagingEnabled: inAppMessagingEnabled,
      };
}

class DataroidAPMConfig {
  /// Whether the feature is enabled or not.
  final bool recordCollectionEnabled;

  /// Whether auto-capture of APM events is enabled or not.
  final bool? apmAutoCaptureEnabled;

  /// Storage limit.
  final int? recordStorageLimit;
  
  DataroidAPMConfig({
    required this.recordCollectionEnabled,
    this.apmAutoCaptureEnabled,
    this.recordStorageLimit,
  });

  Map<String, dynamic> get toJSON => {
        ArgumentName.recordCollectionEnabled: recordCollectionEnabled,
        ArgumentName.apmAutoCaptureEnabled: apmAutoCaptureEnabled,
        ArgumentName.recordStorageLimit: recordStorageLimit,
      };
}

class DataroidScreenTrackingConfig {
  /// Whether the screen tracking is enabled or not.
  final bool enabled;

  DataroidScreenTrackingConfig({
    required this.enabled,
  });

  Map<String, dynamic> get toJSON => {
        ArgumentName.enabled: enabled,
      };
}

class LoggerConfig {
  /// Log level.
  final LogLevel level;

  /// Whether the logs should be saved to a file or not.
  final bool? writeToFile;
  LoggerConfig({
    required this.level,
    this.writeToFile,
  });

  Map<String, dynamic> get toJSON => {
        ArgumentName.level: level.index,
        ArgumentName.writeToFile: writeToFile,
      };
}

enum LogLevel { none, error, warning, info, debug, verbose }

class NotificationConfig {
  /// Small notification icon resource id.
  final int? smallNotificationIcon;

  /// Large notification icon resource id.
  final int? largeNotificationIcon;

  /// Default notification channel id.
  final String? defaultNotificationChannelId;

  /// Default notification channel name.
  final String? defaultNotificationChannelName;

  NotificationConfig({
    this.smallNotificationIcon,
    this.largeNotificationIcon,
    this.defaultNotificationChannelId,
    this.defaultNotificationChannelName,
  });

  Map<String, dynamic> get toJSON => {
        ArgumentName.smallNotificationIcon: smallNotificationIcon,
        ArgumentName.largeNotificationIcon: largeNotificationIcon,
        ArgumentName.defaultNotificationChannelId: defaultNotificationChannelId,
        ArgumentName.defaultNotificationChannelName: defaultNotificationChannelName,
      };
}
