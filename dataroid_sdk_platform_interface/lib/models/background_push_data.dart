/*
 * Copyright 2025 Dataroid. All Rights Reserved.
 *
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 */

/// Background push notification data containing notification details and custom parameters
class BackgroundPushData {
  /// The notification ID that uniquely identifies this background push notification
  final String? notificationId;

  /// The schedule ID associated with this notification (optional)
  final String? scheduleId;

  /// Custom parameters from the push payload (prefixed with "p." in the original payload)
  final Map<String, String> parameters;

  /// Dynamic string attributes associated with the notification
  final Map<String, String> dynamicStringAttributes;

  /// Dynamic integer attributes associated with the notification
  final Map<String, int> dynamicIntegerAttributes;

  /// Dynamic boolean attributes associated with the notification
  final Map<String, bool> dynamicBooleanAttributes;

  const BackgroundPushData({
    this.notificationId,
    this.scheduleId,
    this.parameters = const {},
    this.dynamicStringAttributes = const {},
    this.dynamicIntegerAttributes = const {},
    this.dynamicBooleanAttributes = const {},
  });

  /// Creates a BackgroundPushData from a map (typically from method channel)
  factory BackgroundPushData.fromMap(Map<dynamic, dynamic> map) {
    // Convert the dynamic map to a proper Map<String, dynamic>
    final stringMap = Map<String, dynamic>.from(map);
    
    return BackgroundPushData(
      notificationId: stringMap['notificationId'] as String? ?? stringMap['pushId'] as String?,
      scheduleId: stringMap['scheduleId'] as String?,
      parameters: _safeMapStringString(stringMap['parameters']),
      dynamicStringAttributes: _safeMapStringString(stringMap['dynamicStringAttributes']),
      dynamicIntegerAttributes: _safeMapStringInt(stringMap['dynamicIntegerAttributes']),
      dynamicBooleanAttributes: _safeMapStringBool(stringMap['dynamicBooleanAttributes']),
    );
  }

  /// Helper method to safely convert to Map<String, String>
  static Map<String, String> _safeMapStringString(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, String>.from(value.map((k, v) => MapEntry(k.toString(), v.toString())));
    }
    return {};
  }

  /// Helper method to safely convert to Map<String, int>
  static Map<String, int> _safeMapStringInt(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      final result = <String, int>{};
      value.forEach((k, v) {
        if (v is int) {
          result[k.toString()] = v;
        } else if (v is num) {
          result[k.toString()] = v.toInt();
        }
      });
      return result;
    }
    return {};
  }

  /// Helper method to safely convert to Map<String, bool>
  static Map<String, bool> _safeMapStringBool(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      final result = <String, bool>{};
      value.forEach((k, v) {
        if (v is bool) {
          result[k.toString()] = v;
        }
      });
      return result;
    }
    return {};
  }

  /// Converts the BackgroundPushData to a map for method channel transmission
  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'scheduleId': scheduleId,
      'parameters': parameters,
      'dynamicStringAttributes': dynamicStringAttributes,
      'dynamicIntegerAttributes': dynamicIntegerAttributes,
      'dynamicBooleanAttributes': dynamicBooleanAttributes,
    };
  }

  /// Returns the notification ID as pushId for tracking purposes
  String? get pushId => notificationId;

  @override
  String toString() {
    return 'BackgroundPushData{notificationId: $notificationId, scheduleId: $scheduleId, '
        'parameters: $parameters, dynamicStringAttributes: $dynamicStringAttributes, '
        'dynamicIntegerAttributes: $dynamicIntegerAttributes, '
        'dynamicBooleanAttributes: $dynamicBooleanAttributes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackgroundPushData &&
          runtimeType == other.runtimeType &&
          notificationId == other.notificationId &&
          scheduleId == other.scheduleId &&
          _mapEquals(parameters, other.parameters) &&
          _mapEquals(dynamicStringAttributes, other.dynamicStringAttributes) &&
          _mapEquals(dynamicIntegerAttributes, other.dynamicIntegerAttributes) &&
          _mapEquals(dynamicBooleanAttributes, other.dynamicBooleanAttributes);

  @override
  int get hashCode =>
      notificationId.hashCode ^
      scheduleId.hashCode ^
      parameters.hashCode ^
      dynamicStringAttributes.hashCode ^
      dynamicIntegerAttributes.hashCode ^
      dynamicBooleanAttributes.hashCode;

  bool _mapEquals<K, V>(Map<K, V> map1, Map<K, V> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }
    return true;
  }
}
