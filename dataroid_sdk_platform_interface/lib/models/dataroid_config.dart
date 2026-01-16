import 'package:json_annotation/json_annotation.dart';

part 'dataroid_config.g.dart'; // Generated file

/// Represents the session configuration
@JsonSerializable()
class DTRSessionConfig {
  final int? timeout;
  final bool? manualManagement;

  const DTRSessionConfig({
    this.timeout,
    this.manualManagement,
  });

  factory DTRSessionConfig.fromJson(Map<String, dynamic> json) => _$DTRSessionConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRSessionConfigToJson(this);

}

/// Represents the screen tracking configuration
@JsonSerializable()
class DTRScreenTrackingConfig {
  final bool? enabled;
  final bool? autoCollectingEnabled;
  final int? checkInterval;
  final bool? ignoreReferralQueryParams;
  final bool? ignoreQueryParams;
  final bool? shouldTrackInnerViewController;
  final List<String>? viewControllerExclusions;

  const DTRScreenTrackingConfig({
    this.enabled,
    this.autoCollectingEnabled,
    this.checkInterval,
    this.ignoreReferralQueryParams,
    this.ignoreQueryParams,
    this.shouldTrackInnerViewController,
    this.viewControllerExclusions,
  });

  factory DTRScreenTrackingConfig.fromJson(Map<String, dynamic> json) => _$DTRScreenTrackingConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRScreenTrackingConfigToJson(this);

}

/// Represents the component interaction configuration
@JsonSerializable()
class DTRComponentInteractionConfig {
  final bool? enabled;
  final int? debounceThreshold;
  final bool? autoCollectingEnabled;
  final List<String>? sensitiveViewLabelList;
  final List<String>? sensitiveComponentSelectorList;

  const DTRComponentInteractionConfig({
    this.enabled,
    this.debounceThreshold,
    this.autoCollectingEnabled,
    this.sensitiveViewLabelList,
    this.sensitiveComponentSelectorList,
  });

  factory DTRComponentInteractionConfig.fromJson(Map<String, dynamic> json) => _$DTRComponentInteractionConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRComponentInteractionConfigToJson(this);
}

/// Represents the screen interaction configuration
@JsonSerializable()
class DTRScreenInteractionConfig {
  final bool? enabled;
  final bool? autoCollectingEnabled;

  const DTRScreenInteractionConfig({
    this.enabled,
    this.autoCollectingEnabled,
  });

  factory DTRScreenInteractionConfig.fromJson(Map<String, dynamic> json) => _$DTRScreenInteractionConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRScreenInteractionConfigToJson(this);
}

/// Represents the APM (Application Performance Monitoring) configuration
@JsonSerializable()
class DTRApmConfig {
  final bool? enabled;
  final int? storageLimit;
  final bool? autoCollectingEnabled;
  final List<String>? excludedHosts;

  const DTRApmConfig({
    this.enabled,
    this.storageLimit,
    this.autoCollectingEnabled,
    this.excludedHosts,
  });

  factory DTRApmConfig.fromJson(Map<String, dynamic> json) => _$DTRApmConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRApmConfigToJson(this);
}

/// Represents the in-app configuration
@JsonSerializable()
class DTRInAppConfig {
  final bool? enabled;

  const DTRInAppConfig({
    this.enabled,
  });

  factory DTRInAppConfig.fromJson(Map<String, dynamic> json) => _$DTRInAppConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRInAppConfigToJson(this);
}

/// Represents the push configuration
@JsonSerializable()
class DTRPushConfig {
  final bool? enabled;
  final Map<String, dynamic>? firebaseOptions;

  const DTRPushConfig({
    this.enabled,
    this.firebaseOptions,
  });

  factory DTRPushConfig.fromJson(Map<String, dynamic> json) => _$DTRPushConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRPushConfigToJson(this);
}

/// Represents the app inbox configuration
@JsonSerializable()
class DTRAppInboxConfig {
  final bool? enabled;
  final int? storageLimit;

  const DTRAppInboxConfig({
    this.enabled,
    this.storageLimit,
  });

  factory DTRAppInboxConfig.fromJson(Map<String, dynamic> json) => _$DTRAppInboxConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRAppInboxConfigToJson(this);
}

/// Represents the crash reporting configuration
@JsonSerializable()
class DTRCrashReportingConfig {
  final bool? autoCollectingEnabled;
  final bool? enabled;
  final int? storageLimit;
  final bool? threadCollection;
  final List<String>? exceptionExclusions;

  const DTRCrashReportingConfig({
    this.autoCollectingEnabled,
    this.enabled,
    this.storageLimit,
    this.threadCollection,
    this.exceptionExclusions,
  });

  factory DTRCrashReportingConfig.fromJson(Map<String, dynamic> json) => _$DTRCrashReportingConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRCrashReportingConfigToJson(this);
}

/// Represents the network configuration
@JsonSerializable()
class DTRNetworkConfig {
  final List<String>? trustPolicies;

  const DTRNetworkConfig({
    this.trustPolicies,
  });

  factory DTRNetworkConfig.fromJson(Map<String, dynamic> json) => _$DTRNetworkConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRNetworkConfigToJson(this);
}

/// Represents the logger configuration
@JsonSerializable()
class DTRLoggerConfig {
  final String? logLevel;
  final bool? writeToFile;

  const DTRLoggerConfig({
    this.logLevel,
    this.writeToFile,
  });

  factory DTRLoggerConfig.fromJson(Map<String, dynamic> json) => _$DTRLoggerConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRLoggerConfigToJson(this);
}

/// Represents the snapshot configuration
@JsonSerializable()
class DTRSnapshotConfig {
  final bool? enabled;
  final List<String>? enabledBundleIDs;
  final int? latencyInMillis;

  const DTRSnapshotConfig({
    this.enabled,
    this.enabledBundleIDs,
    this.latencyInMillis,
  });

  factory DTRSnapshotConfig.fromJson(Map<String, dynamic> json) => _$DTRSnapshotConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DTRSnapshotConfigToJson(this);
}

/// Represents the complete Dataroid SDK configuration
@JsonSerializable()
class DataroidConfig {
  final String sdkKey;
  final String serverURL;
  final String? appGroup;
  final bool? eventCollectingEnabled;
  final int? eventStorageLimit;
  final String? appVersion;
  final String? appPackageName;
  final DTRSessionConfig? session;
  final DTRScreenTrackingConfig? screenTracking;
  final DTRComponentInteractionConfig? componentInteraction;
  final DTRScreenInteractionConfig? screenInteraction;
  final DTRApmConfig? apm;
  final DTRInAppConfig? inApp;
  final DTRPushConfig? push;
  final DTRAppInboxConfig? appInbox;
  final DTRCrashReportingConfig? crashReporting;
  final DTRNetworkConfig? network;
  final DTRLoggerConfig? logger;
  final DTRSnapshotConfig? snapshot;

  const DataroidConfig({
    required this.sdkKey,
    required this.serverURL,
    this.appGroup,
    this.eventCollectingEnabled,
    this.eventStorageLimit,
    this.appVersion,
    this.appPackageName,
    this.session,
    this.screenTracking,
    this.componentInteraction,
    this.screenInteraction,
    this.apm,
    this.inApp,
    this.push,
    this.appInbox,
    this.crashReporting,
    this.network,
    this.logger,
    this.snapshot,
  });

  factory DataroidConfig.fromJson(Map<String, dynamic> json) => _$DataroidConfigFromJson(json);
  Map<String, dynamic> toJson() => _$DataroidConfigToJson(this);

}