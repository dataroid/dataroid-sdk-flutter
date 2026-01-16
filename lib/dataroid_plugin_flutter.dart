import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:dataroid_sdk_platform_interface/models/apm_http_record.dart';
import 'package:dataroid_sdk_platform_interface/models/apm_network_record.dart';
import 'package:dataroid_sdk_platform_interface/models/add_to_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/add_to_wishlist_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/clear_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/purchase_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/remove_from_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/remove_from_wishlist_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/search_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/start_checkout_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/view_category_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/view_product_attributes.dart';

// Screen Interaction imports
import 'package:dataroid_sdk_platform_interface/models/touch_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/double_tap_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/long_press_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/swipe_attributes.dart';

import 'package:dataroid_sdk_platform_interface/models/text_change_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/toggle_change_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/button_click_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/radio_button_select_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/background_push_data.dart';
import 'package:dataroid_sdk_platform_interface/constants.dart';
import 'package:dataroid_sdk_platform_interface/models/context_trigger_listener.dart';
import 'package:dataroid_sdk_platform_interface/models/context_trigger_result.dart';
import 'package:dataroid_plugin_flutter/dataroid_plugin_config.dart';
import 'package:dataroid_plugin_flutter/deeplink_referral/deeplink_attributes.dart';
import 'package:dataroid_plugin_flutter/inbox/inbox_message.dart';
import 'package:dataroid_plugin_flutter/inbox/inbox_query.dart';
import 'package:dataroid_plugin_flutter/push/inapp_button.dart';
import 'package:dataroid_plugin_flutter/push/push_action_type.dart';
import 'package:dataroid_sdk_platform_interface/models/screen_tracker.dart';
import 'package:dataroid_plugin_flutter/super_attributes/super_attribute.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dataroid_sdk_platform_interface/models/user.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dataroid_sdk_platform_interface/dataroid_sdk_platform_interface.dart';
import 'package:dataroid_sdk_platform_interface/models/custom_event.dart';
import 'package:dataroid_plugin_flutter/logger/dataroid_internal_logger.dart';

export 'package:dataroid_sdk_platform_interface/models/add_to_cart_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/add_to_wishlist_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/apm_http_record.dart';
export 'package:dataroid_sdk_platform_interface/models/background_push_data.dart';
export 'package:dataroid_sdk_platform_interface/models/button_click_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/clear_cart_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/commerce_event.dart';
export 'package:dataroid_sdk_platform_interface/models/component_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/context_trigger_listener.dart';
export 'package:dataroid_sdk_platform_interface/models/context_trigger_result.dart';
export 'package:dataroid_sdk_platform_interface/models/coordinates.dart';
export 'package:dataroid_sdk_platform_interface/models/custom_attribute.dart';
export 'package:dataroid_sdk_platform_interface/models/custom_event.dart';
export 'package:dataroid_sdk_platform_interface/models/dataroid_config.dart';
export 'package:dataroid_sdk_platform_interface/models/product.dart';
export 'package:dataroid_sdk_platform_interface/models/purchase_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/radio_button_select_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/remove_from_cart_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/remove_from_wishlist_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/screen_tracker.dart';
export 'package:dataroid_sdk_platform_interface/models/search_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/start_checkout_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/super_attribute.dart';
export 'package:dataroid_sdk_platform_interface/models/text_change_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/toggle_change_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/user.dart';
export 'package:dataroid_sdk_platform_interface/models/utils.dart';
export 'package:dataroid_sdk_platform_interface/models/view_category_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/view_product_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/apm_network_record.dart';

// Screen Interaction exports
export 'package:dataroid_sdk_platform_interface/models/touch_point.dart';
export 'package:dataroid_sdk_platform_interface/models/swipe_points.dart';
export 'package:dataroid_sdk_platform_interface/models/touch_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/double_tap_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/long_press_attributes.dart';
export 'package:dataroid_sdk_platform_interface/models/swipe_attributes.dart';

// Component Interaction Widgets
export 'package:dataroid_plugin_flutter/component_interaction/dataroid_radio_button.dart';

// Push Notification
export 'package:dataroid_plugin_flutter/push/push_action_type.dart';

/// The delegate interface for Dataroid SDK events
///
/// Create a class and initialize [DatroidPluginFlutter] instance with that.
abstract class DataroidPluginFlutterDelegate {
  void handleInAppMessageDeeplink(String deeplink);

  void handleInApp(String content);

  void handleInAppButtonTap(InAppButton button, String content);

  void handlePushEvent(PushActionType actionType, Map<String, dynamic> attributes);

