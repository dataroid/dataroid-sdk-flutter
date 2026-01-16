/*
 * 
 * deeplink_attributes.dart
 * Dataroid-Plugin-Flutter
 *
 * Created on 29/1/2024.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 *
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 *
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';

class DeeplinkAttributes {
  final String url;
  Map<String, dynamic> attributes = {};
  Map<String, int>? _dateAttributes = {};
  Map<String, List<int>>? _intListAttributes = {};
  Map<String, List<String>>? _stringListAttributes = {};

  DeeplinkAttributes({
    required this.url,
  });

  Map<String, dynamic> get toJSON {
    _parseAttributes();
    return {
      ArgumentName.url: url,
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
      } else if (e.value is List<int>) {
        final value = e.value as List<int>;
        _intListAttributes?[e.key] = value;
      } else if (e.value is List<String>) {
        final value = e.value as List<String>;
        _stringListAttributes?[e.key] = value;
      }
    });
    attributes.removeWhere((key, value) => value is DateTime || value is List<int> || value is List<String>);
  }
}
