import 'dart:convert';

/// Result that is triggered when a context trigger condition is met
class ContextTriggerResult {
  /// Unique identifier for the completed context
  final String contextTriggerId;

  /// Key-value pairs from the context
  final Map<String, dynamic>? attributes;

  /// Constructor
  ContextTriggerResult({
    required this.contextTriggerId,
    this.attributes,
  });

  /// Creates a ContextTriggerResult from a JSON map
  factory ContextTriggerResult.fromJson(Map<String, dynamic> json) {
    return ContextTriggerResult(
      contextTriggerId: json['contextTriggerId'] as String,
      attributes: json['attributes'] != null 
          ? Map<String, dynamic>.from(json['attributes']) 
          : null,
    );
  }

  /// Converts the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'contextTriggerId': contextTriggerId,
      'attributes': attributes,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
} 