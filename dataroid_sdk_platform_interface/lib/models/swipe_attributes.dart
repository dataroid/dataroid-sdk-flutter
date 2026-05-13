/*
 * 
 * swipe_attributes.dart
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
import 'package:dataroid_sdk_platform_interface/models/swipe_points.dart';
import 'package:dataroid_sdk_platform_interface/constants.dart';

class SwipeAttributes extends ComponentAttributes {
  final SwipePoints swipePoints;

  SwipeAttributes({
    required this.swipePoints,
    super.accessibilityLabel,
    super.componentId,
    required super.className,
    super.coordinates,
    super.screenTracker,
  });

  @override
  Map<String, dynamic> get toJSON {
    return {
      ArgumentName.swipePoints: swipePoints.toJSON,
      ArgumentName.accessibilityLabel: accessibilityLabel,
      ArgumentName.componentId: componentId,
      ArgumentName.className: className,
      ArgumentName.coordinates: coordinates?.toJSON,
      ArgumentName.screenTrackingAttributes: screenTracker?.toJSON,
    };
  }

  @override
  String toString() =>
      'SwipeAttributes(swipePoints: $swipePoints, className: $className'
      '${componentId != null ? ', componentId: $componentId' : ''}'
      '${accessibilityLabel != null ? ', accessibilityLabel: $accessibilityLabel' : ''}'
      '${coordinates != null ? ', coordinates: $coordinates' : ''}'
      '${screenTracker != null ? ', screen: $screenTracker' : ''}'
      ')';
}
