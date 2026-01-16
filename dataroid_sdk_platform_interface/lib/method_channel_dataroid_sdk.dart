import 'dart:async';

import 'package:dataroid_sdk_platform_interface/models/utils.dart';
import 'package:dataroid_sdk_platform_interface/models/screen_tracker.dart';
import 'package:flutter/services.dart';
import 'models/dataroid_config.dart';
import 'models/user.dart';
import 'models/apm_http_record.dart';
import 'models/apm_network_record.dart';
import 'models/button_click_attributes.dart';
import 'models/text_change_attributes.dart';
import 'models/toggle_change_attributes.dart';
import 'models/radio_button_select_attributes.dart';
import 'models/purchase_attributes.dart';
import 'models/search_attributes.dart';
import 'models/add_to_cart_attributes.dart';
import 'models/remove_from_cart_attributes.dart';
import 'models/clear_cart_attributes.dart';
import 'models/start_checkout_attributes.dart';
import 'models/add_to_wishlist_attributes.dart';
import 'models/remove_from_wishlist_attributes.dart';
import 'models/view_category_attributes.dart';
import 'models/view_product_attributes.dart';
import 'models/context_trigger_listener.dart';
import 'models/touch_attributes.dart';
import 'models/double_tap_attributes.dart';
import 'models/long_press_attributes.dart';
import 'models/swipe_attributes.dart';
import 'dataroid_sdk_platform_interface.dart';

const MethodChannel _channel = MethodChannel('dataroid_plugin_flutter');

/// An implementation of [DataroidSdkPlatform] that uses method channels.
class MethodChannelDataroidSdk extends DataroidSdkPlatform {

