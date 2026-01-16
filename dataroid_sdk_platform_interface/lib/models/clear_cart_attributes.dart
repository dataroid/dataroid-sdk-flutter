/*
 * 
 * clear_cart_attributes.dart
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

import 'package:dataroid_sdk_platform_interface/models/commerce_event.dart';
import 'package:dataroid_sdk_platform_interface/models/custom_attribute.dart';
import 'package:dataroid_sdk_platform_interface/constants.dart';

class ClearCartAttributes extends CommerceEvent {
  ClearCartAttributes({
    super.attributes,
  });

  factory ClearCartAttributes.fromJson(Map<String, dynamic> json) {
    return ClearCartAttributes(
      attributes: (json[ArgumentName.attributes] as Map<String, dynamic>?)
          ?.entries
          .map((e) => CustomAttribute(key: e.key, value: e.value))
          .toList(),
    );
  }
} 