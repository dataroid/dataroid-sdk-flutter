/*
 * 
 * constants.dart
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

class MethodName {
  static const collectCustomEvent = 'collectCustomEvent';

  static const setUser = 'setUser';
  static const clearUser = 'clearUser';

  static const collectAPMHTTPRecord = 'collectAPMHTTPRecord';
  static const collectAPMNetworkErrorRecord = 'collectAPMNetworkErrorRecord';

  static const addToCart = 'addToCart';
  static const addToWishList = 'addToWishList';
  static const clearCart = 'clearCart';
  static const purchase = 'purchase';
  static const removeFromCart = 'removeFromCart';
  static const search = 'search';
  static const startCheckout = 'startCheckout';
  static const removeFromWishList = 'removeFromWishList';
  static const viewCategory = 'viewCategory';
  static const viewProduct = 'viewProduct';

  static const updateSessionConfig = 'updateSessionConfig';
  static const updateInAppConfig = 'updateInAppConfig';
  static const updateApmConfig = 'updateApmConfig';
  static const updateScreenTrackingConfig = 'updateScreenTrackingConfig';
  static const updateComponentInteractionConfig = 'updateComponentInteractionConfig';
  static const updateScreenInteractionConfig = 'updateScreenInteractionConfig';
  static const updateInboxConfig = 'updateInboxConfig';
  static const setEventCollectionEnabled = 'setEventCollectionEnabled';
  static const setEventStorageLimit = 'setEventStorageLimit';
  static const enableGeofencing = 'enableGeofencing';
  static const disableGeofencing = 'disableGeofencing';
  static const updateLanguage = 'updateLanguage';

  static const collectDeeplink = 'collectDeeplink';
  static const handleDeeplink = 'handleDeeplink';
  static const handleInApp = 'handleInApp';
  static const handleInAppButtonTap = 'handleInAppButtonTap';

  static const handlePushEventAndroid = 'handlePushEventAndroid';
  static const requestNotificationAuthorizationiOS = 'requestNotificationAuthorizationiOS';
  static const handlePushEventiOS = 'handlePushEventiOS';
  static const shouldShowPushNotificationInForegroundiOS = 'shouldShowPushNotificationInForegroundiOS';

  static const enablePush = 'enablePush';

  static const startTracking = 'startTracking';
  static const stopTracking = 'stopTracking';

  static const fetchMessages = 'fetchMessages';
  static const deleteMessages = 'deleteMessages';
  static const readMessages = 'readMessages';

  static const setSuperAttribute = 'setSuperAttribute';
  static const clearSuperAttribute = 'clearSuperAttribute';
  static const getAllSuperAttributes = 'getAllSuperAttributes';
  static const clearAllSuperAttributes = 'clearAllSuperAttributes';

  //Component Interaction
  static const collectButtonClickEvent = 'collectButtonClickEvent';
  static const collectTextChangeEvent = 'collectTextChangeEvent';
  static const collectToggleChangeEvent = 'collectToggleChangeEvent';
  static const collectRadioButtonSelectEvent = 'collectRadioButtonSelectEvent';

  //Screen Interaction
  static const collectTouchEvent = 'collectTouchEvent';
  static const collectDoubleTapEvent = 'collectDoubleTapEvent';
  static const collectLongPressEvent = 'collectLongPressEvent';
  static const collectSwipeEvent = 'collectSwipeEvent';

  // Notification Receivers
  static const pushMessageReceived = 'pushMessageReceived';
  static const handleBackgroundPush = 'handleBackgroundPush';
  static const collectNotificationOpenEvent = 'collectNotificationOpenEvent';
  static const collectNotificationDismissedEvent = 'collectNotificationDismissedEvent';
  
  // Context Trigger
  static const registerContextTriggerListener = 'registerContextTriggerListener';
  static const unregisterContextTriggerListener = 'unregisterContextTriggerListener';
  static const contextTriggered = 'contextTriggered';
}

class ArgumentName {
  static const name = 'name';
  static const label = 'label';
  static const viewClass = 'viewClass';
  static const id = 'id';
  static const value = 'value';
  static const key = 'key';
  static const currency = 'currency';

  static const customerId = 'customerId';
  static const email = 'email';
  static const phone = 'phone';
  static const nationalId = 'nationalId';
  static const firstName = 'firstName';
  static const lastName = 'lastName';
  static const dateOfBirth = 'dateOfBirth';
  static const genderIndex = 'genderIndex';
  static const attributes = 'attributes';
  static const dateAttributes = 'dateAttributes';
  static const intListAttributes = 'intListAttributes';
  static const stringListAttributes = 'stringListAttributes';

  static const url = 'url';
  static const method = 'method';
  static const statusCode = 'statusCode';
  static const requestSize = 'requestSize';
  static const responseSize = 'responseSize';
  static const duration = 'duration';
  static const connectionType = 'connectionType';
  static const success = 'success';
  static const errorType = 'errorType';
  static const errorCode = 'errorCode';
  static const errorMessage = 'errorMessage';
  static const customAttributes = 'customAttributes';
  static const exception = 'exception';
  static const message = 'message';

  static const product = 'product';
  static const products = 'products';
  static const description = 'description';
  static const brand = 'brand';
  static const quantity = 'quantity';
  static const price = 'price';
  static const variant = 'variant';
  static const category = 'category';
  static const totalCartValue = 'totalCartValue';
  static const coupon = 'coupon';
  static const query = 'query';
  static const tax = 'tax';
  static const ship = 'ship';
  static const discount = 'discount';
  static const trxId = 'trxId';
  static const paymentMethod = 'paymentMethod';

  static const goal = 'goal';
  static const appGroupIdentifier = 'appGroupIdentifier';
  static const inbox = 'inbox';
  static const storageLimit = 'storageLimit';
  static const isEnabled = 'isEnabled';
  static const recordingEnabled = 'recordingEnabled';
  static const enabledBundleIDs = 'enabledBundleIDs';
  static const snapshot = 'snapshot';
  static const inAppMessaging = 'inAppMessaging';
  static const inAppMessagingEnabled = 'inAppMessagingEnabled';
  static const recordCollectionEnabled = 'recordCollectionEnabled';
  static const recordDispatchLimit = 'recordDispatchLimit';
  static const recordStorageLimit = 'recordStorageLimit';
  static const apmAutoCaptureEnabled = 'apmAutoCaptureEnabled';
  static const apm = 'apm';
  static const enabled = 'enabled';
  static const autoCollectingEnabled = 'autoCollectingEnabled';
  static const debounceThreshold = 'debounceThreshold';
  static const screenTracking = 'screenTracking';

  static const eventCollectingEnabled = 'eventCollectingEnabled';
  static const sessionDropDuration = 'sessionDropDuration';
  static const languageCode = 'languageCode';

  static const logger = 'logger';
  static const level = 'level';
  static const writeToFile = 'writeToFile';

  static const deeplink = 'deeplink';
  static const content = 'content';
  static const inAppMessage = 'inAppMessage';
  static const inAppButton = 'inAppButton';
  static const title = 'title';
  static const text = 'text';
  static const language = 'language';
  static const action = 'action';
  static const buttonId = 'buttonId';

  static const notificationConfig = 'notificationConfig';
  static const smallNotificationIcon = 'smallNotificationIcon';
  static const largeNotificationIcon = 'largeNotificationIcon';
  static const defaultNotificationChannelId = 'defaultNotificationChannelId';
  static const defaultNotificationChannelName = 'defaultNotificationChannelName';

  static const pushEventTiming = 'pushEventTiming';
  static const pushActionType = 'pushActionType';
  static const pushTargetURL = 'pushTargetURL';
  static const pushAttrs = 'pushAttrs';
  static const actionType = 'actionType';
  static const notificationId = 'notificationId';

  static const messageIDList = 'messageIDList';
  static const messageType = 'messageType';
  static const messageStatus = 'messageStatus';
  static const from = 'from';
  static const to = 'to';
  static const isAnonymous = 'isAnonymous';

  static const type = 'type';
  static const receivedDate = 'receivedDate';
  static const expirationDate = 'expirationDate';
  static const status = 'status';
  static const payload = 'payload';

  static const left = "left";
  static const top = "top";
  static const right = "right";
  static const bottom = "bottom";

  static const accessibilityLabel = "accessibilityLabel";
  static const componentId = "componentId";
  static const className = "className";
  static const coordinates = "coordinates";
  static const screenTrackingAttributes = "screenTrackingAttributes";
  static const placeholder = "placeholder";

  static const x = "x";
  static const y = "y";
  static const touchPoint = "touchPoint";

  static const start = "start";
  static const end = "end";
  static const swipePoints = "swipePoints";

  static const contextTriggerId = 'contextTriggerId';
  static const contextTriggerAttributes = 'contextTriggerAttributes';
  
  // Background Push
  static const parameters = 'parameters';
  static const pushId = 'pushId';
  static const backgroundPushData = 'backgroundPushData';

  // Component Interaction specific
  static const href = 'href';
  static const elementType = 'elementType';
  static const elementName = 'elementName';
  static const groupName = 'groupName';
}