  bool shouldShowNotificationInForeground(Map<String, dynamic> userInfo);

  void handleBackgroundPushAndroid(Map<String, dynamic> parameters);
}

class DataroidPluginFlutter {
  MethodChannel channel = const MethodChannel('dataroid_plugin_flutter');
  static const MethodChannel _snapshotChannel = MethodChannel('com.dataroid/snapshot');
  DataroidSdkPlatform get sdkChannel => DataroidSdkPlatform.instance;

  DataroidPluginFlutterDelegate? delegate;
  ContextTriggerListener? _contextTriggerListener;

  static final DataroidPluginFlutter _shared = DataroidPluginFlutter._internal();

  factory DataroidPluginFlutter() {
    return _shared;
  }

  DataroidPluginFlutter._internal() {
    channel.setMethodCallHandler(_nativeMethodHandler);
    _snapshotChannel.setMethodCallHandler(_handleSnapshotMethodCall);
  }

  /// Collects custom event
  Future<void> collectCustomEvent(CustomEvent event) async {
    DataroidInternalLogger.debug('collectCustomEvent: called with event=$event');
    if(kIsWeb) {
      await sdkChannel.collectEvent(event.eventName, event.attributes);
    } else {
      await sdkChannel.collectEvent(event.eventName, event.toJSON);
    }
  }

  /// Sets the [user] as current SDK user.
  Future<void> setUser(
    User user,
  ) async {
    DataroidInternalLogger.debug('setUser: called with user=$user');
    await sdkChannel.setUser(user);
  }

  /// Clears current user information.
  Future<void> clearUser() async {
    DataroidInternalLogger.debug('clearUser: called');
    await sdkChannel.clearUser();
  }

  /// Collects HTTP Record event.
  Future<void> collectAPMHTTPRecord(APMHTTPRecord record) async {
    DataroidInternalLogger.debug('collectAPMHTTPRecord: called with record=$record');
    await sdkChannel.httpCall(record);
  }

  /// Collects Network Error event.
  Future<void> collectAPMNetworkErrorRecord(APMNetworkRecord record) async {
    DataroidInternalLogger.debug('collectAPMNetworkErrorRecord: called with record=$record');
    await sdkChannel.networkError(record);
  }

  /// Collects add to cart event with given [product].
  Future<void> addToCart(AddToCartAttributes addToCartAttributes) async {
    DataroidInternalLogger.debug('addToCart: called with addToCartAttributes=$addToCartAttributes');
    await sdkChannel.addToCart(addToCartAttributes);
  }

  /// Collects add to wish list with given [product].
  Future<void> addToWishList(AddToWishlistAttributes addToWishlistAttributes) async {
    DataroidInternalLogger.debug('addToWishList: called with addToWishlistAttributes=$addToWishlistAttributes');
    await sdkChannel.addToWishList(addToWishlistAttributes);
  }

  /// Collects clear cart event with given attributes.
  Future<void> clearCart(ClearCartAttributes clearCartAttributes) async {
    DataroidInternalLogger.debug('clearCart: called with clearCartAttributes=$clearCartAttributes');
    await sdkChannel.clearCart(clearCartAttributes);
  }

  /// Collects purchase event with given [products].
  Future<void> purchase(PurchaseAttributes purchaseAttributes) async {
    DataroidInternalLogger.debug('purchase: called with purchaseAttributes=$purchaseAttributes');
    await sdkChannel.purchase(purchaseAttributes);
  }

  /// Collects remove to cart event with given [product].
  Future<void> removeFromCart(RemoveFromCartAttributes removeFromCartAttributes) async {
    DataroidInternalLogger.debug('removeFromCart: called with removeFromCartAttributes=$removeFromCartAttributes');
    await sdkChannel.removeFromCart(removeFromCartAttributes);
  }

  /// Collects remove from wish list event with given [product].
  Future<void> removeFromWishList(RemoveFromWishlistAttributes removeFromWishlistAttributes) async {
    DataroidInternalLogger.debug('removeFromWishList: called with removeFromWishlistAttributes=$removeFromWishlistAttributes');
    await sdkChannel.removeFromWishList(removeFromWishlistAttributes);
  }

  /// Collects search event with given [query].
  Future<void> search(SearchAttributes searchAttributes) async {
    DataroidInternalLogger.debug('search: called with searchAttributes=$searchAttributes');
    await sdkChannel.search(searchAttributes);
  }

