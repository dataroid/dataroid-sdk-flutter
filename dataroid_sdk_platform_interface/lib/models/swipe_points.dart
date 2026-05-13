/*
 * 
 * swipe_points.dart
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
import 'package:dataroid_sdk_platform_interface/models/touch_point.dart';

class SwipePoints {
  final TouchPoint start;
  final TouchPoint end;

  SwipePoints({required this.start, required this.end});

  factory SwipePoints.fromJson(Map<String, dynamic> json) {
    return SwipePoints(
      start: TouchPoint.fromJson(json[ArgumentName.start] ?? {}),
      end: TouchPoint.fromJson(json[ArgumentName.end] ?? {}),
    );
  }

  Map<String, dynamic> get toJSON {
    return {
      ArgumentName.start: start.toJSON,
      ArgumentName.end: end.toJSON,
    };
  }

  @override
  String toString() => 'SwipePoints(start: $start, end: $end)';
}
