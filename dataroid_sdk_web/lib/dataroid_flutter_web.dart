import 'dart:async';
import 'dart:js_interop';

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
import 'package:dataroid_sdk_platform_interface/models/context_trigger_result.dart';
import 'package:dataroid_sdk_platform_interface/models/utils.dart';
import 'package:dataroid_sdk_web/dataroid_js_bindings.dart';
import 'package:dataroid_sdk_web/safeJsify.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:dataroid_sdk_platform_interface/dataroid_sdk_platform_interface.dart';


class DataroidSdkPlugin extends DataroidSdkPlatform {
  ContextTriggerListener? _contextTriggerListener;

  static void registerWith(Registrar registrar) {
    //DataroidSdkPlatform.instance = DataroidSdkPlugin();

    final MethodChannel channel = MethodChannel(
        'dataroid_plugin_flutter',
        const StandardMethodCodec(),
        registrar.messenger
    );

    final DataroidSdkPlugin instance = DataroidSdkPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    return callMethod(call);
  }

  Future<bool> callMethod(MethodCall call) async {
    switch (call.method) {
      case 'init':
        // signature must be same with method_channel_dataroid_sdk.dart file
        return init(
            safeJsonDecode<DataroidConfig>(call.arguments["config"])
        );

      case 'collectCustomEvent':
      // parameter names are mapped to the method_channel_dataroid_sdk.dart file
        return collectEvent(
            call.arguments["eventName"],
            safeJsonDecode<Map<String, Object?>>(
                call.arguments["attributes"]
            )
        );

      case 'startTracking':
        // todo date attribute is not supported
        // parameter names are mapped to the method_channel_dataroid_sdk.dart file
        return startTracking(
            safeJsonDecode<ScreenTracker>(call.arguments["tracker"])
        );

      case 'stopTracking':
      // parameter names are mapped to the method_channel_dataroid_sdk.dart file
        return stopTracking(
            safeJsonDecode<ScreenTracker>(call.arguments["tracker"])
        );

      case 'setUser':
      // parameter names are mapped to the method_channel_dataroid_sdk.dart file
        return setUser(
            safeJsonDecode<User>(call.arguments["user"])
        );

      case 'clearUser':
        return clearUser();

      case 'setSuperAttribute':
        // In v4, value is sent directly without JSON encoding
        // For DateTime, it's sent as 'dateAttributes' with milliseconds
        final key = call.arguments["key"];
        if (key == null || key is! String) {
          print('[DATAROID/WEB] setSuperAttribute: invalid key type');
          return Future.value(false);
        }
        
        final dateMs = call.arguments["dateAttributes"];
        final value = call.arguments["value"];
        
        // If dateAttributes exists, it's a DateTime that needs conversion
        if (dateMs != null && dateMs is num) {
          return setSuperAttributeDate(key, dateMs.toDouble());
        } else if (value != null) {
          return setSuperAttribute(key, value);
        } else {
          return Future.value(false);
        }

      case 'clearSuperAttribute':
        return clearSuperAttribute(
            call.arguments["key"]
        );

      case 'clearAllSuperAttributes':
        return clearAllSuperAttributes();

      case 'getAllSuperAttributes':
        print('[DATAROID/WEB] getAllSuperAttributes is not supported on web platform');
        return Future.value(false);

      case 'httpCall':
        return httpCall(
            safeJsonDecode<APMHTTPRecord>(call.arguments["httpRecord"])
        );

      case 'networkError':
        return networkError(
            safeJsonDecode<APMNetworkRecord>(call.arguments["networkRecord"])
        );

      case 'collectButtonClickEvent':
        return collectButtonClick(
            safeJsonDecode<ButtonClickAttributes>(call.arguments["buttonClickAttributes"])
        );

      case 'collectTextChangeEvent':
        return collectTextChange(
            safeJsonDecode<TextChangeAttributes>(call.arguments["textChangeAttributes"])
        );

      case 'collectToggleChangeEvent':
        return collectToggleChange(
            safeJsonDecode<ToggleChangeAttributes>(call.arguments["toggleChangeAttributes"])
        );

      case 'collectRadioButtonSelectEvent':
        return collectRadioButtonSelect(
            safeJsonDecode<RadioButtonSelectAttributes>(call.arguments["radioButtonSelectAttributes"])
        );

      case 'purchase':
        return purchase(
            safeJsonDecode<PurchaseAttributes>(call.arguments["purchaseAttributes"])
        );

      case 'search':
        return search(
            safeJsonDecode<SearchAttributes>(call.arguments["searchAttributes"])
        );

      case 'addToCart':
        return addToCart(
            safeJsonDecode<AddToCartAttributes>(call.arguments["addToCartAttributes"])
        );

      case 'removeFromCart':
        return removeFromCart(
            safeJsonDecode<RemoveFromCartAttributes>(call.arguments["removeFromCartAttributes"])
        );

      case 'clearCart':
        return clearCart(
            safeJsonDecode<ClearCartAttributes>(call.arguments["clearCartAttributes"])
        );

      case 'startCheckout':
        return startCheckout(
            safeJsonDecode<StartCheckoutAttributes>(call.arguments["startCheckoutAttributes"])
        );

      case 'addToWishList':
        return addToWishList(
            safeJsonDecode<AddToWishlistAttributes>(call.arguments["addToWishlistAttributes"])
        );

      case 'removeFromWishList':
        return removeFromWishList(
            safeJsonDecode<RemoveFromWishlistAttributes>(call.arguments["removeFromWishlistAttributes"])
        );

      case 'viewCategory':
        return viewCategory(
            safeJsonDecode<ViewCategoryAttributes>(call.arguments["viewCategoryAttributes"])
        );

      case 'viewProduct':
        return viewProduct(
            safeJsonDecode<ViewProductAttributes>(call.arguments["viewProductAttributes"])
        );

      case 'updateLanguage':
        return updateLanguage(call.arguments["languageCode"] as String);

      case 'setContextTriggerListener':
        return _setContextTriggerListenerWeb();

      case 'removeContextTriggerListener':
        return _removeContextTriggerListenerWeb();

      default:
        return false;
    }
  }

