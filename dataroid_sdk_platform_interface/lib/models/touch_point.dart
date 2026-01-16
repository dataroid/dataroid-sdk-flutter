/*
 * 
 * touch_point.dart
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

class TouchPoint {
  final int x;
  final int y;

  TouchPoint(this.x, this.y);

  factory TouchPoint.fromJson(Map<String, dynamic> json) {
    return TouchPoint(
      json[ArgumentName.x] ?? 0,
      json[ArgumentName.y] ?? 0,
    );
  }

  Map<String, dynamic> get toJSON {
    return {
      ArgumentName.x: x,
      ArgumentName.y: y,
    };
  }
}
