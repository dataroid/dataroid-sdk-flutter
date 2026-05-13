/*
 * 
 * user.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 27/11/2020.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';

class ScreenTracker {
  final String label;
  final String viewClass;
  final Map<String, dynamic> attributes;
  final String? url;
  Map<String, int>? _dateAttributes = {};
  Map<String, List<int>>? _intListAttributes = {};
  Map<String, List<String>>? _stringListAttributes = {};

  ScreenTracker({
    required this.label,
    required this.viewClass,
    this.attributes = const {},
    this.url,
  });

  factory ScreenTracker.fromJson(Map<String, dynamic> json) {
    final attributes =
        Map<String, dynamic>.from(json[ArgumentName.attributes] ?? {});

    // Reconstruct DateTime attributes from milliseconds
    final dateAttributes =
        json[ArgumentName.dateAttributes] as Map<String, dynamic>?;
    if (dateAttributes != null) {
      dateAttributes.forEach((key, value) {
        if (value is int) {
          attributes[key] =
              DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
        }
      });
    }

    // Reconstruct List<int> attributes
    final intListAttributes =
        json[ArgumentName.intListAttributes] as Map<String, dynamic>?;
    if (intListAttributes != null) {
      intListAttributes.forEach((key, value) {
        if (value is List) {
          attributes[key] = List<int>.from(value);
        }
      });
    }

    // Reconstruct List<String> attributes
    final stringListAttributes =
        json[ArgumentName.stringListAttributes] as Map<String, dynamic>?;
    if (stringListAttributes != null) {
      stringListAttributes.forEach((key, value) {
        if (value is List) {
          attributes[key] = List<String>.from(value);
        }
      });
    }

    return ScreenTracker(
      label: json[ArgumentName.label] ?? '',
      viewClass: json[ArgumentName.viewClass] ?? '',
      attributes: attributes,
      url: json[ArgumentName.url],
    );
  }

  Map<String, dynamic> get toJSON {
    final parsedAttributes = _parseAttributes();
    return {
      ArgumentName.label: label,
      ArgumentName.viewClass: viewClass,
      ArgumentName.attributes: parsedAttributes,
      ArgumentName.dateAttributes: _dateAttributes,
      ArgumentName.intListAttributes: _intListAttributes,
      ArgumentName.stringListAttributes: _stringListAttributes,
      ArgumentName.url: url,
    };
  }

  Map<String, dynamic> _parseAttributes() {
    _dateAttributes = {};
    _intListAttributes = {};
    _stringListAttributes = {};
    final parsedAttributes = Map<String, dynamic>.from(attributes);

    attributes.entries.forEach((e) {
      if (e.value is DateTime) {
        final value = e.value as DateTime;
        // _dateAttributes is currently encoded as an integer (milliseconds since epoch).
        // However, the fromJson method expects an ISO string and preserves the timezone.
        // TODO: Update this logic when refactoring to ensure consistency.
        _dateAttributes?[e.key] = value.millisecondsSinceEpoch;
      } else if (e.value is List<int>) {
        final value = e.value as List<int>;
        _intListAttributes?[e.key] = value;
      } else if (e.value is List<String>) {
        final value = e.value as List<String>;
        _stringListAttributes?[e.key] = value;
      }
    });
    parsedAttributes.removeWhere((key, value) =>
        value is DateTime || value is List<int> || value is List<String>);
    return parsedAttributes;
  }

  @override
  String toString() => 'ScreenTracker(label: $label, viewClass: $viewClass'
      '${url != null ? ', url: ${_redactedUrl(url!)}' : ''}'
      '${attributes.isNotEmpty ? ', attributeCount: ${attributes.length}' : ''})';

  /// Returns a privacy-safe representation of [value] for logging.
  ///
  /// Drops query, fragment, and path entirely to avoid leaking session tokens,
  /// reset tokens, identifiers, or other PII commonly carried in URLs.
  static String _redactedUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return '[INVALID_URL]';
    }
    if (!uri.hasScheme || uri.host.isEmpty) {
      return '[REDACTED]';
    }
    final scheme = uri.scheme.toLowerCase();
    final isDefaultPort = (scheme == 'http' && uri.port == 80) ||
        (scheme == 'https' && uri.port == 443);
    return Uri(
      scheme: scheme,
      host: uri.host,
      port: (uri.hasPort && !isDefaultPort) ? uri.port : null,
    ).toString();
  }
}
