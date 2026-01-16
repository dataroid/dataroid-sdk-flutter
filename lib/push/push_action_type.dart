/*
 * 
 * push_action_type.dart
 * Dataroid-Plugin-Flutter
 * 
 * Created on 10/12/2024.
 * Copyright (c) 2020 Dataroid. All rights reserved.
 * 
 * Save to the extent permitted by law, you may not use, copy, modify,
 * distribute or create derivative works of this material or any part
 * of it without the prior written consent of Dataroid.
 * Any reproduction of this material must contain this notice.
 * 
 */

/// Enum representing the type of action for a push notification.
///
/// This enum defines the action type that should be performed when a push notification is tapped.
/// It is used in [DataroidPluginFlutterDelegate.handlePushEvent] to determine how to handle
/// the notification interaction.
///
/// Available action types:
/// * [nothing] - No action should be taken
/// * [openApp] - Open the application
/// * [goToUrl] - Navigate to a URL
/// * [goToDeeplink] - Navigate to a deeplink
/// * [custom] - Custom action (Android only)
enum PushActionType {
  /// No action should be taken when the notification is tapped
  nothing,
  
  /// Open the application when the notification is tapped
  openApp,
  
  /// Navigate to a URL when the notification is tapped
  goToUrl,
  
  /// Navigate to a deeplink when the notification is tapped
  goToDeeplink,
  
  /// Custom action defined by the application (Android only)
  custom
}

