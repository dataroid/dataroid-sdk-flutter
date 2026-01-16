/*
 * 
 * touch_attributes.dart
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

import 'package:dataroid_sdk_platform_interface/models/component_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/touch_point.dart';
import 'package:dataroid_sdk_platform_interface/constants.dart';

class TouchAttributes extends ComponentAttributes {
  final TouchPoint touchPoint;

  TouchAttributes({
    required this.touchPoint,
    super.accessibilityLabel,
    super.componentId,
    required super.className,
    super.coordinates,
    super.screenTracker,
  });

  @override
  Map<String, dynamic> get toJSON {
    return {
      ArgumentName.touchPoint: touchPoint.toJSON,
      ArgumentName.accessibilityLabel: accessibilityLabel,
      ArgumentName.componentId: componentId,
      ArgumentName.className: className,
      ArgumentName.coordinates: coordinates?.toJSON,
      ArgumentName.screenTrackingAttributes: screenTracker?.toJSON,
    };
  }
}
