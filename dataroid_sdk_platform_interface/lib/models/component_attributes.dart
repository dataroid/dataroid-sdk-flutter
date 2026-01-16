/*
 * 
 * component_attributes.dart
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

import 'package:dataroid_sdk_platform_interface/models/screen_tracker.dart';
import 'package:dataroid_sdk_platform_interface/models/coordinates.dart';

abstract class ComponentAttributes {
  final String? accessibilityLabel;
  final String? componentId;
  final String className;
  final Coordinates? coordinates;
  final ScreenTracker? screenTracker;

  ComponentAttributes({
    this.accessibilityLabel,
    this.componentId,
    required this.className,
    this.coordinates,
    this.screenTracker,
  });

  Map<String, dynamic> get toJSON;
} 