  @override
  Future<bool> init(DataroidConfig config) {

    final customConfigs = {
      'sessionConfig': {
        'timeout': config.session?.timeout,
        'manualManagement': config.session?.manualManagement
      },
      'pageConfig': {
        'enabled': config.screenTracking?.enabled,
        'checkInterval': config.screenTracking?.checkInterval,
        'ignoreQueryParams': config.screenTracking?.ignoreQueryParams,
        'ignoreReferralQueryParams': config.screenTracking?.ignoreQueryParams,
        'screenCapture': {
          'enabled': config.snapshot?.enabled,
          'delay': config.snapshot?.latencyInMillis
        }
      },
      'pushConfig': {
        'enabled': config.push?.enabled,
        'firebaseOptions': config.push?.firebaseOptions
      },
    };


    // todo add error handling for js interop calls
    DataroidJSBinding.init(
        config.sdkKey,
        config.serverURL,
        config.appVersion ?? "Unknown",
        config.appPackageName ?? "Unknown",
        safeJsify(customConfigs)
    );

    return Future<bool>.value(true);
  }

  @override
  Future<bool> collectEvent(String eventName, Map<String, Object?>? attributes) async {
    DataroidJSBinding.track(eventName, safeJsify(attributes));
    return true;
  }

  @override
  Future<bool> startTracking(ScreenTracker tracker) async {
    DataroidJSBinding.pageView(tracker.label, safeJsify(tracker.attributes), tracker.url);
    return true;
  }

  @override
  Future<bool> stopTracking(ScreenTracker tracker) async {
    // since the equivalent api is not available in web, body should empty

    return false; // returning false because something went wrong
  }

  @override
  Future<bool> setUser(User user) async {
    var genderJS = "UNKNOWN";
    switch (user.gender) {
      case Gender.male: genderJS = "MALE"; break;
      case Gender.female: genderJS = "FEMALE"; break;
      case Gender.nonBinary: genderJS = "NON_BINARY"; break;
      default: genderJS = "UNKNOWN"; break;
    }

    final userJS = {
      'cid': user.customerId,
      'email': user.email,
      'phone': user.phone,
      'nid': user.nationalId,
      'fn': user.firstName,
      'ln': user.lastName,
      'gn': genderJS,
      'dob': user.dateOfBirth != null ? formatDateAsYYYYMMDD(user.dateOfBirth!) : null,
      'attributes': safeJsify(user.attributes)
    };

    DataroidJSBinding.setUserProfile(safeJsify(userJS));

    return true;
  }

