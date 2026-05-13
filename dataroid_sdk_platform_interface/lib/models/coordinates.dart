/*
 * 
 * coordinates.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 30/1/2024.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';

class Coordinates {
  final int left;
  final int top;
  final int right;
  final int bottom;

  Coordinates(
      {required this.left,
      required this.top,
      required this.right,
      required this.bottom});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      left: json[ArgumentName.left] ?? 0,
      top: json[ArgumentName.top] ?? 0,
      right: json[ArgumentName.right] ?? 0,
      bottom: json[ArgumentName.bottom] ?? 0,
    );
  }

  Map<String, dynamic> get toJSON {
    return {
      ArgumentName.left: left,
      ArgumentName.top: top,
      ArgumentName.right: right,
      ArgumentName.bottom: bottom,
    };
  }

  @override
  String toString() =>
      'Coordinates(left: $left, top: $top, right: $right, bottom: $bottom)';
}
