/*
 * 
 * product.dart
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

import 'package:dataroid_sdk_platform_interface/constants.dart';

class Product {
  String id;
  String name;
  int quantity;
  double price;
  String currency;
  String? productDescription;
  String? brand;
  String? variant;
  String? category;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.currency,
    this.productDescription,
    this.brand,
    this.variant,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json[ArgumentName.id] as String,
      name: json[ArgumentName.name] as String,
      quantity: json[ArgumentName.quantity] as int,
      price: (json[ArgumentName.price] as num).toDouble(),
      currency: json[ArgumentName.currency] as String,
      productDescription: json[ArgumentName.description] as String?,
      brand: json[ArgumentName.brand] as String?,
      variant: json[ArgumentName.variant] as String?,
      category: json[ArgumentName.category] as String?,
    );
  }

  Map<String, dynamic> get toJSON => {
        ArgumentName.id: id,
        ArgumentName.name: name,
        ArgumentName.quantity: quantity,
        ArgumentName.price: price,
        ArgumentName.currency: currency,
        ArgumentName.description: productDescription,
        ArgumentName.brand: brand,
        ArgumentName.variant: variant,
        ArgumentName.category: category,
      };
} 