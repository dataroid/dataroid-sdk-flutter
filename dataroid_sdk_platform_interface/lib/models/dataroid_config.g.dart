// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataroid_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DTRSessionConfig _$DTRSessionConfigFromJson(Map<String, dynamic> json) =>
    DTRSessionConfig(
      timeout: (json['timeout'] as num?)?.toInt(),
      manualManagement: json['manualManagement'] as bool?,
    );

Map<String, dynamic> _$DTRSessionConfigToJson(DTRSessionConfig instance) =>
    <String, dynamic>{
      'timeout': instance.timeout,
      'manualManagement': instance.manualManagement,
    };

DTRScreenTrackingConfig _$DTRScreenTrackingConfigFromJson(
        Map<String, dynamic> json) =>
    DTRScreenTrackingConfig(
      enabled: json['enabled'] as bool?,
      autoCollectingEnabled: json['autoCollectingEnabled'] as bool?,
      checkInterval: (json['checkInterval'] as num?)?.toInt(),
      ignoreReferralQueryParams: json['ignoreReferralQueryParams'] as bool?,
      ignoreQueryParams: json['ignoreQueryParams'] as bool?,
      shouldTrackInnerViewController:
          json['shouldTrackInnerViewController'] as bool?,
      viewControllerExclusions:
          (json['viewControllerExclusions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$DTRScreenTrackingConfigToJson(
        DTRScreenTrackingConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'autoCollectingEnabled': instance.autoCollectingEnabled,
      'checkInterval': instance.checkInterval,
      'ignoreReferralQueryParams': instance.ignoreReferralQueryParams,
      'ignoreQueryParams': instance.ignoreQueryParams,
      'shouldTrackInnerViewController': instance.shouldTrackInnerViewController,
      'viewControllerExclusions': instance.viewControllerExclusions,
    };

DTRComponentInteractionConfig _$DTRComponentInteractionConfigFromJson(
        Map<String, dynamic> json) =>
    DTRComponentInteractionConfig(
      enabled: json['enabled'] as bool?,
      debounceThreshold: (json['debounceThreshold'] as num?)?.toInt(),
      autoCollectingEnabled: json['autoCollectingEnabled'] as bool?,
      sensitiveViewLabelList: (json['sensitiveViewLabelList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sensitiveComponentSelectorList:
          (json['sensitiveComponentSelectorList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$DTRComponentInteractionConfigToJson(
        DTRComponentInteractionConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'debounceThreshold': instance.debounceThreshold,
      'autoCollectingEnabled': instance.autoCollectingEnabled,
      'sensitiveViewLabelList': instance.sensitiveViewLabelList,
      'sensitiveComponentSelectorList': instance.sensitiveComponentSelectorList,
    };

DTRScreenInteractionConfig _$DTRScreenInteractionConfigFromJson(
        Map<String, dynamic> json) =>
    DTRScreenInteractionConfig(
      enabled: json['enabled'] as bool?,
      autoCollectingEnabled: json['autoCollectingEnabled'] as bool?,
    );

Map<String, dynamic> _$DTRScreenInteractionConfigToJson(
        DTRScreenInteractionConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'autoCollectingEnabled': instance.autoCollectingEnabled,
    };

DTRApmConfig _$DTRApmConfigFromJson(Map<String, dynamic> json) => DTRApmConfig(
      enabled: json['enabled'] as bool?,
      storageLimit: (json['storageLimit'] as num?)?.toInt(),
      autoCollectingEnabled: json['autoCollectingEnabled'] as bool?,
      excludedHosts: (json['excludedHosts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DTRApmConfigToJson(DTRApmConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'storageLimit': instance.storageLimit,
      'autoCollectingEnabled': instance.autoCollectingEnabled,
      'excludedHosts': instance.excludedHosts,
    };

DTRInAppConfig _$DTRInAppConfigFromJson(Map<String, dynamic> json) =>
    DTRInAppConfig(
      enabled: json['enabled'] as bool?,
    );

Map<String, dynamic> _$DTRInAppConfigToJson(DTRInAppConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
    };

DTRPushConfig _$DTRPushConfigFromJson(Map<String, dynamic> json) =>
    DTRPushConfig(
      enabled: json['enabled'] as bool?,
      firebaseOptions: json['firebaseOptions'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DTRPushConfigToJson(DTRPushConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'firebaseOptions': instance.firebaseOptions,
    };

DTRAppInboxConfig _$DTRAppInboxConfigFromJson(Map<String, dynamic> json) =>
    DTRAppInboxConfig(
      enabled: json['enabled'] as bool?,
      storageLimit: (json['storageLimit'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DTRAppInboxConfigToJson(DTRAppInboxConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'storageLimit': instance.storageLimit,
    };

DTRCrashReportingConfig _$DTRCrashReportingConfigFromJson(
        Map<String, dynamic> json) =>
    DTRCrashReportingConfig(
      autoCollectingEnabled: json['autoCollectingEnabled'] as bool?,
      enabled: json['enabled'] as bool?,
      storageLimit: (json['storageLimit'] as num?)?.toInt(),
      threadCollection: json['threadCollection'] as bool?,
      exceptionExclusions: (json['exceptionExclusions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DTRCrashReportingConfigToJson(
        DTRCrashReportingConfig instance) =>
    <String, dynamic>{
      'autoCollectingEnabled': instance.autoCollectingEnabled,
      'enabled': instance.enabled,
      'storageLimit': instance.storageLimit,
      'threadCollection': instance.threadCollection,
      'exceptionExclusions': instance.exceptionExclusions,
    };

DTRNetworkConfig _$DTRNetworkConfigFromJson(Map<String, dynamic> json) =>
    DTRNetworkConfig(
      trustPolicies: (json['trustPolicies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DTRNetworkConfigToJson(DTRNetworkConfig instance) =>
    <String, dynamic>{
      'trustPolicies': instance.trustPolicies,
    };

DTRLoggerConfig _$DTRLoggerConfigFromJson(Map<String, dynamic> json) =>
    DTRLoggerConfig(
      logLevel: json['logLevel'] as String?,
      writeToFile: json['writeToFile'] as bool?,
    );

Map<String, dynamic> _$DTRLoggerConfigToJson(DTRLoggerConfig instance) =>
    <String, dynamic>{
      'logLevel': instance.logLevel,
      'writeToFile': instance.writeToFile,
    };

DTRSnapshotConfig _$DTRSnapshotConfigFromJson(Map<String, dynamic> json) =>
    DTRSnapshotConfig(
      enabled: json['enabled'] as bool?,
      enabledBundleIDs: (json['enabledBundleIDs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      latencyInMillis: (json['latencyInMillis'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DTRSnapshotConfigToJson(DTRSnapshotConfig instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'enabledBundleIDs': instance.enabledBundleIDs,
      'latencyInMillis': instance.latencyInMillis,
    };

DataroidConfig _$DataroidConfigFromJson(Map<String, dynamic> json) =>
    DataroidConfig(
      sdkKey: json['sdkKey'] as String,
      serverURL: json['serverURL'] as String,
      appGroup: json['appGroup'] as String?,
      eventCollectingEnabled: json['eventCollectingEnabled'] as bool?,
      eventStorageLimit: (json['eventStorageLimit'] as num?)?.toInt(),
      appVersion: json['appVersion'] as String?,
      appPackageName: json['appPackageName'] as String?,
      session: json['session'] == null
          ? null
          : DTRSessionConfig.fromJson(json['session'] as Map<String, dynamic>),
      screenTracking: json['screenTracking'] == null
          ? null
          : DTRScreenTrackingConfig.fromJson(
              json['screenTracking'] as Map<String, dynamic>),
      componentInteraction: json['componentInteraction'] == null
          ? null
          : DTRComponentInteractionConfig.fromJson(
              json['componentInteraction'] as Map<String, dynamic>),
      screenInteraction: json['screenInteraction'] == null
          ? null
          : DTRScreenInteractionConfig.fromJson(
              json['screenInteraction'] as Map<String, dynamic>),
      apm: json['apm'] == null
          ? null
          : DTRApmConfig.fromJson(json['apm'] as Map<String, dynamic>),
      inApp: json['inApp'] == null
          ? null
          : DTRInAppConfig.fromJson(json['inApp'] as Map<String, dynamic>),
      push: json['push'] == null
          ? null
          : DTRPushConfig.fromJson(json['push'] as Map<String, dynamic>),
      appInbox: json['appInbox'] == null
          ? null
          : DTRAppInboxConfig.fromJson(
              json['appInbox'] as Map<String, dynamic>),
      crashReporting: json['crashReporting'] == null
          ? null
          : DTRCrashReportingConfig.fromJson(
              json['crashReporting'] as Map<String, dynamic>),
      network: json['network'] == null
          ? null
          : DTRNetworkConfig.fromJson(json['network'] as Map<String, dynamic>),
      logger: json['logger'] == null
          ? null
          : DTRLoggerConfig.fromJson(json['logger'] as Map<String, dynamic>),
      snapshot: json['snapshot'] == null
          ? null
          : DTRSnapshotConfig.fromJson(
              json['snapshot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataroidConfigToJson(DataroidConfig instance) =>
    <String, dynamic>{
      'sdkKey': instance.sdkKey,
      'serverURL': instance.serverURL,
      'appGroup': instance.appGroup,
      'eventCollectingEnabled': instance.eventCollectingEnabled,
      'eventStorageLimit': instance.eventStorageLimit,
      'appVersion': instance.appVersion,
      'appPackageName': instance.appPackageName,
      'session': instance.session,
      'screenTracking': instance.screenTracking,
      'componentInteraction': instance.componentInteraction,
      'screenInteraction': instance.screenInteraction,
      'apm': instance.apm,
      'inApp': instance.inApp,
      'push': instance.push,
      'appInbox': instance.appInbox,
      'crashReporting': instance.crashReporting,
      'network': instance.network,
      'logger': instance.logger,
      'snapshot': instance.snapshot,
    };
