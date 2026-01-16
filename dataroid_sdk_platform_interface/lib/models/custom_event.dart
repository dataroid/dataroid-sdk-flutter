/*
 * 
 * user.dart
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

class CustomEvent {
  final String eventName;
  Map<String, dynamic> attributes = {};
  Map<String, int>? _dateAttributes = {};
  Map<String, List<int>>? _intListAttributes = {};
  Map<String, List<String>>? _stringListAttributes = {};

  CustomEvent({
    required this.eventName,
  });

  Map<String, dynamic> get toJSON {
    _parseAttributes();
    return {
      ArgumentName.name: eventName,
      ArgumentName.attributes: attributes,
      ArgumentName.dateAttributes: _dateAttributes,
      ArgumentName.intListAttributes: _intListAttributes,
      ArgumentName.stringListAttributes: _stringListAttributes,
    };
  }

  void _parseAttributes() {
    attributes.entries.forEach((e) {
      if (e.value is DateTime) {
        final value = e.value as DateTime;
        _dateAttributes?[e.key] = value.millisecondsSinceEpoch;
      } else if (e.value is List) {
        // Check the list type by inspecting elements
        final list = e.value as List;
        if (list.isNotEmpty) {
          if (list.first is int) {
            // Integer list
            final intList = list.cast<int>();
            _intListAttributes?[e.key] = intList;
          } else if (list.first is String) {
            // String list
            final stringList = list.cast<String>();
            _stringListAttributes?[e.key] = stringList;
          }
        }
      }
    });
    attributes.removeWhere((key, value) => value is DateTime || value is List);
  }
}
