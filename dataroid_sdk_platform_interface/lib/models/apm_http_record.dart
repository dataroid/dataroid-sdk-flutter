/*
 * 
 * apm_http_record.dart
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

enum HTTPMethod {
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
  HEAD,
  OPTIONS,
  TRACE,
  CONNECT
}

enum ConnectionType {
  NONE,
  CELLULAR,
  WIFI,
  ETHERNET,
  BLUETOOTH,
  WIFI_AWARE,
  LOWPAN,
  VPN
}

enum ResourceType {
  XHR,
  JS,
  CSS,
  IMG,
  MEDIA,
  OTHER
}

class CustomAttribute {
  final String key;
  final dynamic value;
  
  CustomAttribute({required this.key, required this.value});

  factory CustomAttribute.fromJson(Map<String, dynamic> json) {
    return CustomAttribute(
      key: json['key'] as String,
      value: json['value'],
    );
  }
  
  Map<String, dynamic> get toJSON => {
    'key': key,
    'value': value,
  };
}

class APMHTTPRecord {
  String url;
  HTTPMethod method;
  int statusCode;
  double? requestSize;
  double? responseSize;
  int duration;
  bool success;
  String? errorType;
  String? errorCode;
  String? errorMessage;
  String? viewLabel;
  ResourceType? resourceType;
  ConnectionType? connectionType;
  List<CustomAttribute>? customAttributes;
  Map<String, int>? _dateAttributes = {};
  Map<String, List<int>>? _intListAttributes = {};
  Map<String, List<String>>? _stringListAttributes = {};

  APMHTTPRecord({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.duration,
    required this.success,
    this.requestSize,
    this.responseSize,
    this.errorType,
    this.errorCode,
    this.errorMessage,
    this.viewLabel,
    this.resourceType,
    this.connectionType,
    this.customAttributes,
  });

  factory APMHTTPRecord.fromJson(Map<String, dynamic> json) {
    return APMHTTPRecord(
      url: json['url'] ?? '',
      method: HTTPMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => HTTPMethod.GET,
      ),
      statusCode: json['statusCode'] ?? 0,
      duration: json['duration'] ?? 0,
      success: json['success'] ?? false,
      requestSize: json['requestSize']?.toDouble(),
      responseSize: json['responseSize']?.toDouble(),
      errorType: json['errorType'],
      errorCode: json['errorCode'],
      errorMessage: json['errorMessage'],
      viewLabel: json['viewLabel'],
      resourceType: json['resourceType'] != null 
        ? ResourceType.values.firstWhere(
            (e) => e.name == json['resourceType'],
            orElse: () => ResourceType.OTHER,
          )
        : null,
      connectionType: json['connectionType'] != null
        ? ConnectionType.values.firstWhere(
            (e) => e.name == json['connectionType'],
            orElse: () => ConnectionType.NONE,
          )
        : null,
    );
  }

  Map<String, dynamic> get toJSON {
    _parseAttributes();
    return {
      ArgumentName.url: url,
      ArgumentName.method: method.name,
      ArgumentName.statusCode: statusCode,
      ArgumentName.requestSize: requestSize,
      ArgumentName.responseSize: responseSize,
      ArgumentName.duration: duration,
      ArgumentName.success: success,
      ArgumentName.errorType: errorType,
      ArgumentName.errorCode: errorCode,
      ArgumentName.errorMessage: errorMessage,
      'viewLabel': viewLabel,
      'resourceType': resourceType?.name,
      'connectionType': connectionType?.name,
      ArgumentName.customAttributes: customAttributes != null 
        ? Map.fromEntries(customAttributes!.map((e) => MapEntry(e.key, e.value)))
        : null,
      ArgumentName.dateAttributes: _dateAttributes,
      ArgumentName.intListAttributes: _intListAttributes,
      ArgumentName.stringListAttributes: _stringListAttributes,
    };
  }

  void _parseAttributes() {
    customAttributes?.forEach((e) {
      if (e.value is DateTime) {
        final value = e.value as DateTime;
        _dateAttributes?[e.key] = value.millisecondsSinceEpoch;
      } else if (e.value is List<int>) {
        final value = e.value as List<int>;
        _intListAttributes?[e.key] = value;
      } else if (e.value is List<String>) {
        final value = e.value as List<String>;
        _stringListAttributes?[e.key] = value;
      }
    });
    customAttributes?.removeWhere((e) => e.value is DateTime || e.value is List<int> || e.value is List<String>);
  }
} 