  /// Collects start to checkout event.
  Future<void> startCheckout(StartCheckoutAttributes startCheckoutAttributes) async {
    DataroidInternalLogger.debug('startCheckout: called with startCheckoutAttributes=$startCheckoutAttributes');
    await sdkChannel.startCheckout(startCheckoutAttributes);
  }

  /// Collects view [category] event.
  Future<void> viewCategory(ViewCategoryAttributes categoryAttributes) async {
    DataroidInternalLogger.debug('viewCategory: called with categoryAttributes=$categoryAttributes');
    await sdkChannel.viewCategory(categoryAttributes);
  }

  /// Collects view [product] event.
  Future<void> viewProduct(ViewProductAttributes productAttributes) async {
    DataroidInternalLogger.debug('viewProduct: called with productAttributes=$productAttributes');
    await sdkChannel.viewProduct(productAttributes);
  }

  /// Triggers Dataroid's FCM MessageReceived class. Android only.
  Future<bool> pushMessageReceived(Map<String, String> data) async {
    DataroidInternalLogger.debug('pushMessageReceived: called with data=$data');
    if(Platform.isAndroid) {
      try {
        var result = await channel.invokeMethod(MethodName.pushMessageReceived, data);
        DataroidInternalLogger.debug('pushMessageReceived: completed with result=$result');
        return result;
      } catch (e) {
        DataroidInternalLogger.error('pushMessageReceived: failed with error: $e');
        return false;
      }
    }
    DataroidInternalLogger.debug('pushMessageReceived: skipped (not Android)');
    return false;
  }


  /// Updates the current language.
  ///
  /// [languageCode] is the language code to set for the SDK.
  Future<void> updateLanguage({
    required String languageCode,
  }) async {
    DataroidInternalLogger.debug('updateLanguage: called with languageCode=$languageCode');
    await sdkChannel.updateLanguage(languageCode);
  }

  /// Enables geofencing feature. Permission requests must be handled by host application.
  Future<void> enableGeofencing() async {
    DataroidInternalLogger.debug('enableGeofencing: called');
    await channel.invokeMethod(MethodName.enableGeofencing);
  }

  /// Disables geofencing feature.
  Future<void> disableGeofencing() async {
    DataroidInternalLogger.debug('disableGeofencing: called');
    await channel.invokeMethod(MethodName.disableGeofencing);
  }

  /// Collects deeplink events.
  ///
  /// Host app must call this when the application routes to a deeplink.
  Future<void> collectDeeplink(DeeplinkAttributes deeplinkAttributes) async {
    DataroidInternalLogger.debug('collectDeeplink: called with deeplinkAttributes=$deeplinkAttributes');
    await channel.invokeMethod(MethodName.collectDeeplink, deeplinkAttributes.toJSON);
  }

  /// Starts tracking the page with given [name] and [label].
  Future<void> startTracking(ScreenTracker tracker) async {
    DataroidInternalLogger.debug('startTracking: called with tracker=$tracker');
    await sdkChannel.startTracking(tracker);
  }

  /// Stops tracking the page with given [name] and [label].
  Future<void> stopTracking(ScreenTracker tracker) async {
    DataroidInternalLogger.debug('stopTracking: called with tracker=$tracker');
    await sdkChannel.stopTracking(tracker);
  }

  /// [iOS] Requests authorization from user to present notifications.
  Future<void> requestNotificationAuthorization() async {
    DataroidInternalLogger.debug('requestNotificationAuthorization: called');
    await channel.invokeMethod(MethodName.requestNotificationAuthorizationiOS);
  }

  /// [Android] Enables push notifications.
  Future<void> enablePush() async {
    DataroidInternalLogger.debug('enablePush: called');
    await channel.invokeMethod(MethodName.enablePush);
  }

  /// Retrieves inbox messages from database with an optional [query].
  Future<List<InboxMessage>> fetchMessages({
    InboxQuery? query,
  }) async {
    DataroidInternalLogger.debug('fetchMessages: called with query=$query');
    if (Platform.isIOS) {
      final messages = await channel.invokeMethod(
        MethodName.fetchMessages,
        query?.toJSON,
      );
      final result = List<InboxMessage>.from(
        messages.map((e) {
          try {
            return InboxMessage(e as Map<dynamic, dynamic>);
          } catch (error) {
            DataroidInternalLogger.error('fetchMessages: error creating InboxMessage: $error');
            return null;
          }
        }).where((message) => message != null),
      );
      DataroidInternalLogger.debug('fetchMessages: completed with ${result.length} messages');
      return result;
    } else if (Platform.isAndroid) {
      final messagesString = await channel.invokeMethod(
        MethodName.fetchMessages,
        query?.toJSON,
      );
      try {
        final List<dynamic> messageList = json.decode(messagesString);
        final result = messageList.map((e) => InboxMessage(e as Map<dynamic, dynamic>)).toList();
        DataroidInternalLogger.debug('fetchMessages: completed with ${result.length} messages');
        return result;
      } catch (e) {
        DataroidInternalLogger.error('fetchMessages: error decoding inbox messages: $e');
        return [];
      }
    } else {
      DataroidInternalLogger.error('fetchMessages: unsupported platform');
      throw PlatformException(
        code: "PlatformException",
        message: "Unsupported platform!",
      );
    }
  }

