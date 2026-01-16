/*
 * 
 * purchase_attributes.dart
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

class PurchaseAttributes extends CommerceEvent {
  final String currency;
  final double value;
  final List<Product> products;
  final bool success;
  double? tax;
  double? ship;
  double? discount;
  String? coupon;
  String? trxId;
  String? paymentMethod;
  int? quantity;
  String? errorCode;
  String? errorMessage;

  PurchaseAttributes({
    required this.currency,
    required this.value,
    required this.products,
    required this.success,
    this.tax,
    this.ship,
    this.discount,
    this.coupon,
    this.trxId,
    this.paymentMethod,
    this.quantity,
    this.errorCode,
    this.errorMessage,
    super.attributes,
  });

  factory PurchaseAttributes.fromJson(Map<String, dynamic> json) {
    final productsJson = json[ArgumentName.products] as List<dynamic>;
    return PurchaseAttributes(
      currency: json[ArgumentName.currency] as String,
      value: (json[ArgumentName.value] as num).toDouble(),
      products: productsJson
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList(),
      success: json[ArgumentName.success] as bool,
      tax: json[ArgumentName.tax] != null ? (json[ArgumentName.tax] as num).toDouble() : null,
      ship: json[ArgumentName.ship] != null ? (json[ArgumentName.ship] as num).toDouble() : null,
      discount: json[ArgumentName.discount] != null ? (json[ArgumentName.discount] as num).toDouble() : null,
      coupon: json[ArgumentName.coupon] as String?,
      trxId: json[ArgumentName.trxId] as String?,
      paymentMethod: json[ArgumentName.paymentMethod] as String?,
      quantity: json[ArgumentName.quantity] as int?,
      errorCode: json[ArgumentName.errorCode] as String?,
      errorMessage: json[ArgumentName.errorMessage] as String?,
      attributes: (json[ArgumentName.attributes] as Map<String, dynamic>?)
          ?.entries
          .map((e) => CustomAttribute(key: e.key, value: e.value))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> get toJSON => {
        ...super.toJSON,
        ArgumentName.currency: currency,
        ArgumentName.value: value,
        ArgumentName.products: products.map((e) => e.toJSON).toList(),
        ArgumentName.success: success,
        ArgumentName.tax: tax,
        ArgumentName.ship: ship,
        ArgumentName.discount: discount,
        ArgumentName.coupon: coupon,
        ArgumentName.trxId: trxId,
        ArgumentName.paymentMethod: paymentMethod,
        ArgumentName.quantity: quantity,
        ArgumentName.errorCode: errorCode,
        ArgumentName.errorMessage: errorMessage,
      };
} 