import 'dart:async';

import 'models/dataroid_config.dart';
import 'models/screen_tracker.dart';
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
import 'models/background_push_data.dart';
import 'models/touch_attributes.dart';
import 'models/double_tap_attributes.dart';
import 'models/long_press_attributes.dart';
import 'models/swipe_attributes.dart';

import 'method_channel_dataroid_sdk.dart';

/// The interface that implementations of dataroid_sdk must implement.
///
/// Platform implementations that live in a separate package should extend this
/// class rather than implement it as `dataroid_sdk` does not consider newly
/// added methods to be breaking changes. Extending this class (using `extends`)
/// ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by
/// newly added [DataroidSdkPlatform] methods.
abstract class DataroidSdkPlatform {
  /// The default instance of [DataroidSdkPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [DataroidSdkPlatform] when they
  /// register themselves.
  ///
  /// Defaults to [MethodChannelDataroidSdk].
  static DataroidSdkPlatform instance = MethodChannelDataroidSdk();

  Future<bool> init(DataroidConfig config) async {
    return instance.init(config);
  }

  Future<bool> collectEvent(String eventName, Map<String, Object?>? attributes) async {
    return instance.collectEvent(eventName, attributes);
  }

  Future<bool> startTracking(ScreenTracker tracker) async {
    return instance.startTracking(tracker);
  }

  Future<bool> stopTracking(ScreenTracker tracker) async {
    return instance.stopTracking(tracker);
  }

  Future<bool> setUser(User user) async {
    return instance.setUser(user);
  }

  Future<bool> clearUser() async {
    return instance.clearUser();
  }

  Future<bool> setSuperAttribute(String key, Object value) async {
    return instance.setSuperAttribute(key, value);
  }

  Future<bool> clearSuperAttribute(String key) async {
    return instance.clearSuperAttribute(key);
  }

  Future<bool> httpCall(APMHTTPRecord httpRecord) async {
    return instance.httpCall(httpRecord);
  }

  Future<bool> networkError(APMNetworkRecord networkRecord) async {
    return instance.networkError(networkRecord);
  }

  Future<bool> collectButtonClick(ButtonClickAttributes buttonClickAttributes) async {
    return instance.collectButtonClick(buttonClickAttributes);
  }

  Future<bool> collectTextChange(TextChangeAttributes textChangeAttributes) async {
    return instance.collectTextChange(textChangeAttributes);
  }

  Future<bool> collectToggleChange(ToggleChangeAttributes toggleChangeAttributes) async {
    return instance.collectToggleChange(toggleChangeAttributes);
  }

  Future<bool> collectRadioButtonSelect(RadioButtonSelectAttributes radioButtonSelectAttributes) async {
    return instance.collectRadioButtonSelect(radioButtonSelectAttributes);
  }

  Future<bool> purchase(PurchaseAttributes purchaseAttributes) async {
    return instance.purchase(purchaseAttributes);
  }

  Future<bool> search(SearchAttributes searchAttributes) async {
    return instance.search(searchAttributes);
  }

  Future<bool> addToCart(AddToCartAttributes addToCartAttributes) async {
    return instance.addToCart(addToCartAttributes);
  }

  Future<bool> removeFromCart(RemoveFromCartAttributes removeFromCartAttributes) async {
    return instance.removeFromCart(removeFromCartAttributes);
  }

  Future<bool> clearCart(ClearCartAttributes clearCartAttributes) async {
    return instance.clearCart(clearCartAttributes);
  }

  Future<bool> startCheckout(StartCheckoutAttributes startCheckoutAttributes) async {
    return instance.startCheckout(startCheckoutAttributes);
  }

  Future<bool> addToWishList(AddToWishlistAttributes addToWishlistAttributes) async {
    return instance.addToWishList(addToWishlistAttributes);
  }

  Future<bool> removeFromWishList(RemoveFromWishlistAttributes removeFromWishlistAttributes) async {
    return instance.removeFromWishList(removeFromWishlistAttributes);
  }

  Future<bool> viewCategory(ViewCategoryAttributes viewCategoryAttributes) async {
    return instance.viewCategory(viewCategoryAttributes);
  }

  Future<bool> viewProduct(ViewProductAttributes viewProductAttributes) async {
    return instance.viewProduct(viewProductAttributes);
  }

  Future<bool> updateLanguage(String languageCode) async {
    return instance.updateLanguage(languageCode);
  }

  Future<bool> setContextTriggerListener(ContextTriggerListener listener) async {
    return instance.setContextTriggerListener(listener);
  }

  Future<bool> removeContextTriggerListener() async {
    return instance.removeContextTriggerListener();
  }

  // Screen Interaction methods
  Future<bool> collectTouch(TouchAttributes touchAttributes) async {
    return instance.collectTouch(touchAttributes);
  }

  Future<bool> collectDoubleTap(DoubleTapAttributes doubleTapAttributes) async {
    return instance.collectDoubleTap(doubleTapAttributes);
  }

  Future<bool> collectLongPress(LongPressAttributes longPressAttributes) async {
    return instance.collectLongPress(longPressAttributes);
  }

  Future<bool> collectSwipe(SwipeAttributes swipeAttributes) async {
    return instance.collectSwipe(swipeAttributes);
  }

  Future<bool> updateSessionConfig(double sessionDropDuration) async {
    return instance.updateSessionConfig(sessionDropDuration);
  }

  Future<bool> updateInAppConfig(bool inAppMessagingEnabled) async {
    return instance.updateInAppConfig(inAppMessagingEnabled);
  }

  Future<bool> updateApmConfig({bool? recordCollectionEnabled, bool? apmAutoCaptureEnabled, int? recordStorageLimit}) async {
    return instance.updateApmConfig(recordCollectionEnabled: recordCollectionEnabled, apmAutoCaptureEnabled: apmAutoCaptureEnabled, recordStorageLimit: recordStorageLimit);
  }

  Future<bool> updateScreenTrackingConfig(bool enabled) async {
    return instance.updateScreenTrackingConfig(enabled);
  }

  Future<bool> setEventCollectionEnabled(bool enabled) async {
    return instance.setEventCollectionEnabled(enabled);
  }

  Future<bool> setEventStorageLimit(int limit) async {
    return instance.setEventStorageLimit(limit);
  }

  Future<bool> logExternal(int logLevel, String source, String message) async {
    return instance.logExternal(logLevel, source, message);
  }

}
