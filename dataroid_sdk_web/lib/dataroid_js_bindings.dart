import 'dart:js_interop';

@JS('dataroid')
@staticInterop
class DataroidJSBinding {

  external static void init(String sdkKey, String endpoint, String version, String appPackageName, JSAny? customConfigs);
  external static void track(String eventName, JSAny? data);
  external static void pageView(String viewLabel, JSAny? extras, String? url);
  external static void setUserProfile(JSAny? user);
  external static void clearUserProfile();
  external static void setSuperAttribute(String key, JSAny value);
  external static void clearSuperAttribute(String key);
}

@JS('dataroid.apm')
@staticInterop
class DataroidAPMBinding {
  external static JSAny createHttpCall(String url, String method, int? status, int? duration, String? connectionType, bool? success);
  external static void sendHttpCallEvent(JSAny httpCall);
  external static JSAny createNetworkError(String url, String? method, int? duration, String? errorType, String? exception);
  external static void sendNetworkErrorEvent(JSAny networkError);
}

@JS('dataroid.apm.HTTP_METHODS')
@staticInterop
external JSObject get httpMethods;

@JS('dataroid.apm.HTTP_CALL_CONNECTION_TYPES')
@staticInterop
external JSObject get connectionTypes;

@JS('dataroid.apm.RESOURCE_TYPES')
@staticInterop
external JSObject get resourceTypes;

@JS('dataroid.apm.NETWORK_ERROR_TYPES')
@staticInterop
external JSObject get networkErrorTypes;

@JS('dataroid.componentInteraction')
@staticInterop
class DataroidComponentInteractionBinding {
  external static void buttonClick(
    String elementName,
    String elementType,
    String? elementId,
    String? className,
    JSAny? coordinates,
    String? label,
    String? accessibilityLabel,
    String? href
  );
  
  external static void textChange(
    String elementName,
    String? value,
    String? elementType,
    String? elementId,
    String? className,
    JSAny? coordinates,
    String? placeholder,
    String? accessibilityLabel
  );
  
  external static void toggleChange(
    String elementName,
    bool isChecked,
    String? elementType,
    String? elementId,
    String? className,
    JSAny? coordinates,
    String? label,
    String? accessibilityLabel
  );
  
  external static void radioButtonSelect(
    String elementName,
    String? elementType,
    String? label,
    String? groupName,
    String? elementId,
    String? className,
    JSAny? coordinates,
    String? accessibilityLabel
  );
}

@JS('dataroid.componentInteraction.BUTTON_CLICK_ELEMENT_TYPES')
@staticInterop
external JSObject get buttonClickElementTypes;

@JS('dataroid.componentInteraction.TEXT_CHANGE_ELEMENT_TYPES')
@staticInterop
external JSObject get textChangeElementTypes;

@JS('dataroid.componentInteraction.TOGGLE_CHANGE_ELEMENT_TYPES')
@staticInterop
external JSObject get toggleChangeElementTypes;

@JS('dataroid.componentInteraction.RADIO_BUTTON_SELECT_ELEMENT_TYPES')
@staticInterop
external JSObject get radioButtonSelectElementTypes;

@JS('dataroid.commerceModels')
@staticInterop
class DataroidCommerceModelsBinding {
  external static JSAny createProduct(
    String id,
    String name,
    int quantity,
    double price,
    String currency
  );
  
  external static JSAny createPurchase(
    JSAny? products,
    double value,
    String currency,
    bool success
  );
}

@JS('dataroid.commerceEvents')
@staticInterop
class DataroidCommerceEventsBinding {
  external static void purchase(JSAny purchase, JSAny? extras);
  external static void search(String query, JSAny? extras);
  external static void viewProduct(JSAny product, JSAny? extras);
  external static void viewCategory(String category, JSAny? extras);
  external static void addToCart(JSAny product, double? value, double? totalCartValue, JSAny? extras);
  external static void removeFromCart(JSAny product, double? value, double? totalCartValue, JSAny? extras);
  external static void clearCart(JSAny? extras);
  external static void startCheckout(double value, String currency, int? quantity, JSAny? extras);
  external static void addToWishList(JSAny product, JSAny? extras);
  external static void removeFromWishList(JSAny product, JSAny? extras);
}

@JS('dataroid')
@staticInterop
class DataroidBinding {
  external static void setLanguage(String languageCode);
}

@JS('dataroid')
@staticInterop
class DataroidContextTriggerBinding {
  external static void setContextTriggerCallback(JSFunction callback);
  external static void removeContextTriggerCallback();
}



