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

class SuperAttribute {
  final String key;
  dynamic value;
  int? _dateValue;

  SuperAttribute({
    required this.key,
    required this.value,
  });

  Map<String, dynamic> get toJSON {
    _parseValue();
    return {
      ArgumentName.key: key,
      ArgumentName.attributes: value,
      ArgumentName.dateAttributes: _dateValue,
    };
  }

  void _parseValue() {
    if (value is DateTime) {
      value = value as DateTime;
      _dateValue = value.millisecondsSinceEpoch;
      value = null;
    }
  }
}