  /// Deletes inbox messages associated with given IDs.
  Future<bool> deleteMessages(List<String> messageIDs) async {
    DataroidInternalLogger.debug('deleteMessages: called with ${messageIDs.length} message IDs');
    final result = await channel.invokeMethod(MethodName.deleteMessages, {
      ArgumentName.messageIDList: messageIDs,
    });
    DataroidInternalLogger.debug('deleteMessages: completed with result=$result');
    return result;
  }

  /// Marks inbox messages associated with given IDs as read.
  Future<bool> readMessages(List<String> messageIDs) async {
    DataroidInternalLogger.debug('readMessages: called with ${messageIDs.length} message IDs');
    final result = await channel.invokeMethod(MethodName.readMessages, {
      ArgumentName.messageIDList: messageIDs,
    });
    DataroidInternalLogger.debug('readMessages: completed with result=$result');
    return result;
  }

  /// Sets or updates the [superAttribute].
  Future<void> setSuperAttribute(
    SuperAttribute superAttribute,
  ) async {
    DataroidInternalLogger.debug('setSuperAttribute: called with superAttribute=$superAttribute');
    if (kIsWeb) {
      await sdkChannel.setSuperAttribute(superAttribute.key, superAttribute.value);
    } else {
      await channel.invokeMethod(
        MethodName.setSuperAttribute,
        superAttribute.toJSON,
      );
    }
  }

  /// Clears the super attribute with the given [key].
  Future<void> clearSuperAttribute(
    String key,
  ) async {
    DataroidInternalLogger.debug('clearSuperAttribute: called with key=$key');
    await sdkChannel.clearSuperAttribute(key);
  }

  /// Gets all super attributes.
  Future<Map<String, dynamic>> getAllSuperAttributes() async {
    DataroidInternalLogger.debug('getAllSuperAttributes: called');
    final result = await channel.invokeMethod(MethodName.getAllSuperAttributes);
    final attributes = Map<String, dynamic>.from(result ?? {});
    DataroidInternalLogger.debug('getAllSuperAttributes: completed with ${attributes.length} attributes');
    return attributes;
  }

  /// Clears all super attributes.
  Future<void> clearAllSuperAttributes() async {
    DataroidInternalLogger.debug('clearAllSuperAttributes: called');
    await channel.invokeMethod(MethodName.clearAllSuperAttributes);
  }

  /// Collects the [buttonClickEvent].
  Future<void> collectButtonClick(ButtonClickAttributes buttonClickAttributes) async {
    DataroidInternalLogger.debug('collectButtonClick: called with buttonClickAttributes=$buttonClickAttributes');
    await sdkChannel.collectButtonClick(buttonClickAttributes);
  }

  /// Collects the [textChangeEvent].
  Future<void> collectTextChange(TextChangeAttributes textChangeAttributes) async {
    DataroidInternalLogger.debug('collectTextChange: called with textChangeAttributes=$textChangeAttributes');
    await sdkChannel.collectTextChange(textChangeAttributes);
  }

  /// Collects the [toggleChangeEvent].
  Future<void> collectToggleChange(ToggleChangeAttributes toggleChangeAttributes) async {
    DataroidInternalLogger.debug('collectToggleChange: called with toggleChangeAttributes=$toggleChangeAttributes');
    await sdkChannel.collectToggleChange(toggleChangeAttributes);
  }

  /// Collects the [radioButtonSelectEvent].
  Future<void> collectRadioButtonSelect(RadioButtonSelectAttributes radioButtonSelectAttributes) async {
    DataroidInternalLogger.debug('collectRadioButtonSelect: called with radioButtonSelectAttributes=$radioButtonSelectAttributes');
    await sdkChannel.collectRadioButtonSelect(radioButtonSelectAttributes);
  }

  // Screen Interaction methods (only for iOS and Android)