  @override
  Future<bool> clearUser() async {
    DataroidJSBinding.clearUserProfile();
    return true;
  }

  @override
  Future<bool> setSuperAttribute(String key, Object value) async {
    DataroidJSBinding.setSuperAttribute(key, safeJsify(value)!);
    return true;
  }

  Future<bool> setSuperAttributeDate(String key, double milliseconds) async {
    try {
      // Validate timestamp range to prevent overflow
      // Valid range: ~1970-01-01 to ~2100-01-01
      if (milliseconds < 0 || milliseconds > 4102444800000) {
        print('[DATAROID/WEB] Invalid timestamp value: $milliseconds');
        return false;
      }
      
      // Convert milliseconds to ISO 8601 string for JavaScript Date parsing
      // Using round() instead of toInt() for safer conversion
      final dateString = DateTime.fromMillisecondsSinceEpoch(milliseconds.round()).toIso8601String();
      DataroidJSBinding.setSuperAttribute(key, dateString.toJS);
      return true;
    } catch (e) {
      print('Error setting date super attribute: $e');
      return false;
    }
  }

  @override
  Future<bool> clearSuperAttribute(String key) async {
    DataroidJSBinding.clearSuperAttribute(key);
    return true;
  }

  Future<bool> clearAllSuperAttributes() async {
    DataroidJSBinding.clearAllSuperAttributes();
    return true;
  }

  @override
  Future<bool> httpCall(APMHTTPRecord httpRecord) async {
    // Map HTTP method to JS constant
    String methodJS = httpRecord.method.name;
    
    // Map connection type to JS constant
    String? connectionTypeJS;
    if (httpRecord.connectionType != null) {
      connectionTypeJS = httpRecord.connectionType!.name;
    }
    
    // Create HTTP call using JavaScript API
    final httpCall = DataroidAPMBinding.createHttpCall(
      httpRecord.url,
      methodJS,
      httpRecord.statusCode,
      httpRecord.duration,
      connectionTypeJS,
      httpRecord.success,
    );
    
    // Add additional attributes if provided
    if (httpRecord.requestSize != null) {
      // httpCall.addRequestPayloadSize(httpRecord.requestSize!);
    }
    if (httpRecord.responseSize != null) {
      // httpCall.addResponsePayloadSize(httpRecord.responseSize!);
    }
    if (httpRecord.errorType != null) {
      // httpCall.addErrorType(httpRecord.errorType!);
    }
    if (httpRecord.errorCode != null) {
      // httpCall.addErrorCode(httpRecord.errorCode!);
    }
    if (httpRecord.errorMessage != null) {
      // httpCall.addErrorMessage(httpRecord.errorMessage!);
    }
    if (httpRecord.viewLabel != null) {
      // httpCall.addViewLabel(httpRecord.viewLabel!);
    }
    if (httpRecord.resourceType != null) {
      // httpCall.addResourceType(httpRecord.resourceType!.name);
    }
    
    // Send the HTTP call event
    DataroidAPMBinding.sendHttpCallEvent(httpCall);
    
    return true;
  }

