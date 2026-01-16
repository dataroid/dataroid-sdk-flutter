/*
 * 
 * text_change_attributes.dart
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
import 'package:dataroid_sdk_platform_interface/models/coordinates.dart';
import 'package:dataroid_sdk_platform_interface/models/screen_tracker.dart';
import 'package:dataroid_sdk_platform_interface/constants.dart';

class TextChangeAttributes extends ComponentAttributes {
  final String? placeholder;
  final String textValue;
  final String? elementType;
  final String? elementName;

  TextChangeAttributes({
    this.placeholder,
    required this.textValue,
    this.elementType,
    this.elementName,
    super.accessibilityLabel,
    super.componentId,
    required super.className,
    super.coordinates,
    super.screenTracker,
  });

  factory TextChangeAttributes.fromJson(Map<String, dynamic> json) {
    return TextChangeAttributes(
      placeholder: json[ArgumentName.placeholder],
      textValue: json[ArgumentName.value] ?? '',
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
        ArgumentName.placeholder: placeholder,
        ArgumentName.value: textValue,
        ArgumentName.elementType: elementType,
        ArgumentName.elementName: elementName,
        ArgumentName.accessibilityLabel: accessibilityLabel,
        ArgumentName.componentId: componentId,
        ArgumentName.className: className,
        ArgumentName.coordinates: coordinates?.toJSON,
        ArgumentName.screenTrackingAttributes: screenTracker?.toJSON,
      };
} 