  /// Collects touch event with given [touchAttributes].
  /// Note: Screen interaction is only supported on iOS and Android platforms.
  Future<void> collectTouch(TouchAttributes touchAttributes) async {
    if (kIsWeb) {
      DataroidInternalLogger.warning('collectTouch: skipped (not supported on web)');
      return;
    }
    DataroidInternalLogger.debug('collectTouch: called with touchAttributes=$touchAttributes');
    await channel.invokeMethod(
      MethodName.collectTouchEvent,
      touchAttributes.toJSON,
    );
  }

  /// Collects double tap event with given [doubleTapAttributes].
  /// Note: Screen interaction is only supported on iOS and Android platforms.
  Future<void> collectDoubleTap(DoubleTapAttributes doubleTapAttributes) async {
    if (kIsWeb) {
      DataroidInternalLogger.warning('collectDoubleTap: skipped (not supported on web)');
      return;
    }
    DataroidInternalLogger.debug('collectDoubleTap: called with doubleTapAttributes=$doubleTapAttributes');
    await channel.invokeMethod(
      MethodName.collectDoubleTapEvent,
      doubleTapAttributes.toJSON,
    );
  }

  /// Collects long press event with given [longPressAttributes].
  /// Note: Screen interaction is only supported on iOS and Android platforms.
  Future<void> collectLongPress(LongPressAttributes longPressAttributes) async {
    if (kIsWeb) {
      DataroidInternalLogger.warning('collectLongPress: skipped (not supported on web)');
      return;
    }
    DataroidInternalLogger.debug('collectLongPress: called with longPressAttributes=$longPressAttributes');
    await channel.invokeMethod(
      MethodName.collectLongPressEvent,
      longPressAttributes.toJSON,
    );
  }

  /// Collects swipe event with given [swipeAttributes].
  /// Note: Screen interaction is only supported on iOS and Android platforms.
  Future<void> collectSwipe(SwipeAttributes swipeAttributes) async {
    if (kIsWeb) {
      DataroidInternalLogger.warning('collectSwipe: skipped (not supported on web)');
      return;
    }
    DataroidInternalLogger.debug('collectSwipe: called with swipeAttributes=$swipeAttributes');
    await channel.invokeMethod(
      MethodName.collectSwipeEvent,
      swipeAttributes.toJSON,
    );
  }

  /// Updates the session configuration
  ///
  /// [sessionDropDuration] The duration in seconds after which a session should be dropped
  Future<void> updateSessionConfig(double sessionDropDuration) async {
    DataroidInternalLogger.debug('updateSessionConfig: called with sessionDropDuration=$sessionDropDuration');
    await sdkChannel.updateSessionConfig(sessionDropDuration);
  }

  /// Updates the in-app messaging configuration
  ///
  /// [inAppMessagingEnabled] Whether in-app messaging is enabled
  Future<void> updateInAppConfig(bool inAppMessagingEnabled) async {
    DataroidInternalLogger.debug('updateInAppConfig: called with inAppMessagingEnabled=$inAppMessagingEnabled');
    await sdkChannel.updateInAppConfig(inAppMessagingEnabled);
  }

  /// Updates the APM (Application Performance Monitoring) configuration
  ///
  /// [recordCollectionEnabled] Whether APM record collection is enabled
  /// [apmAutoCaptureEnabled] Whether APM auto-capture is enabled
  /// [recordStorageLimit] Storage limit for APM records
  Future<void> updateApmConfig({bool? recordCollectionEnabled, bool? apmAutoCaptureEnabled, int? recordStorageLimit}) async {
    DataroidInternalLogger.debug('updateApmConfig: called with recordCollectionEnabled=$recordCollectionEnabled, apmAutoCaptureEnabled=$apmAutoCaptureEnabled, recordStorageLimit=$recordStorageLimit');
    await sdkChannel.updateApmConfig(recordCollectionEnabled: recordCollectionEnabled, apmAutoCaptureEnabled: apmAutoCaptureEnabled, recordStorageLimit: recordStorageLimit);
  }

  /// Updates the screen tracking configuration
  ///
  /// [enabled] Whether screen tracking is enabled
  Future<void> updateScreenTrackingConfig(bool enabled) async {
    DataroidInternalLogger.debug('updateScreenTrackingConfig: called with enabled=$enabled');
    await sdkChannel.updateScreenTrackingConfig(enabled);
  }

  /// Enables or disables event collection
  ///
  /// [enabled] Whether event collection should be enabled
  Future<void> setEventCollectionEnabled(bool enabled) async {
    DataroidInternalLogger.debug('setEventCollectionEnabled: called with enabled=$enabled');
    await sdkChannel.setEventCollectionEnabled(enabled);
  }

