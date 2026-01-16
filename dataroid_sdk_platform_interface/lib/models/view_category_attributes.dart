/*
 * 
 * view_category_attributes.dart
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

class ViewCategoryAttributes extends CommerceEvent {
  final String category;

  ViewCategoryAttributes({
    required this.category,
    super.attributes,
  });

  factory ViewCategoryAttributes.fromJson(Map<String, dynamic> json) {
    return ViewCategoryAttributes(
      category: json[ArgumentName.category] as String,
      attributes: (json[ArgumentName.attributes] as Map<String, dynamic>?)
          ?.entries
          .map((e) => CustomAttribute(key: e.key, value: e.value))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> get toJSON => {
        ...super.toJSON,
        ArgumentName.category: category,
      };
} 