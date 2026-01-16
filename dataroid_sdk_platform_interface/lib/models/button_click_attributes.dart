/*
 * 
 * button_click_attributes.dart
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

import 'package:dataroid_sdk_platform_interface/models/component_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/coordinates.dart';
import 'package:dataroid_sdk_platform_interface/models/screen_tracker.dart';
import 'package:dataroid_sdk_platform_interface/constants.dart';

class ButtonClickAttributes extends ComponentAttributes {
  final String? label;
  final String? href;
  final String? elementType;
  final String? elementName;

  ButtonClickAttributes({
    this.label,
    this.href,
    this.elementType,
    this.elementName,
    super.accessibilityLabel,
    super.componentId,
    required super.className,
    super.coordinates,
    super.screenTracker,
  });

  factory ButtonClickAttributes.fromJson(Map<String, dynamic> json) {
    return ButtonClickAttributes(
      label: json[ArgumentName.label],
      href: json[ArgumentName.href],
      elementType: json[ArgumentName.elementType],
      elementName: json[ArgumentName.elementName],
      accessibilityLabel: json[ArgumentName.accessibilityLabel],
      componentId: json[ArgumentName.componentId],
      className: json[ArgumentName.className] ?? '',
      coordinates: json[ArgumentName.coordinates] != null 
          ? Coordinates.fromJson(json[ArgumentName.coordinates]) 
          : null,
      screenTracker: json[ArgumentName.screenTrackingAttributes] != null 
          ? ScreenTracker.fromJson(json[ArgumentName.screenTrackingAttributes]) 
          : null,
    );
  }

  @override
  Map<String, dynamic> get toJSON => {
        ArgumentName.label: label,
        ArgumentName.href: href,
        ArgumentName.elementType: elementType,
        ArgumentName.elementName: elementName,
        ArgumentName.accessibilityLabel: accessibilityLabel,
        ArgumentName.componentId: componentId,
        ArgumentName.className: className,
        ArgumentName.coordinates: coordinates?.toJSON,
        ArgumentName.screenTrackingAttributes: screenTracker?.toJSON,
      };
} 