  @override
  Future<bool> networkError(APMNetworkRecord networkRecord) async {
    // Map HTTP method to JS constant
    String methodJS = networkRecord.method.name;
    
    // Map error type to JS constant
    String errorTypeJS;
    // Convert ErrorType enum to corresponding JS constant
    switch (networkRecord.type) {
        case ErrorType.unknown:
          errorTypeJS = 'UNKNOWN_ERROR';
          break;
        case ErrorType.noConnection:
          errorTypeJS = 'NO_CONNECTION_ERROR';
          break;
        case ErrorType.ssl:
          errorTypeJS = 'SSL_ERROR';
          break;
        case ErrorType.timeout:
          errorTypeJS = 'TIMEOUT_ERROR';
          break;
        case ErrorType.authFailure:
          errorTypeJS = 'AUTH_FAILURE_ERROR';
          break;
        case ErrorType.network:
          errorTypeJS = 'NETWORK_ERROR';
          break;
        case ErrorType.parse:
          errorTypeJS = 'PARSE_ERROR';
          break;
        case ErrorType.server:
          errorTypeJS = 'SERVER_ERROR';
          break;
        case ErrorType.cancelled:
          errorTypeJS = 'CANCELLED_ERROR';
          break;
        case ErrorType.insecureConnection:
          errorTypeJS = 'INSECURE_CONNECTION_ERROR';
          break;
      }
    
    // Create network error using JavaScript API
    final networkError = DataroidAPMBinding.createNetworkError(
      networkRecord.url,
      methodJS,
      networkRecord.duration,
      errorTypeJS,
      networkRecord.exception,
    );
    
    // Add additional attributes if provided
    if (networkRecord.message != null) {
      // networkError.addErrorMessage(networkRecord.message!);
    }
    
    // Send the network error event
    DataroidAPMBinding.sendNetworkErrorEvent(networkError);
    
    return true;
  }

  @override
  Future<bool> collectButtonClick(ButtonClickAttributes buttonClickAttributes) async {
    // Convert coordinates to JavaScript format
    final coordinatesJS = buttonClickAttributes.coordinates != null ? {
      'top': buttonClickAttributes.coordinates!.top,
      'right': buttonClickAttributes.coordinates!.right,
      'bottom': buttonClickAttributes.coordinates!.bottom,
      'left': buttonClickAttributes.coordinates!.left,
    } : null;

    DataroidComponentInteractionBinding.buttonClick(
      buttonClickAttributes.elementName ?? 'button',
      buttonClickAttributes.elementType ?? 'BUTTON',
      buttonClickAttributes.componentId,
      buttonClickAttributes.className,
      coordinatesJS != null ? safeJsify(coordinatesJS) : null,
      buttonClickAttributes.label,
      buttonClickAttributes.accessibilityLabel,
      buttonClickAttributes.href,
    );

    return true;
  }

  @override
  Future<bool> collectTextChange(TextChangeAttributes textChangeAttributes) async {
    // Convert coordinates to JavaScript format
    final coordinatesJS = textChangeAttributes.coordinates != null ? {
      'top': textChangeAttributes.coordinates!.top,
      'right': textChangeAttributes.coordinates!.right,
      'bottom': textChangeAttributes.coordinates!.bottom,
      'left': textChangeAttributes.coordinates!.left,
    } : null;

    DataroidComponentInteractionBinding.textChange(
      textChangeAttributes.elementName ?? 'input',
      textChangeAttributes.textValue,
      textChangeAttributes.elementType ?? 'text',
      textChangeAttributes.componentId,
      textChangeAttributes.className,
      coordinatesJS != null ? safeJsify(coordinatesJS) : null,
      textChangeAttributes.placeholder,
      textChangeAttributes.accessibilityLabel,
    );

    return true;
  }

  @override
  Future<bool> collectToggleChange(ToggleChangeAttributes toggleChangeAttributes) async {
    // Convert coordinates to JavaScript format
    final coordinatesJS = toggleChangeAttributes.coordinates != null ? {
      'top': toggleChangeAttributes.coordinates!.top,
      'right': toggleChangeAttributes.coordinates!.right,
      'bottom': toggleChangeAttributes.coordinates!.bottom,
      'left': toggleChangeAttributes.coordinates!.left,
    } : null;

    DataroidComponentInteractionBinding.toggleChange(
      toggleChangeAttributes.elementName ?? 'input',
      toggleChangeAttributes.isChecked,
      toggleChangeAttributes.elementType ?? 'checkbox',
      toggleChangeAttributes.componentId,
      toggleChangeAttributes.className,
      coordinatesJS != null ? safeJsify(coordinatesJS) : null,
      toggleChangeAttributes.label,
      toggleChangeAttributes.accessibilityLabel,
    );

    return true;
  }

