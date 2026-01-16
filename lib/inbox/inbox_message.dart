/*
 * 
 * inbox_message.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 10/12/2020.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

import 'package:dataroid_sdk_platform_interface/constants.dart';
import 'package:dataroid_plugin_flutter/push/push_action_type.dart';

/// Enum representing the type of inbox message
enum InboxMessageType {
  push,    // Push notification
  inApp,   // In-app message
  geofence, // Geofence-triggered message
  actionBased // Action-based message
}

/// Enum representing the status of an inbox message
enum InboxMessageStatus {
  unread,    // Message has not been read
  read,      // Message has been read
  dismissed  // Message has been dismissed
}

/// Class representing an alert in a push notification
class Alert {
  final String? title;
  final String? body;
  
  Alert({this.title, this.body});
  
  factory Alert.fromJson(Map<dynamic, dynamic> json) {
    return Alert(
      title: json['title'] as String?,
      body: json['body'] as String?,
    );
  }
}

/// Class representing a push event in the inbox
class PushEvent {
  final Alert? alert;
  final String? soundName;
  final String? pushId;
  final String? scheduleId;
  final String? mediaURL;
  final String? targetURL;
  final PushActionType? actionType;
  
  PushEvent({
    this.alert,
    this.soundName,
    this.pushId,
    this.scheduleId,
    this.mediaURL,
    this.targetURL,
    this.actionType,
  });
  
  factory PushEvent.fromJson(Map<dynamic, dynamic> json) {
    final actionTypeIndex = json['actionType'] as int?;
    PushActionType? type;
    
    if (actionTypeIndex != null && actionTypeIndex >= 0 && actionTypeIndex < PushActionType.values.length) {
      type = PushActionType.values[actionTypeIndex];
    }
    
    return PushEvent(
      alert: json['alert'] != null ? Alert.fromJson(json['alert'] as Map<dynamic, dynamic>) : null,
      soundName: json['soundName'] as String?,
      pushId: json['pushId'] as String?,
      scheduleId: json['scheduleId'] as String?,
      mediaURL: json['mediaURL'] as String?,
      targetURL: json['targetURL'] as String?,
      actionType: type,
    );
  }
}

/// Class representing content of an in-app message
class InAppMessageContent {
  final String? language;
  final String? title;
  final String? body;
  
  InAppMessageContent({
    this.language,
    this.title,
    this.body,
  });
  
  factory InAppMessageContent.fromJson(Map<dynamic, dynamic> json) {
    return InAppMessageContent(
      language: json['language'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
    );
  }
}

/// Class representing custom content of an in-app message
class InAppMessageCustomContent {
  final String? language;
  final Map<String, dynamic>? content;
  
  InAppMessageCustomContent({
    this.language,
    this.content,
  });
  
  factory InAppMessageCustomContent.fromJson(Map<dynamic, dynamic> json) {
    // Safely convert from Map<dynamic, dynamic> to Map<String, dynamic>
    Map<String, dynamic>? safeContent;
    if (json['content'] != null) {
      safeContent = {};
      (json['content'] as Map<dynamic, dynamic>).forEach((key, value) {
        if (key is String) {
          safeContent![key] = value;
        }
      });
    }
    
    return InAppMessageCustomContent(
      language: json['language'] as String?,
      content: safeContent,
    );
  }
}

/// Class representing an in-app message
class InAppMessage {
  final String? messageId;
  final String? defaultLanguage;
  final List<InAppMessageContent>? contents;
  final List<InAppMessageCustomContent>? customContents;
  
  InAppMessage({
    this.messageId,
    this.defaultLanguage,
    this.contents,
    this.customContents,
  });
  
  factory InAppMessage.fromJson(Map<dynamic, dynamic> json) {
    List<InAppMessageContent>? contentsList;
    if (json['contents'] != null) {
      contentsList = (json['contents'] as List)
          .map((content) => InAppMessageContent.fromJson(content as Map<dynamic, dynamic>))
          .toList();
    }
    
    List<InAppMessageCustomContent>? customContentsList;
    if (json['customContents'] != null) {
      customContentsList = (json['customContents'] as List)
          .map((content) => InAppMessageCustomContent.fromJson(content as Map<dynamic, dynamic>))
          .toList();
    }
    
    return InAppMessage(
      messageId: json['messageId'] as String?,
      defaultLanguage: json['defaultLanguage'] as String?,
      contents: contentsList,
      customContents: customContentsList,
    );
  }
}

/// Class representing content of an action-based message
class ActionBasedContent {
  final String? title;
  final String? text;
  final String? actionType;
  final String? actionTargetUrl;
  final String? imageUrl;
  final Map<String, dynamic>? parameters;
  
  ActionBasedContent({
    this.title,
    this.text,
    this.actionType,
    this.actionTargetUrl,
    this.imageUrl,
    this.parameters,
  });
  
  factory ActionBasedContent.fromJson(Map<dynamic, dynamic> json) {
    // Safely convert from Map<dynamic, dynamic> to Map<String, dynamic>
    Map<String, dynamic>? safeParameters;
    if (json['parameters'] != null) {
      safeParameters = {};
      (json['parameters'] as Map<dynamic, dynamic>).forEach((key, value) {
        if (key is String) {
          safeParameters![key] = value;
        }
      });
    }
    
    return ActionBasedContent(
      title: json['title'] as String?,
      text: json['text'] as String?,
      actionType: json['actionType'] as String?,
      actionTargetUrl: json['actionTargetUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      parameters: safeParameters,
    );
  }
}

/// Class representing an action-based message
class ActionBasedMessage {
  final String? pushId;
  final String? sound;
  final String? defaultLanguage;
  final Alert? alert;
  final String? soundName;
  final String? scheduleId;
  final String? mediaURL;
  final String? targetURL;
  final PushActionType? actionType;
  final Map<dynamic, dynamic>? parameters;

  ActionBasedMessage({
    this.pushId,
    this.sound,
    this.defaultLanguage,
    this.alert,
    this.soundName,
    this.scheduleId,
    this.mediaURL,
    this.targetURL,
    this.actionType,
    this.parameters,
  });

  /// Creates an ActionBasedMessage from JSON data, returns null if parsing fails
  static ActionBasedMessage? parseJson(Map<dynamic, dynamic> json) {
    return ActionBasedMessage(
      pushId: json['pushId'] as String?,
      sound: json['sound'] as String?,
      parameters: json['parameters'] as Map<dynamic, dynamic>?,
      alert: Alert(title: json['title'], body: json['text']),
      mediaURL: json['imageUrl'] as String?,
      targetURL: json['actionTargetUrl'] as String?,
      actionType: PushActionType.values[json['actionTypeIndex'] as int? ?? 0],
    );
  }
}

/// Exception thrown when an action-based message fails to initialize
class ActionBasedMessageInitializationException implements Exception {
  final String message;
  
  ActionBasedMessageInitializationException(this.message);
  
  @override
  String toString() => 'ActionBasedMessageInitializationException: $message';
}

/// Class representing a message in the inbox
class InboxMessage {
  /// The primary key used to store the inbox message in the database
  String? id;
  
  /// The type of message (push, inApp, geofence, actionBased)
  InboxMessageType? type;
  
  /// The date on which the message was received
  DateTime? receivedDate;
  
  /// The date on which the message will expire and be removed from the database
  DateTime? expirationDate;
  
  /// The id of the targeted customer, if applicable
  String? customerId;
  
  /// The status of the message (unread, read, dismissed)
  InboxMessageStatus? status;
  
  /// The payload of the message (used for simple messages)
  String? payload;
  
  /// The push event model (for PUSH-MESSAGE and GEOFENCE type messages)
  PushEvent? pushEvent;
  
  /// The in-app message model (for INAPP-MESSAGE type messages)
  InAppMessage? inAppMessage;
  
  /// The action-based message model (for ACTION-BASED-MESSAGE type messages)
  ActionBasedMessage? actionBasedMessage;

  InboxMessage(Map<dynamic, dynamic> json) {
    // Basic properties parsing
    id = json[ArgumentName.id] as String?;
    
    // Add safety check for messageType to prevent index out of range
    final messageTypeIndex = json[ArgumentName.messageType] as int?;
    if (messageTypeIndex != null && messageTypeIndex >= 0 && messageTypeIndex < InboxMessageType.values.length) {
      type = InboxMessageType.values[messageTypeIndex];
    } else {
      type = InboxMessageType.values[0]; // Default to push
      print('Warning: Invalid messageType index: $messageTypeIndex, defaulting to push');
    }
    
    // Add safety check for messageStatus to prevent index out of range
    final messageStatusIndex = json[ArgumentName.messageStatus] as int?;
    if (messageStatusIndex != null && messageStatusIndex >= 0 && messageStatusIndex < InboxMessageStatus.values.length) {
      status = InboxMessageStatus.values[messageStatusIndex];
    } else {
      status = InboxMessageStatus.values[0]; // Default to unread
      print('Warning: Invalid messageStatus index: $messageStatusIndex, defaulting to unread');
    }
    
    customerId = json[ArgumentName.customerId] as String?;
    
    // Parse dates
    final receivedInterval = _parseDouble(json[ArgumentName.receivedDate]);
    if (receivedInterval != null) {
      receivedDate = DateTime.fromMillisecondsSinceEpoch(receivedInterval.toInt());
    }
    
    final expirationInterval = _parseDouble(json[ArgumentName.expirationDate]);
    if (expirationInterval != null) {
      expirationDate = DateTime.fromMillisecondsSinceEpoch(expirationInterval.toInt());
    }
    
    // Parse simple payload
    payload = json[ArgumentName.payload] as String?;
    
    // Parse nested models based on message type
    if (type != null) {
      switch (type) {
        case InboxMessageType.push:
        case InboxMessageType.geofence:
          if (json['pushEvent'] != null) {
            try {
              pushEvent = PushEvent.fromJson(json['pushEvent'] as Map<dynamic, dynamic>);
            } catch (e) {
              print('Error parsing pushEvent: $e');
            }
          }
          break;
        case InboxMessageType.inApp:
          if (json['inAppMessage'] != null) {
            try {
              inAppMessage = InAppMessage.fromJson(json['inAppMessage'] as Map<dynamic, dynamic>);
            } catch (e) {
              print('Error parsing inAppMessage: $e');
            }
          }
          break;
        case InboxMessageType.actionBased:
          _parseActionBasedMessage(json);
          break;
        default:
          break;
      }
    }
  }
  
  /// Helper method to parse action-based messages
  void _parseActionBasedMessage(Map<dynamic, dynamic> json) {
    try {
      
      // Then try to parse actionBasedMessage if it exists
      if (json['actionBasedMessage'] != null) {
        actionBasedMessage = ActionBasedMessage.parseJson(json['actionBasedMessage'] as Map<dynamic, dynamic>);
      } else {
        // If actionBasedMessage is null, we should not initialize this InboxMessage
        throw ActionBasedMessageInitializationException('Failed to initialize ActionBasedMessage from provided JSON');
      }

    } catch (e) {
      print('Error parsing action-based message: $e');
      throw e; // Re-throw the exception to prevent initialization
    }
  }
  
  /// Helper method to safely parse a double value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    
    if (value is double) return value;
    if (value is int) return value.toDouble();
    
    return double.tryParse(value.toString());
  }
}
