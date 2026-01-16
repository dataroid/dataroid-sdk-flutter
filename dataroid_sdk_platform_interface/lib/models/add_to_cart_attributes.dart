/*
 * 
 * add_to_cart_attributes.dart
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
import 'package:dataroid_sdk_platform_interface/models/product.dart';
import 'package:dataroid_sdk_platform_interface/models/custom_attribute.dart';
import 'package:dataroid_sdk_platform_interface/constants.dart';

class AddToCartAttributes extends CommerceEvent {
  final Product product;
  final int? value;
  final int? totalCartValue;

  AddToCartAttributes({
    required this.product,
    this.value,
    this.totalCartValue,
    super.attributes,
  });

  factory AddToCartAttributes.fromJson(Map<String, dynamic> json) {
    final productJson = json[ArgumentName.product] as Map<String, dynamic>;
    return AddToCartAttributes(
      product: Product.fromJson(productJson),
      value: json[ArgumentName.value] as int?,
      totalCartValue: json[ArgumentName.totalCartValue] as int?,
      attributes: (json[ArgumentName.attributes] as Map<String, dynamic>?)
          ?.entries
          .map((e) => CustomAttribute(key: e.key, value: e.value))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> get toJSON => {
        ...super.toJSON,
        ArgumentName.product: product.toJSON,
        ArgumentName.value: value,
        ArgumentName.totalCartValue: totalCartValue,
      };
} 