  @override
  Future<bool> init(DataroidConfig config) async {
    final result = await _channel.invokeMethod<bool>(
      'init',
      {
        'config': safeJsonEncode(config)
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> collectEvent(String eventName, Map<String, Object?>? attributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectCustomEvent',
      <String, Object?>{
        'eventName': eventName,
        'attributes': safeJsonEncode(attributes)
      },
    );
    return result ?? false;
  }

  Future<bool> startTracking(ScreenTracker tracker) async {
    final result = await _channel.invokeMethod<bool>(
      'startTracking',
      <String, Object?>{
        'tracker': safeJsonEncode(tracker)
      },
    );
    return result ?? false;
  }

  Future<bool> stopTracking(ScreenTracker tracker) async {
    final result = await _channel.invokeMethod<bool>(
      'stopTracking',
      <String, Object?>{
        'tracker': safeJsonEncode(tracker)
      },
    );
    return result ?? false;
  }

  Future<bool> setUser(User user) async {
    final result = await _channel.invokeMethod<bool>(
      'setUser',
      <String, Object?>{
        'user': safeJsonEncode(user)
      },
    );
    return result ?? false;
  }

  Future<bool> clearUser() async {
    final result = await _channel.invokeMethod<bool>(
      'clearUser',
    );
    return result ?? false;
  }

  Future<bool> setSuperAttribute(String key, Object value) async {
    final Map<String, Object?> arguments = {'key': key};
    
    // Handle DateTime separately for native platforms
    if (value is DateTime) {
      arguments['dateAttributes'] = value.millisecondsSinceEpoch.toDouble();
    } else {
      // Send primitive values directly without JSON encoding
      arguments['value'] = value;
    }
    
    final result = await _channel.invokeMethod<bool>(
      'setSuperAttribute',
      arguments,
    );
    return result ?? false;
  }

  Future<bool> clearSuperAttribute(String key) async {
    final result = await _channel.invokeMethod<bool>(
      'clearSuperAttribute',
      <String, Object?>{
        'key': key
      },
    );
    return result ?? false;
  }

  Future<bool> httpCall(APMHTTPRecord httpRecord) async {
    final result = await _channel.invokeMethod<bool>(
      'httpCall',
      <String, Object?>{
        'httpRecord': safeJsonEncode(httpRecord)
      },
    );
    return result ?? false;
  }

  Future<bool> networkError(APMNetworkRecord networkRecord) async {
    final result = await _channel.invokeMethod<bool>(
      'networkError',
      <String, Object?>{
        'networkRecord': safeJsonEncode(networkRecord)
      },
    );
    return result ?? false;
  }

  Future<bool> collectButtonClick(ButtonClickAttributes buttonClickAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectButtonClickEvent',
      <String, Object?>{
        'buttonClickAttributes': safeJsonEncode(buttonClickAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> collectTextChange(TextChangeAttributes textChangeAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectTextChangeEvent',
      <String, Object?>{
        'textChangeAttributes': safeJsonEncode(textChangeAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> collectToggleChange(ToggleChangeAttributes toggleChangeAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectToggleChangeEvent',
      <String, Object?>{
        'toggleChangeAttributes': safeJsonEncode(toggleChangeAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> collectRadioButtonSelect(RadioButtonSelectAttributes radioButtonSelectAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectRadioButtonSelectEvent',
      <String, Object?>{
        'radioButtonSelectAttributes': safeJsonEncode(radioButtonSelectAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> purchase(PurchaseAttributes purchaseAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'purchase',
      <String, Object?>{
        'purchaseAttributes': safeJsonEncode(purchaseAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> search(SearchAttributes searchAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'search',
      <String, Object?>{
        'searchAttributes': safeJsonEncode(searchAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> addToCart(AddToCartAttributes addToCartAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'addToCart',
      <String, Object?>{
        'addToCartAttributes': safeJsonEncode(addToCartAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> removeFromCart(RemoveFromCartAttributes removeFromCartAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'removeFromCart',
      <String, Object?>{
        'removeFromCartAttributes': safeJsonEncode(removeFromCartAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> clearCart(ClearCartAttributes clearCartAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'clearCart',
      <String, Object?>{
        'clearCartAttributes': safeJsonEncode(clearCartAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> startCheckout(StartCheckoutAttributes startCheckoutAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'startCheckout',
      <String, Object?>{
        'startCheckoutAttributes': safeJsonEncode(startCheckoutAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> addToWishList(AddToWishlistAttributes addToWishlistAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'addToWishList',
      <String, Object?>{
        'addToWishlistAttributes': safeJsonEncode(addToWishlistAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> removeFromWishList(RemoveFromWishlistAttributes removeFromWishlistAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'removeFromWishList',
      <String, Object?>{
        'removeFromWishlistAttributes': safeJsonEncode(removeFromWishlistAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> viewCategory(ViewCategoryAttributes viewCategoryAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'viewCategory',
      <String, Object?>{
        'viewCategoryAttributes': safeJsonEncode(viewCategoryAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> viewProduct(ViewProductAttributes viewProductAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'viewProduct',
      <String, Object?>{
        'viewProductAttributes': safeJsonEncode(viewProductAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> updateLanguage(String languageCode) async {
    final result = await _channel.invokeMethod<bool>(
      'updateLanguage',
      <String, Object?>{
        'languageCode': languageCode
      },
    );
    return result ?? false;
  }

  Future<bool> setContextTriggerListener(ContextTriggerListener listener) async {
    final result = await _channel.invokeMethod<bool>(
      'setContextTriggerListener',
    );
    return result ?? false;
  }

  Future<bool> removeContextTriggerListener() async {
    final result = await _channel.invokeMethod<bool>(
      'removeContextTriggerListener',
    );
    return result ?? false;
  }

  // Screen Interaction methods
  Future<bool> collectTouch(TouchAttributes touchAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectTouch',
      <String, Object?>{
        'touchAttributes': safeJsonEncode(touchAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> collectDoubleTap(DoubleTapAttributes doubleTapAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectDoubleTap',
      <String, Object?>{
        'doubleTapAttributes': safeJsonEncode(doubleTapAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> collectLongPress(LongPressAttributes longPressAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectLongPress',
      <String, Object?>{
        'longPressAttributes': safeJsonEncode(longPressAttributes)
      },
    );
    return result ?? false;
  }

  Future<bool> collectSwipe(SwipeAttributes swipeAttributes) async {
    final result = await _channel.invokeMethod<bool>(
      'collectSwipe',
      <String, Object?>{
        'swipeAttributes': safeJsonEncode(swipeAttributes)
      },
    );
    return result ?? false;
  }

  // iOS Dedicated Config API Methods

  @override
  Future<bool> updateSessionConfig(double sessionDropDuration) async {
    final result = await _channel.invokeMethod<bool>(
      'updateSessionConfig',
      <String, Object?>{
        'sessionDropDuration': sessionDropDuration,
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> updateInAppConfig(bool inAppMessagingEnabled) async {
    final result = await _channel.invokeMethod<bool>(
      'updateInAppConfig',
      <String, Object?>{
        'inAppMessagingEnabled': inAppMessagingEnabled,
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> updateApmConfig({bool? recordCollectionEnabled, bool? apmAutoCaptureEnabled, int? recordStorageLimit}) async {
    final result = await _channel.invokeMethod<bool>(
      'updateApmConfig',
      <String, Object?>{
        if (recordCollectionEnabled != null) 'recordCollectionEnabled': recordCollectionEnabled,
        if (apmAutoCaptureEnabled != null) 'apmAutoCaptureEnabled': apmAutoCaptureEnabled,
        if (recordStorageLimit != null) 'recordStorageLimit': recordStorageLimit,
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> updateScreenTrackingConfig(bool enabled) async {
    final result = await _channel.invokeMethod<bool>(
      'updateScreenTrackingConfig',
      <String, Object?>{
        'enabled': enabled,
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> setEventCollectionEnabled(bool enabled) async {
    final result = await _channel.invokeMethod<bool>(
      'setEventCollectionEnabled',
      <String, Object?>{
        'enabled': enabled,
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> setEventStorageLimit(int limit) async {
    final result = await _channel.invokeMethod<bool>(
      'setEventStorageLimit',
      <String, Object?>{
        'limit': limit,
      },
    );
    return result ?? false;
  }

  @override
  Future<bool> logExternal(int logLevel, String source, String message) async {
    final result = await _channel.invokeMethod<bool>(
      'logExternal',
      <String, Object?>{
        'logLevel': logLevel,
        'logSource': source,
        'logMessage': message,
      },
    );
    return result ?? false;
  }

}