  /// Sets the event storage limit
  ///
  /// [limit] The maximum number of events to store
  Future<void> setEventStorageLimit(int limit) async {
    DataroidInternalLogger.debug('setEventStorageLimit: called with limit=$limit');
    await sdkChannel.setEventStorageLimit(limit);
  }

  /// Registers a listener for Context Trigger events
  Future<void> setContextTriggerListener(ContextTriggerListener listener) async {
    DataroidInternalLogger.debug('setContextTriggerListener: called with listener=$listener');
    _contextTriggerListener = listener;
    await sdkChannel.setContextTriggerListener(listener);
  }

  /// Unregisters the Context Trigger listener
  Future<void> removeContextTriggerListener() async {
    DataroidInternalLogger.debug('removeContextTriggerListener: called');
    _contextTriggerListener = null;
    await sdkChannel.removeContextTriggerListener();
  }

  /// Track when user opens a notification created from background push
  /// 
  /// [backgroundPushData] The background push data containing notification details
  Future<void> collectNotificationOpenEvent(BackgroundPushData backgroundPushData) async {
    DataroidInternalLogger.debug('collectNotificationOpenEvent: called with backgroundPushData=$backgroundPushData');
    if (Platform.isAndroid) {
      await channel.invokeMethod(
        MethodName.collectNotificationOpenEvent,
        {ArgumentName.backgroundPushData: backgroundPushData.toMap()},
      );
    } else {
      DataroidInternalLogger.error('collectNotificationOpenEvent: unsupported platform');
      throw UnsupportedError('collectNotificationOpenEvent is only supported on Android platform');
    }
  }

  /// Track when user dismisses a notification created from background push
  /// 
  /// [backgroundPushData] The background push data containing notification details
  Future<void> collectNotificationDismissedEvent(BackgroundPushData backgroundPushData) async {
    DataroidInternalLogger.debug('collectNotificationDismissedEvent: called with backgroundPushData=$backgroundPushData');
    if (Platform.isAndroid) {
      await channel.invokeMethod(
        MethodName.collectNotificationDismissedEvent,
        {ArgumentName.backgroundPushData: backgroundPushData.toMap()},
      );
    } else {
      DataroidInternalLogger.error('collectNotificationDismissedEvent: unsupported platform');
      throw UnsupportedError('collectNotificationDismissedEvent is only supported on Android platform');
    }
  }

