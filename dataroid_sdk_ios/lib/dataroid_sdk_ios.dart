/// iOS implementation of the Dataroid SDK platform interface.
library dataroid_sdk_ios;

import 'package:flutter/services.dart';
import 'package:dataroid_sdk_platform_interface/dataroid_sdk_platform_interface.dart';

// Import all required models
import 'package:dataroid_sdk_platform_interface/models/dataroid_config.dart';
import 'package:dataroid_sdk_platform_interface/models/screen_tracker.dart';
import 'package:dataroid_sdk_platform_interface/models/user.dart';
import 'package:dataroid_sdk_platform_interface/models/apm_http_record.dart';
import 'package:dataroid_sdk_platform_interface/models/apm_network_record.dart';
import 'package:dataroid_sdk_platform_interface/models/button_click_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/text_change_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/toggle_change_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/radio_button_select_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/purchase_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/search_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/add_to_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/remove_from_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/clear_cart_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/start_checkout_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/add_to_wishlist_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/remove_from_wishlist_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/view_category_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/view_product_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/context_trigger_listener.dart';
import 'package:dataroid_sdk_platform_interface/models/touch_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/double_tap_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/long_press_attributes.dart';
import 'package:dataroid_sdk_platform_interface/models/swipe_attributes.dart';

/// iOS implementation of [DataroidSdkPlatform].
class DataroidSdkIos extends DataroidSdkPlatform {
  /// Registers this class as the default instance of [DataroidSdkPlatform].
  static void registerWith() {
    DataroidSdkPlatform.instance = DataroidSdkIos();
  }

  /// The method channel used to interact with the native platform.
  final MethodChannel _channel = const MethodChannel('dataroid_plugin_flutter');

