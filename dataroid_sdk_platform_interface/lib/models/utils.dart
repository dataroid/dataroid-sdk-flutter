import 'dart:convert';

import 'package:dataroid_sdk_platform_interface/models/dataroid_config.dart';
import 'package:dataroid_sdk_platform_interface/models/screen_tracker.dart';
import 'package:dataroid_sdk_platform_interface/models/user.dart';
import 'package:dataroid_sdk_platform_interface/models/apm_http_record.dart';
import 'package:dataroid_sdk_platform_interface/models/apm_network_record.dart';
import 'package:dataroid_sdk_platform_interface/models/commerce_event.dart';
import 'package:dataroid_sdk_platform_interface/models/view_product_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/search_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/add_to_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/remove_from_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/clear_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/start_checkout_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/add_to_wishlist_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/remove_from_wishlist_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/view_category_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/purchase_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/button_click_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/text_change_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/toggle_change_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/radio_button_select_attributes.dart';

/// Safely encodes an object to JSON string, handling DateTime objects by converting them to ISO strings
String safeJsonEncode(Object? object) {
  return jsonEncode(object, toEncodable: (dynamic item) {
    if (item is DateTime) return item.toIso8601String();
    if (item is DataroidConfig) return item.toJson();
    if (item is ScreenTracker) return item.toJSON;
    if (item is User) return item.toJSON;
    if (item is APMHTTPRecord) return item.toJSON;
    if (item is APMNetworkRecord) return item.toJSON;
    if (item is CommerceEvent) return item.toJSON;
    // Component interaction attributes
    if (item is ButtonClickAttributes) return item.toJSON;
    if (item is TextChangeAttributes) return item.toJSON;
    if (item is ToggleChangeAttributes) return item.toJSON;
    if (item is RadioButtonSelectAttributes) return item.toJSON;
    return item;
  });
}

/// Safely decodes a JSON string or Map, optionally converting ISO date strings back to DateTime objects
/// 
/// [data] - The JSON string or Map to decode/process
/// [dateKeys] - Optional list of keys that should be converted from ISO strings to DateTime objects
/// [autoDetectDates] - If true, automatically detects and converts ISO date strings to DateTime objects
/// [factory] - Optional factory function to create instances of type T from the decoded JSON
T safeJsonDecode<T>(dynamic data, {List<String>? dateKeys, bool autoDetectDates = false, T Function(Map<String, dynamic>)? factory}) {
  // Handle both JSON string and Map input
  dynamic processedData;
  
  if (data is String) {
    final decoded = jsonDecode(data);
    processedData = decoded;
  } else {
    processedData = data;
  }
  
  if (dateKeys != null || autoDetectDates) {
    processedData = _convertDatesInObject(processedData, dateKeys: dateKeys, autoDetectDates: autoDetectDates);
  }
  
  // Transform customAttributes from Map to List for APM network records (web compatibility)
  if (processedData is Map<String, dynamic> && T == APMNetworkRecord) {
    processedData = _transformCustomAttributesForAPM(processedData);
  }
  
  // If a factory function is provided, use it
  if (factory != null && processedData is Map<String, dynamic>) {
    return factory(processedData);
  }
  
  // Auto-detect common types and create instances
  if (processedData is Map<String, dynamic>) {
    return _createInstanceFromMap<T>(processedData);
  }
  
  return processedData as T;
}

/// Creates an instance of type T from a Map based on the type parameter
T _createInstanceFromMap<T>(Map<String, dynamic> map) {
  if (T == DataroidConfig) {
    return DataroidConfig.fromJson(map) as T;
  }

  if (T == ScreenTracker) {
    return ScreenTracker.fromJson(map) as T;
  }

  if (T == User) {
    return User.fromJson(map) as T;
  }

  if (T == APMHTTPRecord) {
    return APMHTTPRecord.fromJson(map) as T;
  }

  if (T == APMNetworkRecord) {
    return APMNetworkRecord.fromJson(map) as T;
  }

  // Commerce Event Classes
  if (T == ViewProductAttributes) {
    return ViewProductAttributes.fromJson(map) as T;
  }

  if (T == SearchAttributes) {
    return SearchAttributes.fromJson(map) as T;
  }

  if (T == AddToCartAttributes) {
    return AddToCartAttributes.fromJson(map) as T;
  }

  if (T == RemoveFromCartAttributes) {
    return RemoveFromCartAttributes.fromJson(map) as T;
  }

  if (T == ClearCartAttributes) {
    return ClearCartAttributes.fromJson(map) as T;
  }

  if (T == StartCheckoutAttributes) {
    return StartCheckoutAttributes.fromJson(map) as T;
  }

  if (T == AddToWishlistAttributes) {
    return AddToWishlistAttributes.fromJson(map) as T;
  }

  if (T == RemoveFromWishlistAttributes) {
    return RemoveFromWishlistAttributes.fromJson(map) as T;
  }

  if (T == ViewCategoryAttributes) {
    return ViewCategoryAttributes.fromJson(map) as T;
  }

  if (T == PurchaseAttributes) {
    return PurchaseAttributes.fromJson(map) as T;
  }

  // Component interaction attributes
  if (T == ButtonClickAttributes) {
    return ButtonClickAttributes.fromJson(map) as T;
  }

  if (T == TextChangeAttributes) {
    return TextChangeAttributes.fromJson(map) as T;
  }

  if (T == ToggleChangeAttributes) {
    return ToggleChangeAttributes.fromJson(map) as T;
  }

  if (T == RadioButtonSelectAttributes) {
    return RadioButtonSelectAttributes.fromJson(map) as T;
  }

  // For other types, just cast the map
  return map as T;
}

/// Recursively converts ISO date strings to DateTime objects in a decoded JSON object
dynamic _convertDatesInObject(dynamic obj, {List<String>? dateKeys, bool autoDetectDates = false}) {
  if (obj is Map<String, dynamic>) {
    final result = <String, dynamic>{};
    for (final entry in obj.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is String) {
        if ((dateKeys?.contains(key) == true) || (autoDetectDates && _isIsoDateString(value))) {
          try {
            result[key] = DateTime.parse(value);
          } catch (e) {
            // If parsing fails, keep the original string value
            result[key] = value;
          }
        } else {
          result[key] = value;
        }
      } else {
        result[key] = _convertDatesInObject(value, dateKeys: dateKeys, autoDetectDates: autoDetectDates);
      }
    }
    return result;
  } else if (obj is List) {
    return obj.map((item) => _convertDatesInObject(item, dateKeys: dateKeys, autoDetectDates: autoDetectDates)).toList();
  }
  
  return obj;
}

/// Checks if a string matches the ISO 8601 date format
bool _isIsoDateString(String value) {
  // Basic regex for ISO 8601 format: YYYY-MM-DDTHH:mm:ss.sssZ or YYYY-MM-DDTHH:mm:ss.sss+HH:mm
  final isoDateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?([+-]\d{2}:\d{2}|Z)$');
  return isoDateRegex.hasMatch(value);
}

/// Formats a DateTime to "yyyy-mm-dd" string format
String formatDateAsYYYYMMDD(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Transforms customAttributes from Map to List format for APM records
/// This handles the web platform where toJSON produces a Map but fromJson expects a List
Map<String, dynamic> _transformCustomAttributesForAPM(Map<String, dynamic> map) {
  final customAttributes = map['customAttributes'];
  
  // If customAttributes is a Map, convert it to List format
  if (customAttributes is Map<String, dynamic>) {
    map['customAttributes'] = customAttributes.entries
        .map((e) => {'key': e.key, 'value': e.value})
        .toList();
  }
  
  return map;
}