  @override
  Future<bool> collectRadioButtonSelect(RadioButtonSelectAttributes radioButtonSelectAttributes) async {
    // Convert coordinates to JavaScript format
    final coordinatesJS = radioButtonSelectAttributes.coordinates != null ? {
      'top': radioButtonSelectAttributes.coordinates!.top,
      'right': radioButtonSelectAttributes.coordinates!.right,
      'bottom': radioButtonSelectAttributes.coordinates!.bottom,
      'left': radioButtonSelectAttributes.coordinates!.left,
    } : null;

    DataroidComponentInteractionBinding.radioButtonSelect(
      radioButtonSelectAttributes.elementName ?? 'input',
      radioButtonSelectAttributes.elementType ?? 'radio',
      radioButtonSelectAttributes.label,
      radioButtonSelectAttributes.groupName,
      radioButtonSelectAttributes.componentId,
      radioButtonSelectAttributes.className,
      coordinatesJS != null ? safeJsify(coordinatesJS) : null,
      radioButtonSelectAttributes.accessibilityLabel,
    );

    return true;
  }

  @override
  Future<bool> purchase(PurchaseAttributes purchaseAttributes) async {
    // Create products array
    final productsJS = purchaseAttributes.products.map((product) {
      final productJS = DataroidCommerceModelsBinding.createProduct(
        product.id,
        product.name,
        product.quantity,
        product.price,
        product.currency,
      );
      
      // Set optional product attributes
      // Note: In JavaScript API, optional attributes are set via methods on the product object
      // This would require additional JS bindings for product methods like setDescription, setBrand, etc.
      
      return productJS;
    }).toList();

    // Create purchase object
    final purchaseJS = DataroidCommerceModelsBinding.createPurchase(
      safeJsify(productsJS),
      purchaseAttributes.value,
      purchaseAttributes.currency,
      purchaseAttributes.success,
    );

    // Set optional purchase attributes
    // Note: Similar to products, these would require additional JS bindings for purchase methods
    // like addTax, addShip, addDiscount, etc.

    // Convert custom attributes to extras
    final extrasJS = purchaseAttributes.attributes != null ? 
        safeJsify(_convertCustomAttributesToJS(purchaseAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.purchase(purchaseJS, extrasJS);
    return true;
  }

  @override
  Future<bool> search(SearchAttributes searchAttributes) async {
    final extrasJS = searchAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(searchAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.search(searchAttributes.query, extrasJS);
    return true;
  }

  @override
  Future<bool> addToCart(AddToCartAttributes addToCartAttributes) async {
    final productJS = DataroidCommerceModelsBinding.createProduct(
      addToCartAttributes.product.id,
      addToCartAttributes.product.name,
      addToCartAttributes.product.quantity,
      addToCartAttributes.product.price,
      addToCartAttributes.product.currency,
    );

    final extrasJS = addToCartAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(addToCartAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.addToCart(
      productJS,
      addToCartAttributes.value?.toDouble(),
      addToCartAttributes.totalCartValue?.toDouble(),
      extrasJS,
    );
    return true;
  }

  @override
  Future<bool> removeFromCart(RemoveFromCartAttributes removeFromCartAttributes) async {
    final productJS = DataroidCommerceModelsBinding.createProduct(
      removeFromCartAttributes.product.id,
      removeFromCartAttributes.product.name,
      removeFromCartAttributes.product.quantity,
      removeFromCartAttributes.product.price,
      removeFromCartAttributes.product.currency,
    );

    final extrasJS = removeFromCartAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(removeFromCartAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.removeFromCart(
      productJS,
      removeFromCartAttributes.value?.toDouble(),
      removeFromCartAttributes.totalCartValue?.toDouble(),
      extrasJS,
    );
    return true;
  }

  @override
  Future<bool> clearCart(ClearCartAttributes clearCartAttributes) async {
    final extrasJS = clearCartAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(clearCartAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.clearCart(extrasJS);
    return true;
  }

  @override
  Future<bool> startCheckout(StartCheckoutAttributes startCheckoutAttributes) async {
    final extrasJS = startCheckoutAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(startCheckoutAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.startCheckout(
      startCheckoutAttributes.value.toDouble(),
      startCheckoutAttributes.currency,
      startCheckoutAttributes.quantity,
      extrasJS,
    );
    return true;
  }

  @override
  Future<bool> addToWishList(AddToWishlistAttributes addToWishlistAttributes) async {
    final productJS = DataroidCommerceModelsBinding.createProduct(
      addToWishlistAttributes.product.id,
      addToWishlistAttributes.product.name,
      addToWishlistAttributes.product.quantity,
      addToWishlistAttributes.product.price,
      addToWishlistAttributes.product.currency,
    );

    final extrasJS = addToWishlistAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(addToWishlistAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.addToWishList(productJS, extrasJS);
    return true;
  }

  @override
  Future<bool> removeFromWishList(RemoveFromWishlistAttributes removeFromWishlistAttributes) async {
    final productJS = DataroidCommerceModelsBinding.createProduct(
      removeFromWishlistAttributes.product.id,
      removeFromWishlistAttributes.product.name,
      removeFromWishlistAttributes.product.quantity,
      removeFromWishlistAttributes.product.price,
      removeFromWishlistAttributes.product.currency,
    );

    final extrasJS = removeFromWishlistAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(removeFromWishlistAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.removeFromWishList(productJS, extrasJS);
    return true;
  }

  @override
  Future<bool> viewCategory(ViewCategoryAttributes viewCategoryAttributes) async {
    final extrasJS = viewCategoryAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(viewCategoryAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.viewCategory(viewCategoryAttributes.category, extrasJS);
    return true;
  }

  @override
  Future<bool> viewProduct(ViewProductAttributes viewProductAttributes) async {
    final productJS = DataroidCommerceModelsBinding.createProduct(
      viewProductAttributes.product.id,
      viewProductAttributes.product.name,
      viewProductAttributes.product.quantity,
      viewProductAttributes.product.price,
      viewProductAttributes.product.currency,
    );

    final extrasJS = viewProductAttributes.attributes != null ?
        safeJsify(_convertCustomAttributesToJS(viewProductAttributes.attributes!)) : null;

    DataroidCommerceEventsBinding.viewProduct(productJS, extrasJS);
    return true;
  }

  @override
  Future<bool> updateLanguage(String languageCode) async {
    try {
      DataroidBinding.setLanguage(languageCode);
      return true;
    } catch (e) {
      print('Error in updateLanguage: $e');
      return false;
    }
  }

  @override
  Future<bool> setContextTriggerListener(ContextTriggerListener listener) async {
    _contextTriggerListener = listener;
    return _setContextTriggerListenerWeb();
  }

  @override
  Future<bool> removeContextTriggerListener() async {
    _contextTriggerListener = null;
    return _removeContextTriggerListenerWeb();
  }

  Future<bool> _setContextTriggerListenerWeb() async {
    try {
      // Create a Dart callback that will be called from JavaScript
      final jsCallback = ((JSAny contextData) {
        _handleContextTriggerFromJS(contextData);
      }).toJS;

      // Register the callback with the JavaScript SDK
      DataroidContextTriggerBinding.setContextTriggerCallback(jsCallback);
      return true;
    } catch (e) {
      print('Error setting context trigger listener: $e');
      return false;
    }
  }

  Future<bool> _removeContextTriggerListenerWeb() async {
    try {
      DataroidContextTriggerBinding.removeContextTriggerCallback();
      return true;
    } catch (e) {
      print('Error removing context trigger listener: $e');
      return false;
    }
  }

  void _handleContextTriggerFromJS(JSAny contextData) {
    try {
      // Convert JS object to Dart Map
      final contextMap = Map<String, dynamic>.from(
        (contextData as JSObject).dartify() as Map
      );

      // Extract contextTriggerId and params (which maps to attributes)
      final contextTriggerId = contextMap['contextTriggerId'] as String;
      final params = contextMap['params'] as Map<String, dynamic>?;

      // Create ContextTriggerResult
      final result = ContextTriggerResult(
        contextTriggerId: contextTriggerId,
        attributes: params,
      );

      // Call the registered listener if available
      _contextTriggerListener?.onContextTriggered(result);
    } catch (e) {
      print('Error handling context trigger from JavaScript: $e');
    }
  }

  // Helper method to convert CustomAttribute list to JS object
  Map<String, dynamic> _convertCustomAttributesToJS(List<dynamic> attributes) {
    final result = <String, dynamic>{};
    for (final attr in attributes) {
      if (attr is Map<String, dynamic> && attr.containsKey('key') && attr.containsKey('value')) {
        result[attr['key']] = attr['value'];
      }
    }
    return result;
  }

}