  Future<dynamic> _nativeMethodHandler(MethodCall methodCall) async {
    if (delegate == null) {
      print('[DATAROID/FLUTTER] Received native callback, but the delegate is null!');
      return false;
    }
    final args = methodCall.arguments;
    switch (methodCall.method) {
      case MethodName.handleDeeplink:
        final deeplink = args[ArgumentName.deeplink] ?? "";
        delegate?.handleInAppMessageDeeplink(deeplink);
        return true;
      case MethodName.handleInAppButtonTap:
        delegate?.handleInAppButtonTap(
          InAppButton(json.decode(args[ArgumentName.inAppButton])),
          args[ArgumentName.content],
        );
        return true;
      case MethodName.handleInApp:
        delegate?.handleInApp(args[ArgumentName.content]);
        return true;
      case MethodName.handlePushEventAndroid:
        final actionTypeString = args[ArgumentName.actionType] as String;
        final attributesMap = args[ArgumentName.attributes] as Map;
        final attributes = Map<String, dynamic>.from(attributesMap);
        
        // Convert String to PushActionType enum
        PushActionType actionType;
        switch (actionTypeString.toUpperCase()) {
          case 'NOTHING':
            actionType = PushActionType.nothing;
            break;
          case 'OPEN_APP':
            actionType = PushActionType.openApp;
            break;
          case 'GO_TO_URL':
            actionType = PushActionType.goToUrl;
            break;
          case 'DEEPLINK':
          case 'GO_TO_DEEPLINK':
            actionType = PushActionType.goToDeeplink;
            break;
          case 'CUSTOM':
            actionType = PushActionType.custom;
            break;
          default:
            print('[DATAROID/FLUTTER] Unknown action type: $actionTypeString, defaulting to nothing');
            actionType = PushActionType.nothing;
        }
        
        delegate?.handlePushEvent(actionType, attributes);
        return true;
      case MethodName.handlePushEventiOS:
        {
          final actionType = PushActionType.values[args[ArgumentName.pushActionType] as int];
          final targetURL = (args[ArgumentName.pushTargetURL] as String?) ?? "";
          final attributes = args[ArgumentName.pushAttrs] as Map;

          // Convert attributes to Map<String, dynamic> and add targetURL if present
          final convertedAttributes = Map<String, dynamic>.from(attributes);
          if (targetURL.isNotEmpty) {
            convertedAttributes['targetURL'] = targetURL;
          }

          delegate?.handlePushEvent(actionType, convertedAttributes);
          return true;
        }
      case MethodName.shouldShowPushNotificationInForegroundiOS:
        final userInfo = args[ArgumentName.value];
        return delegate?.shouldShowNotificationInForeground(userInfo);
      case MethodName.contextTriggered:
        final contextTriggerId = args[ArgumentName.contextTriggerId];
        final attributes = args[ArgumentName.contextTriggerAttributes];

        final result = ContextTriggerResult(
          contextTriggerId: contextTriggerId,
          attributes: attributes != null ? Map<String, dynamic>.from(attributes) : null,
        );

        // Notify the registered listener if available
        _contextTriggerListener?.onContextTriggered(result);
        break;
      case MethodName.handleBackgroundPush:
        final parameters = args[ArgumentName.parameters] as Map?;
        final backgroundPushParameters = parameters != null ? Map<String, dynamic>.from(parameters) : <String, dynamic>{};
        
        // Handle background push notification
        delegate?.handleBackgroundPushAndroid(backgroundPushParameters);
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }


  static Future<dynamic> _handleSnapshotMethodCall(MethodCall call) async {
    if (call.method == 'takeScreenshot') {
      await Future.delayed(Duration(milliseconds: 200));
      try {
        // 1. Try to get RepaintBoundary from the current active screen
        RenderRepaintBoundary? boundary;

        // Method 1: Try to find the active/focused context
        BuildContext? activeContext;
        
        // First try to get the currently focused context
        final focusedContext = WidgetsBinding.instance.focusManager.primaryFocus?.context;
        if (focusedContext != null) {
          activeContext = focusedContext;
          print('🟡 [SNAPSHOT] Using focused context');
        }
        
        // If no focused context, try to find the navigator's overlay context
        if (activeContext == null) {
          final rootContext = WidgetsBinding.instance.rootElement;
          if (rootContext != null) {
            // Find Navigator's overlay context (where current route is rendered)
            rootContext.visitChildElements((element) {
              if (element.widget is Navigator) {
                // Look for Overlay inside Navigator
                element.visitChildElements((child) {
                  if (child.widget is Overlay) {
                    // Get the top overlay entry (current screen)
                    child.visitChildElements((overlayChild) {
                      if (activeContext == null) {
                        activeContext = overlayChild;
                        print('🟡 [SNAPSHOT] Using overlay context');
                      }
                    });
                  }
                });
              }
            });
          }
        }

        // Method 2: Find RepaintBoundary from the active context
        if (activeContext != null) {
          final renderObject = activeContext!.findRenderObject();
          if (renderObject != null) {
            // First try to find RepaintBoundary by walking down the tree
            void findBoundaryRecursive(RenderObject current) {
              if (boundary != null) return;
              
              if (current is RenderRepaintBoundary) {
                // Check if this boundary has a reasonable size (not just a small widget)
                final size = current.size;
                if (size.width > 100 && size.height > 100) {
                  boundary = current;
                  print('🟡 [SNAPSHOT] Found RepaintBoundary: ${size.width}x${size.height}');
                  return;
                }
              }
              
              current.visitChildren(findBoundaryRecursive);
            }
            
            findBoundaryRecursive(renderObject);
            
            // If no suitable boundary found by going down, try going up
            if (boundary == null) {
              RenderObject? current = renderObject;
              while (current != null) {
                if (current is RenderRepaintBoundary) {
                  final size = current.size;
                  if (size.width > 100 && size.height > 100) {
                    boundary = current;
                    print('🟡 [SNAPSHOT] Found RepaintBoundary (upward): ${size.width}x${size.height}');
                    break;
                  }
                }
                current = current.parent;
              }
            }
          }
        }

        // Method 3: Fallback to finding any suitable RepaintBoundary in the render tree
        if (boundary == null) {
          try {
            // ignore: deprecated_member_use
            final renderView = WidgetsBinding.instance.renderView;

            // Walk through the render tree to find the largest RepaintBoundary
            RenderRepaintBoundary? largestBoundary;
            double largestArea = 0;

            void findLargestBoundaryRecursive(RenderObject renderObject) {
              if (renderObject is RenderRepaintBoundary) {
                final size = renderObject.size;
                final area = size.width * size.height;
                if (area > largestArea && size.width > 100 && size.height > 100) {
                  largestArea = area;
                  largestBoundary = renderObject;
                }
              }
              renderObject.visitChildren(findLargestBoundaryRecursive);
            }

            findLargestBoundaryRecursive(renderView);
            boundary = largestBoundary;
            
            if (boundary != null) {
              print('🟡 [SNAPSHOT] Using largest RepaintBoundary: ${boundary!.size.width}x${boundary!.size.height}');
            }
          } catch (e) {
            // Fallback: try with new renderViews API
            final renderViews = WidgetsBinding.instance.renderViews;
            if (renderViews.isNotEmpty) {
              RenderRepaintBoundary? largestBoundary;
              double largestArea = 0;

              void findLargestBoundaryInView(RenderObject renderObject) {
                if (renderObject is RenderRepaintBoundary) {
                  final size = renderObject.size;
                  final area = size.width * size.height;
                  if (area > largestArea && size.width > 100 && size.height > 100) {
                    largestArea = area;
                    largestBoundary = renderObject;
                  }
                }
                renderObject.visitChildren(findLargestBoundaryInView);
              }

              findLargestBoundaryInView(renderViews.first);
              boundary = largestBoundary;
            }
          }
        }

        // If still no boundary found, create a snapshot of the whole view
        if (boundary == null) {
          print('🔴 [SNAPSHOT] No RepaintBoundary found, sending null');
          await _snapshotChannel
              .invokeMethod('onScreenshotTaken', {'filePath': null});
          return;
        }

        print('🟣 [SNAPSHOT] RepaintBoundary found, capturing image...');

        // Wait a bit to ensure rendering is complete
        await Future.delayed(Duration(milliseconds: 100));

        // 2. Capture the image with high quality
        final ui.Image image = await boundary!.toImage(pixelRatio: 3.0);

        // 3. Convert image to PNG bytes
        final ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) {
          image.dispose();
          await _snapshotChannel
              .invokeMethod('onScreenshotTaken', {'filePath': null});
          return;
        }

        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // 4. Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'snapshots$timestamp.png';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);

        print(
            '🟢 [SNAPSHOT] Image saved: ${file.path} (${pngBytes.length} bytes)');

        // 5. Clean up
        image.dispose();

        // 6. Send file path back to native and handle cleanup if needed
        try {
          final response = await _snapshotChannel
              .invokeMethod('onScreenshotTaken', {'filePath': file.path});
          
          // Check if native side requested cleanup
          if (response is Map && response['cleanup'] == true) {
            print('🧹 [SNAPSHOT] Native requested cleanup, deleting temp file');
            try {
              await file.delete();
              print('🗑️ [SNAPSHOT] Temp file deleted: ${file.path}');
            } catch (deleteError) {
              print('⚠️ [SNAPSHOT] Failed to delete temp file: $deleteError');
            }
          } else if (response is Map && response['success'] == true) {
            print('✅ [SNAPSHOT] Native processed screenshot successfully');
          }
        } catch (e) {
          print('❌ [SNAPSHOT] Failed to send screenshot to native: $e');
          // Clean up file if native communication failed
          try {
            await file.delete();
            print('🧹 [SNAPSHOT] Cleaned up temp file after native communication failure');
          } catch (deleteError) {
            print('⚠️ [SNAPSHOT] Failed to delete temp file after error: $deleteError');
          }
        }
      } catch (e) {
        // On error, send null path to native
        print('🔴 [SNAPSHOT] Flutter snapshot error: $e');
        
        // Clean up any partially created files
        try {
          final tempDir = await getTemporaryDirectory();
          // Clean up any snapshot files that might have been created recently
          final dir = Directory(tempDir.path);
          final files = await dir.list().toList();
          for (final file in files) {
            if (file is File && file.path.contains('snapshots') && file.path.endsWith('.png')) {
              final stat = await file.stat();
              final fileAge = DateTime.now().difference(stat.modified).inMinutes;
              if (fileAge < 1) { // Delete files created within the last minute
                await file.delete();
                print('🧹 [SNAPSHOT] Cleaned up recent snapshot file after error: ${file.path}');
              }
            }
          }
        } catch (cleanupError) {
          print('⚠️ [SNAPSHOT] Error during cleanup: $cleanupError');
        }
        
        await _snapshotChannel
            .invokeMethod('onScreenshotTaken', {'filePath': null});
      }
    }
  }

}
