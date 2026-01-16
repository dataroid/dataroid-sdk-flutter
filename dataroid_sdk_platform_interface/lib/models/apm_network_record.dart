/*
 * 
 * apm_network_record.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 30/11/2020.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/models/apm_http_record.dart';
import 'package:dataroid_sdk_platform_interface/constants.dart';

enum ErrorType {
  unknown(0),
  noConnection(1),
  ssl(2),
  timeout(4),
  authFailure(8),
  network(16),
  parse(32),
  server(64),
  cancelled(128),
  insecureConnection(256);

  final int value;

  const ErrorType(this.value);
}

class APMNetworkRecord {
  String url;
  HTTPMethod method;
  int duration;
  String exception;
  ErrorType type;
  String? message;
  List<CustomAttribute>? customAttributes;
  Map<String, int>? _dateAttributes = {};
  Map<String, List<int>>? _intListAttributes = {};
  Map<String, List<String>>? _stringListAttributes = {};

  APMNetworkRecord({
    required this.url,
    required this.method,
    required this.duration,
    required this.exception,
    required this.type,
    this.message,
    this.customAttributes,
  });

  factory APMNetworkRecord.fromJson(Map<String, dynamic> json) {
    return APMNetworkRecord(
      url: json[ArgumentName.url] as String,
      method: HTTPMethod.values.firstWhere((e) => e.name == json[ArgumentName.method]),
      duration: json[ArgumentName.duration] as int,
      exception: json[ArgumentName.exception] as String,
      type: ErrorType.values.firstWhere((e) => e.value == json[ArgumentName.type]),
      message: json[ArgumentName.message] as String?,
      customAttributes: (json[ArgumentName.customAttributes] as List<dynamic>?)
          ?.map((e) => CustomAttribute.fromJson(e as Map<String, dynamic>))
          .toList(),
    ).._dateAttributes = Map<String, int>.from(json[ArgumentName.dateAttributes] ?? {})
     .._intListAttributes = (json[ArgumentName.intListAttributes] as Map<String, dynamic>?)
         ?.map((key, value) => MapEntry(key, List<int>.from(value)))
     .._stringListAttributes = (json[ArgumentName.stringListAttributes] as Map<String, dynamic>?)
         ?.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  Map<String, dynamic> get toJSON {
    _parseAttributes();
    return {
      ArgumentName.url: url,
      ArgumentName.method: method.name,
      ArgumentName.duration: duration,
      ArgumentName.exception: exception,
      ArgumentName.type: type.value,
      ArgumentName.message: message,
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
