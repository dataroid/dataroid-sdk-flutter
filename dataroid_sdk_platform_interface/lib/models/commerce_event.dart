/*
 * 
 * commerce_event.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 31/1/2024.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';
import 'package:dataroid_sdk_platform_interface/models/custom_attribute.dart';

class CommerceEvent {
  // Maximum number of extra parameters allowed for commerce events
  // When exceeded, the first parameters will be removed to maintain this limit
  static const int maxExtraParams = 10;

  final List<CustomAttribute>? attributes;

  Map<String, dynamic>? _attributesMap = {};
  Map<String, int>? _dateAttributes = {};
  Map<String, List<int>>? _intListAttributes = {};
  Map<String, List<String>>? _stringListAttributes = {};

  CommerceEvent({
    this.attributes,
  });

  Map<String, dynamic> get toJSON {
    _parseAttributes();
    return {
      ArgumentName.attributes: _attributesMap,
      ArgumentName.dateAttributes: _dateAttributes,
      ArgumentName.intListAttributes: _intListAttributes,
      ArgumentName.stringListAttributes: _stringListAttributes,
    };
  }

  void _parseAttributes() {
    if (attributes == null || attributes!.isEmpty) {
      return;
    }

    // Limit attributes to maxExtraParams (10) by keeping only the last 10
    // If we have more than 10, remove the first ones (FIFO - First In, First Out)
    final List<CustomAttribute> attributesToProcess = attributes!.length > maxExtraParams
        ? attributes!.sublist(attributes!.length - maxExtraParams)
        : attributes!;

    for (final e in attributesToProcess) {
      if (e.value is DateTime) {
        final value = e.value as DateTime;
        _dateAttributes?[e.key] = value.millisecondsSinceEpoch;
      } else if (e.value is List<int>) {
        final value = e.value as List<int>;
        _intListAttributes?[e.key] = value;
      } else if (e.value is List<String>) {
        final value = e.value as List<String>;
        _stringListAttributes?[e.key] = value;
      } else {
        _attributesMap?[e.key] = e.value;
      }
    }
  }
} 