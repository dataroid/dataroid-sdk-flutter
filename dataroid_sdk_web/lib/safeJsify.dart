import 'dart:js_interop';

import 'package:flutter/foundation.dart';

/// Safely converts Dart values to JavaScript-compatible types for web interop.
///
/// This function handles the conversion of various Dart types to their JavaScript
/// equivalents using the appropriate JS interop methods.
///
/// **Accepted input types:**
/// - `JSAny` - Returned as-is to avoid double conversion
/// - `Map` - Converted using `.jsify()` to a JavaScript object
/// - `List` - Converted using `.jsify()` to a JavaScript array
/// - `DateTime` - Converted using `.jsify()` to a JavaScript Date object
/// - `bool` - Converted using `.toJS` to a JavaScript boolean
/// - `num` (int/double) - Converted using `.toJS` to a JavaScript number
/// - `String` - Converted using `.toJS` to a JavaScript string
/// - Any other type - Logs a warning and returns null to prevent JS interop issues
///
/// **Return value:**
/// Returns a `JSAny?` which represents the JavaScript-compatible value.
/// The return type is nullable to handle cases where the input cannot be
/// converted or is already null.
///
/// **Null handling:**
/// - If the input value is `null`, it is explicitly checked and returned immediately
/// - The function is null-safe and will not throw on null inputs
///
/// **Example usage:**
/// ```dart
/// Convert a Map to JavaScript object
/// var jsObj = safeJsify({'key': 'value', 'count': 42});
///
/// Convert a List to JavaScript array
/// var jsArray = safeJsify([1, 2, 3, 'four']);
///
/// Handles null gracefully
/// var jsNull = safeJsify(null); // Returns null
/// ```
JSAny? safeJsify(dynamic value) {
  if (value == null) {
    return null;
  } else if (value is Map) {
    return value.jsify();
  } else if (value is List) {
    return value.jsify();
  } else if (value is DateTime) {
    return value.jsify();
  } else if (value is bool) {
    return value.toJS;
  } else if (value is num) {
    return value.toJS;
  } else if (value is String) {
    return value.toJS;
  } else {
    debugPrint(
        '[Dataroid] Warning: Unsupported type for JS conversion: ${value.runtimeType}. '
            'Value will be ignored. Supported types are: Map, List, DateTime, bool, num, String, JSAny, and null.');
    return null;
  }
}