  @override
  Future<bool> init(DataroidConfig config) async {
    try {
      // iOS init is handled on the native side during app startup
      // This method exists for interface compatibility
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectEvent(String eventName, Map<String, Object?>? attributes) async {
    try {
      await _channel.invokeMethod('collectCustomEvent', {
        'eventName': eventName,
        'attributes': attributes ?? {},
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> startTracking(ScreenTracker tracker) async {
    try {
      await _channel.invokeMethod('startTracking', tracker.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> stopTracking(ScreenTracker tracker) async {
    try {
      await _channel.invokeMethod('stopTracking', tracker.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setUser(User user) async {
    try {
      await _channel.invokeMethod('setUser', user.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearUser() async {
    try {
      await _channel.invokeMethod('clearUser');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setSuperAttribute(String key, Object value) async {
    try {
      await _channel.invokeMethod('setSuperAttribute', {
        'key': key,
        'value': value,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearSuperAttribute(String key) async {
    try {
      await _channel.invokeMethod('clearSuperAttribute', {
        'key': key,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> httpCall(APMHTTPRecord httpRecord) async {
    try {
      await _channel.invokeMethod('collectAPMHTTPRecord', httpRecord.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> networkError(APMNetworkRecord networkRecord) async {
    try {
      await _channel.invokeMethod('collectAPMNetworkErrorRecord', networkRecord.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectButtonClick(ButtonClickAttributes buttonClickAttributes) async {
    try {
      await _channel.invokeMethod('collectButtonClickEvent', buttonClickAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectTextChange(TextChangeAttributes textChangeAttributes) async {
    try {
      await _channel.invokeMethod('collectTextChangeEvent', textChangeAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectToggleChange(ToggleChangeAttributes toggleChangeAttributes) async {
    try {
      await _channel.invokeMethod('collectToggleChangeEvent', toggleChangeAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectRadioButtonSelect(RadioButtonSelectAttributes radioButtonSelectAttributes) async {
    try {
      await _channel.invokeMethod('collectRadioButtonSelectEvent', radioButtonSelectAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> purchase(PurchaseAttributes purchaseAttributes) async {
    try {
      await _channel.invokeMethod('purchase', purchaseAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> search(SearchAttributes searchAttributes) async {
    try {
      await _channel.invokeMethod('search', searchAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> addToCart(AddToCartAttributes addToCartAttributes) async {
    try {
      await _channel.invokeMethod('addToCart', addToCartAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeFromCart(RemoveFromCartAttributes removeFromCartAttributes) async {
    try {
      await _channel.invokeMethod('removeFromCart', removeFromCartAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearCart(ClearCartAttributes clearCartAttributes) async {
    try {
      await _channel.invokeMethod('clearCart', clearCartAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> startCheckout(StartCheckoutAttributes startCheckoutAttributes) async {
    try {
      await _channel.invokeMethod('startCheckout', startCheckoutAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> addToWishList(AddToWishlistAttributes addToWishlistAttributes) async {
    try {
      await _channel.invokeMethod('addToWishList', addToWishlistAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeFromWishList(RemoveFromWishlistAttributes removeFromWishlistAttributes) async {
    try {
      await _channel.invokeMethod('removeFromWishList', removeFromWishlistAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> viewCategory(ViewCategoryAttributes viewCategoryAttributes) async {
    try {
      await _channel.invokeMethod('viewCategory', viewCategoryAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> viewProduct(ViewProductAttributes viewProductAttributes) async {
    try {
      await _channel.invokeMethod('viewProduct', viewProductAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateLanguage(String languageCode) async {
    try {
      await _channel.invokeMethod('updateLanguage', {
        'languageCode': languageCode,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setContextTriggerListener(ContextTriggerListener listener) async {
    try {
      await _channel.invokeMethod('registerContextTriggerListener');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeContextTriggerListener() async {
    try {
      await _channel.invokeMethod('unregisterContextTriggerListener');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectTouch(TouchAttributes touchAttributes) async {
    try {
      await _channel.invokeMethod('collectTouchEvent', touchAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectDoubleTap(DoubleTapAttributes doubleTapAttributes) async {
    try {
      await _channel.invokeMethod('collectDoubleTapEvent', doubleTapAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectLongPress(LongPressAttributes longPressAttributes) async {
    try {
      await _channel.invokeMethod('collectLongPressEvent', longPressAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> collectSwipe(SwipeAttributes swipeAttributes) async {
    try {
      await _channel.invokeMethod('collectSwipeEvent', swipeAttributes.toJSON);
      return true;
    } catch (e) {
      return false;
    }
  }

  // iOS Dedicated Config API Methods

  @override
  Future<bool> updateSessionConfig(double sessionDropDuration) async {
    try {
      await _channel.invokeMethod('updateSessionConfig', {
        'sessionDropDuration': sessionDropDuration,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateInAppConfig(bool inAppMessagingEnabled) async {
    try {
      await _channel.invokeMethod('updateInAppConfig', {
        'inAppMessagingEnabled': inAppMessagingEnabled,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateApmConfig({bool? recordCollectionEnabled, bool? apmAutoCaptureEnabled, int? recordStorageLimit}) async {
    try {
      final args = <String, dynamic>{};
      if (recordCollectionEnabled != null) args['recordCollectionEnabled'] = recordCollectionEnabled;
      if (apmAutoCaptureEnabled != null) args['apmAutoCaptureEnabled'] = apmAutoCaptureEnabled;
      if (recordStorageLimit != null) args['recordStorageLimit'] = recordStorageLimit;
      await _channel.invokeMethod('updateApmConfig', args);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateScreenTrackingConfig(bool enabled) async {
    try {
      await _channel.invokeMethod('updateScreenTrackingConfig', {
        'enabled': enabled,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateComponentInteractionConfig({
    bool? enabled,
    bool? autoCollectingEnabled,
    List<String>? sensitiveViewLabelList,
    List<String>? sensitiveComponentSelectorList,
    int? debounceThreshold,
  }) async {
    try {
      final args = <String, dynamic>{};
      if (enabled != null) args['enabled'] = enabled;
      if (autoCollectingEnabled != null) args['autoCollectingEnabled'] = autoCollectingEnabled;
      // Note: iOS may not support debounceThreshold and sensitive lists at runtime
      if (debounceThreshold != null) args['debounceThreshold'] = debounceThreshold;
      if (sensitiveViewLabelList != null) args['sensitiveViewLabelList'] = sensitiveViewLabelList;
      if (sensitiveComponentSelectorList != null) args['sensitiveComponentSelectorList'] = sensitiveComponentSelectorList;
      await _channel.invokeMethod('updateComponentInteractionConfig', args);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateScreenInteractionConfig({bool? enabled, bool? autoCollectingEnabled}) async {
    try {
      final args = <String, dynamic>{};
      if (enabled != null) args['enabled'] = enabled;
      if (autoCollectingEnabled != null) args['autoCollectingEnabled'] = autoCollectingEnabled;
      await _channel.invokeMethod('updateScreenInteractionConfig', args);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateInboxConfig({bool? enabled, int? storageLimit}) async {
    try {
      final args = <String, dynamic>{};
      if (enabled != null) args['enabled'] = enabled;
      if (storageLimit != null) args['storageLimit'] = storageLimit;
      await _channel.invokeMethod('updateInboxConfig', args);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setEventCollectionEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setEventCollectionEnabled', {
        'enabled': enabled,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setEventStorageLimit(int limit) async {
    try {
      await _channel.invokeMethod('setEventStorageLimit', {
        'limit': limit,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> logExternal(int logLevel, String source, String message) async {
    try {
      await _channel.invokeMethod('logExternal', {
        'logLevel': logLevel,
        'logSource': source,
        'logMessage': message,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}

