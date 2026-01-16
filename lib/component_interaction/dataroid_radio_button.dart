/*
 * 
 * dataroid_radio_button.dart
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

import 'package:flutter/material.dart';
import 'package:dataroid_plugin_flutter/dataroid_plugin_flutter.dart';

/// A custom Radio widget that automatically tracks radio button selections
/// using the Dataroid SDK for analytics purposes.
/// 
/// This widget wraps the standard Flutter Radio widget and provides
/// automatic tracking of radio button interactions.
class DataroidRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String groupName;
  final String? label;
  final String? elementName;
  final String? accessibilityLabel;
  final Coordinates? coordinates;
  final ScreenTracker? screenTracker;
  final Color? activeColor;
  final bool autofocus;
  final bool toggleable;
  
  /// Creates a Dataroid-enabled Radio widget.
  /// 
  /// [value] and [groupValue] work the same as Flutter's Radio widget.
  /// [groupName] is required for analytics grouping.
  /// [label] provides a human-readable label for the option.
  /// [elementName] is used for analytics identification (defaults to value.toString()).
  const DataroidRadio({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.groupName,
    this.label,
    this.elementName,
    this.accessibilityLabel,
    this.coordinates,
    this.screenTracker,
    this.activeColor,
    this.autofocus = false,
    this.toggleable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged != null ? _handleRadioChanged : null,
      activeColor: activeColor,
      autofocus: autofocus,
      toggleable: toggleable,
    );
  }

  void _handleRadioChanged(T? newValue) async {
    if (newValue != null) {
      try {
        final radioButtonSelectAttributes = RadioButtonSelectAttributes(
          label: label ?? newValue.toString(),
          groupName: groupName,
          elementType: "radio",
          elementName: elementName ?? "radio_${groupName}_${newValue.toString()}",
          className: "DataroidRadio",
          coordinates: coordinates,
          screenTracker: screenTracker,
          accessibilityLabel: accessibilityLabel,
        );

        await DataroidPluginFlutter().collectRadioButtonSelect(radioButtonSelectAttributes);
      } catch (e) {
        debugPrint('Dataroid: Error tracking radio button selection: $e');
      }
    }
    
    // Call the original onChanged callback
    onChanged?.call(newValue);
  }
}

/// A custom RadioListTile widget that automatically tracks radio button selections
/// using the Dataroid SDK for analytics purposes.
/// 
/// This widget wraps the standard Flutter RadioListTile widget and provides
/// automatic tracking of radio button interactions.
class DataroidRadioListTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String groupName;
  final Widget? title;
  final Widget? subtitle;
  final bool isThreeLine;
  final bool? dense;
  final Widget? secondary;
  final bool selected;
  final ListTileControlAffinity controlAffinity;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final ShapeBorder? shape;
  final Color? tileColor;
  final Color? selectedTileColor;
  final Color? activeColor;
  final bool toggleable;
  
  // Dataroid specific properties
  final String? label;
  final String? elementName;
  final String? accessibilityLabel;
  final Coordinates? coordinates;
  final ScreenTracker? screenTracker;
  
  /// Creates a Dataroid-enabled RadioListTile widget.
  /// 
  /// [value] and [groupValue] work the same as Flutter's RadioListTile widget.
  /// [groupName] is required for analytics grouping.
  /// [label] provides a human-readable label for the option (defaults to title text if available).
  /// [elementName] is used for analytics identification (defaults to value.toString()).
  const DataroidRadioListTile({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.groupName,
    this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.dense,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
    this.autofocus = false,
    this.contentPadding,
    this.shape,
    this.tileColor,
    this.selectedTileColor,
    this.activeColor,
    this.toggleable = false,
    // Dataroid properties
    this.label,
    this.elementName,
    this.accessibilityLabel,
    this.coordinates,
    this.screenTracker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged != null ? _handleRadioChanged : null,
      title: title,
      subtitle: subtitle,
      isThreeLine: isThreeLine,
      dense: dense,
      secondary: secondary,
      selected: selected,
      controlAffinity: controlAffinity,
      autofocus: autofocus,
      contentPadding: contentPadding,
      shape: shape,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
      activeColor: activeColor,
      toggleable: toggleable,
    );
  }

  void _handleRadioChanged(T? newValue) async {
    if (newValue != null) {
      try {
        // Extract text from title widget if it's a Text widget
        String? titleText;
        if (title is Text) {
          titleText = (title as Text).data;
        }
        
        final radioButtonSelectAttributes = RadioButtonSelectAttributes(
          label: label ?? titleText ?? newValue.toString(),
          groupName: groupName,
          elementType: "radio",
          elementName: elementName ?? "radio_${groupName}_${newValue.toString()}",
          className: "DataroidRadioListTile",
          coordinates: coordinates,
          screenTracker: screenTracker,
          accessibilityLabel: accessibilityLabel,
        );

        await DataroidPluginFlutter().collectRadioButtonSelect(radioButtonSelectAttributes);
      } catch (e) {
        debugPrint('Dataroid: Error tracking radio button selection: $e');
      }
    }
    
    // Call the original onChanged callback
    onChanged?.call(newValue);
  }
}

/// A helper class for building radio button groups with automatic Dataroid tracking
class DataroidRadioGroup<T> {
  final String groupName;
  final List<DataroidRadioOption<T>> options;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? accessibilityLabel;
  final Coordinates? coordinates;
  final ScreenTracker? screenTracker;

  const DataroidRadioGroup({
    required this.groupName,
    required this.options,
    this.groupValue,
    this.onChanged,
    this.accessibilityLabel,
    this.coordinates,
    this.screenTracker,
  });

  /// Builds a list of DataroidRadio widgets
  List<DataroidRadio<T>> buildRadios({
    Color? activeColor,
    bool autofocus = false,
    bool toggleable = false,
  }) {
    return options.map((option) => DataroidRadio<T>(
      value: option.value,
      groupValue: groupValue,
      onChanged: onChanged,
      groupName: groupName,
      label: option.label,
      elementName: option.elementName,
      accessibilityLabel: option.accessibilityLabel ?? accessibilityLabel,
      coordinates: coordinates,
      screenTracker: screenTracker,
      activeColor: activeColor,
      autofocus: autofocus,
      toggleable: toggleable,
    )).toList();
  }

  /// Builds a list of DataroidRadioListTile widgets
  List<DataroidRadioListTile<T>> buildListTiles({
    bool isThreeLine = false,
    bool? dense,
    bool selected = false,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.platform,
    bool autofocus = false,
    EdgeInsetsGeometry? contentPadding,
    ShapeBorder? shape,
    Color? tileColor,
    Color? selectedTileColor,
    Color? activeColor,
    bool toggleable = false,
  }) {
    return options.map((option) => DataroidRadioListTile<T>(
      value: option.value,
      groupValue: groupValue,
      onChanged: onChanged,
      groupName: groupName,
      title: option.title,
      subtitle: option.subtitle,
      label: option.label,
      elementName: option.elementName,
      accessibilityLabel: option.accessibilityLabel ?? accessibilityLabel,
      coordinates: coordinates,
      screenTracker: screenTracker,
      isThreeLine: isThreeLine,
      dense: dense,
      selected: selected,
      controlAffinity: controlAffinity,
      autofocus: autofocus,
      contentPadding: contentPadding,
      shape: shape,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
      activeColor: activeColor,
      toggleable: toggleable,
    )).toList();
  }
}

/// A data class representing a radio button option
class DataroidRadioOption<T> {
  final T value;
  final String? label;
  final String? elementName;
  final String? accessibilityLabel;
  final Widget? title;
  final Widget? subtitle;

  const DataroidRadioOption({
    required this.value,
    this.label,
    this.elementName,
    this.accessibilityLabel,
    this.title,
    this.subtitle,
  });
}