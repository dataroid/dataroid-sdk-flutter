package com.dataroid.dataroid_sdk_android

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import com.dataroid.sdk.Dataroid
import com.dataroid.sdk.DataroidSessionConfig
import com.dataroid.sdk.annotations.Gender
import com.dataroid.sdk.annotations.HttpMethod
import com.dataroid.sdk.apm.NetworkErrorErrorType
import com.dataroid.sdk.autocollect.component.Coordinates
import com.dataroid.sdk.autocollect.gesture.TouchPoint
import com.dataroid.sdk.core.event.AttributeBuilder
import com.dataroid.sdk.core.event.Attributes
import com.dataroid.sdk.core.event.ButtonClickAttributes
import com.dataroid.sdk.core.event.CartAttributes
import com.dataroid.sdk.core.event.ClearCartAttributes
import com.dataroid.sdk.core.event.DeeplinkLaunchedAttributes
import com.dataroid.sdk.core.event.DoubleTapAttributes
import com.dataroid.sdk.core.event.HttpCallAttributes
import com.dataroid.sdk.core.event.LongPressAttributes
import com.dataroid.sdk.core.event.NetworkErrorAttributes
import com.dataroid.sdk.core.event.Product
import com.dataroid.sdk.core.event.PurchaseAttributes
import com.dataroid.sdk.core.event.ScreenTrackingAttributes
import com.dataroid.sdk.core.event.SearchAttributes
import com.dataroid.sdk.core.event.StartCheckoutAttributes
import com.dataroid.sdk.core.event.SwipeAttributes
import com.dataroid.sdk.core.event.TextChangeAttributes
import com.dataroid.sdk.core.event.ToggleChangeAttributes
import com.dataroid.sdk.core.event.RadioButtonSelectAttributes
import com.dataroid.sdk.core.event.TouchAttributes
import com.dataroid.sdk.core.event.ViewCategoryAttributes
import com.dataroid.sdk.core.event.ViewProductAttributes
import com.dataroid.sdk.core.event.WishListAttributes
import com.dataroid.sdk.iamessaging.DataroidInAppMessagingConfig
import com.dataroid.sdk.inbox.InboxMessage
import com.dataroid.sdk.inbox.InboxQuery
import com.dataroid.sdk.mobileservices.protocol.PushRegistrationResult
import com.dataroid.sdk.network.networkconfig.DataroidCertificatePinningConfig
import com.dataroid.sdk.network.networkconfig.DataroidNetworkConfig
import com.dataroid.sdk.push.InboxMessageStatus
import com.dataroid.sdk.push.InboxMessageType
import com.dataroid.sdk.push.RemoteNotificationHandler
import com.dataroid.sdk.snapshot.DataroidSnapshotConfig
import com.dataroid.sdk.snapshot.SnapshotCallback
import com.dataroid.sdk.util.logging.ConnectCommonLog
import com.dataroid.sdk.util.time.SystemCurrentTimeProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONArray
import java.io.File
import java.math.BigDecimal
import java.sql.Timestamp
import java.util.*
import java.util.Queue
import java.util.LinkedList
import com.dataroid.sdk.ctxtrigger.CtxTriggerResult
import com.dataroid.sdk.util.subscription.Subscriber
import com.dataroid.sdk.notifications.NotificationCallbackResult
import com.dataroid.sdk.util.BackgroundPushData
import com.dataroid.sdk.analytics.screentracking.DataroidScreenTrackingConfig
import com.dataroid.sdk.apm.DataroidAPMConfig
import com.dataroid.sdk.autocollect.DataroidComponentInteractionConfig
import com.dataroid.sdk.autocollect.DataroidScreenInteractionConfig
import com.dataroid.sdk.core.event.UserAttributes
import com.dataroid.sdk.network.DataroidJsonConverter
import com.dataroid.sdk.push.DataroidPushNotificationConverter
import com.dataroid.sdk.registry.DataroidInstanceRegistry
import com.dataroid.sdk.util.DataroidLogConfig

enum class LogLevel(val level: Int) {
    NO_LOG(0),
    VERBOSE(2),
    DEBUG(3),
    WARN(5),
    ERROR(6)
}

class SnapshotConfig {
  var enabled: Boolean? = null
  var allowedPackages: Array<String>? = null
  var latency: Int? = null
  var hardwareBitmapSupport: Boolean? = null
}

class DataroidPluginConfig(val sdkKey: String, val serverURL: String) {
  var eventCollectionEnabled: Boolean? = true
  var isAPMEnabled: Boolean? = null
  var isAPMAutoCaptureEnabled: Boolean? = null
  var isInAppMessagingEnabled: Boolean? = null
  var isScreenTrackingEnabled: Boolean? = null
  var isAutoScreenInterActionEnabled: Boolean? = null
  var logLevel: LogLevel? = null
  var isFileLoggingEnabled: Boolean? = null
  var eventStorageLimit: Int? = null
  var eventDispatchLimit: Int? = null
  var languageCode: String? = null
  var pinningEndpoint: String? = null
  var pinningKey: String? = null
  var sessionDropDuration: Double? = null
  var snapshot: SnapshotConfig = SnapshotConfig()

}

/** DataroidSdkAndroidPlugin */
class DataroidSdkAndroidPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, SnapshotCallback {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var snapshotChannel : MethodChannel

  private lateinit var context: Context
  private var activity: Activity? = null
  private var subscriber: Subscriber<CtxTriggerResult>? = null
  private var screenshotCompleter: ((File?) -> Unit)? = null
  private val screenshotCompleterLock = Any()

  private fun convertToHttpMethod(methodName: String?) : String? {
    return when(methodName) {
      "POST" -> HttpMethod.POST
      "HEAD" -> HttpMethod.HEAD
      "CONNECT" -> HttpMethod.CONNECT
      "OPTIONS" -> HttpMethod.OPTIONS
      "GET" -> HttpMethod.GET
      "PATCH" ->HttpMethod.PATCH
      "PUT" -> HttpMethod.PUT
      "DELETE" ->HttpMethod.DELETE
      "TRACE" ->HttpMethod.TRACE
      else -> null
    }
  }

  override fun onAttachedToEngine( flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    pluginInstance = this
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dataroid_plugin_flutter")
    channel.setMethodCallHandler(this)
    
    // Initialize snapshot channel
    snapshotChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.dataroid/snapshot")
    snapshotChannel.setMethodCallHandler(this::handleSnapshotMethodCall)

    try {
      val config = dataroid.config.dataroidSnapshotConfig
      config.withSnapshotCallback(this)
      println("✅ [SNAPSHOT] Flutter callback registered successfully in onAttachedToEngine")
    } catch (e: Exception) {
      println("⚠️ [SNAPSHOT] Failed to register callback: ${e.message}")
    }

    // Process any pending notification actions that occurred while plugin was not attached
    Companion.processPendingNotificationActions()

    dataroid.inAppMessaging.subscribeToMessages {
      channel.invokeMethod(METHOD_HANDLE_IN_APP, mapOf(ARGUMENT_CONTENT to mapOf(ARGUMENT_TITLE to it.title, ARGUMENT_TEXT to it.text, ARGUMENT_LANGUAGE to it.language)));
    }

  }

  override fun onMethodCall( call: MethodCall,  result: Result) {
    Handler(Looper.getMainLooper()).post {
      try {
        val arguments = (call.arguments as? Map<String, Any>) ?: emptyMap<String, Any>()
        when (call.method) {
            METHOD_COLLECT_CUSTOM_EVENT -> {
              handleCollectCustomEvent(arguments, result)
            }
            METHOD_SET_USER -> {
              handleSetUser(arguments, result)
            }
            METHOD_CLEAR_USER -> {
              handleClearUser(result)
            }
            METHOD_COLLECT_APMHTTP_RECORD -> {
              handleCollectAPMHTTPRecord(arguments, result)
            }
            METHOD_COLLECT_APM_NETWORK_ERROR_RECORD -> {
              handleCollectAPMNetworkRecord(arguments, result)
            }
            METHOD_ADD_TO_CART -> {
              handleAddToCart(arguments, result)
            }
            METHOD_ADD_TO_WISH_LIST -> {
              handleAddToWishList(arguments, result)
            }
            METHOD_CLEAR_CART -> {
              handleClearCart(arguments, result)
            }
            METHOD_PURCHASE -> {
              handlePurchase(arguments, result)
            }
            METHOD_REMOVE_FROM_CART -> {
              handleRemoveFromCart(arguments, result)
            }
            METHOD_SEARCH -> {
              handleSearch(arguments, result)
            }
            METHOD_START_CHECKOUT -> {
              handleStartCheckout(arguments, result)
            }
            METHOD_REMOVE_FROM_WISH_LIST -> {
              handleRemoveFromWishList(arguments, result)
            }
            METHOD_VIEW_CATEGORY -> {
              handleViewCategory(arguments, result)
            }
            METHOD_VIEW_PRODUCT -> {
              handleViewProduct(arguments, result)
            }
            METHOD_UPDATE_SESSION_CONFIG -> {
              handleUpdateSessionConfig(arguments, result)
            }
            METHOD_UPDATE_IN_APP_CONFIG -> {
              handleUpdateInAppConfig(arguments, result)
            }
            METHOD_UPDATE_APM_CONFIG -> {
              handleUpdateApmConfig(arguments, result)
            }
            METHOD_UPDATE_SCREEN_TRACKING_CONFIG -> {
              handleUpdateScreenTrackingConfig(arguments, result)
            }
            METHOD_UPDATE_COMPONENT_INTERACTION_CONFIG -> {
              handleUpdateComponentInteractionConfig(arguments, result)
            }
            METHOD_UPDATE_SCREEN_INTERACTION_CONFIG -> {
              handleUpdateScreenInteractionConfig(arguments, result)
            }
            METHOD_UPDATE_INBOX_CONFIG -> {
              handleUpdateInboxConfig(arguments, result)
            }
            METHOD_SET_EVENT_COLLECTION_ENABLED -> {
              handleSetEventCollectionEnabled(arguments, result)
            }
            METHOD_SET_EVENT_STORAGE_LIMIT -> {
              handleSetEventStorageLimit(arguments, result)
            }
            METHOD_ENABLE_GEOFENCING -> {
              handleEnableGeofencing(result)
            }
            METHOD_DISABLE_GEOFENCING -> {
              handleDisableGeofencing(result)
            }
            METHOD_UPDATE_LANGUAGE -> {
              handleUpdateLanguage(arguments, result)
            }
            METHOD_ENABLE_PUSH -> {
              handleEnablePush(result)
            }
            METHOD_START_TRACKING -> {
              handleStartTracking(arguments, result)
            }
            METHOD_STOP_TRACKING -> {
              handleStopTracking(arguments, result)
            }
            METHOD_FETCH_MESSAGES -> {
              handleFetchInboxMessages(arguments, result)
            }
            METHOD_DELETE_MESSAGES -> {
              handleDeleteInboxMessages(arguments, result)
            }
            METHOD_READ_MESSAGES -> {
              handleReadInboxMessages(arguments, result)
            }
            METHOD_SET_SUPER_ATTRIBUTE -> {
              handleSetSuperAttribute(arguments, result)
            }
            METHOD_CLEAR_SUPER_ATTRIBUTE -> {
              handleClearSuperAttribute(arguments, result)
            }
            METHOD_GET_ALL_SUPER_ATTRIBUTES -> {
              handleGetAllSuperAttributes(result)
            }
            METHOD_CLEAR_ALL_SUPER_ATTRIBUTES -> {
              handleClearAllSuperAttributes(result)
            }
            METHOD_COLLECT_DEEPLINK -> {
              handleCollectDeeplink(arguments, result)
            }
            METHOD_COLLECT_BUTTON_CLICK_EVENT -> {
              handleCollectButtonClickEvent(arguments, result)
            }
            METHOD_COLLECT_TEXT_CHANGE_EVENT -> {
              handleCollectTextChangeEvent(arguments, result)
            }
            METHOD_COLLECT_TOGGLE_CHANGE_EVENT -> {
              handleCollectToggleChangeEvent(arguments, result)
            }
            METHOD_COLLECT_RADIO_BUTTON_SELECT_EVENT -> {
              handleCollectRadioButtonSelectEvent(arguments, result)
            }
            METHOD_COLLECT_TOUCH_EVENT -> {
              handleCollectTouchEvent(arguments, result)
            }
            METHOD_COLLECT_DOUBLE_TAP_EVENT -> {
              handleCollectDoubleTapEvent(arguments, result)
            }
            METHOD_COLLECT_LONG_PRESS_EVENT -> {
              handleCollectLongPressEvent(arguments, result)
            }
            METHOD_COLLECT_SWIPE_EVENT -> {
              handleCollectSwipeEvent(arguments, result)
            }
            METHOD_PUSH_MESSAGE_RECEIVED -> {
              handlePushMessageReceived(arguments, result)
            }
            METHOD_REGISTER_CONTEXT_TRIGGER_LISTENER -> {
              registerContextTriggerListener()
              result.success(null)
            }
            METHOD_UNREGISTER_CONTEXT_TRIGGER_LISTENER -> {
              unregisterContextTriggerListener()
              result.success(null)
            }
            METHOD_COLLECT_NOTIFICATION_OPEN_EVENT -> {
              handleCollectNotificationOpenEvent(arguments, result)
            }
            METHOD_COLLECT_NOTIFICATION_DISMISSED_EVENT -> {
              handleCollectNotificationDismissedEvent(arguments, result)
            }
            METHOD_LOG_EXTERNAL -> {
              handleLogExternal(arguments, result)
            }
            else -> {
              result.success(false)
            }
          }
      } catch (e: Exception) {
        result.error("-1", e.message, null)
      }
    }
  }

  private fun handleSnapshotMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "onScreenshotTaken" -> {
        val filePath = call.argument<String>("filePath")
        val file = if (filePath != null) File(filePath) else null
        println("🔵 [SNAPSHOT] Flutter callback received: $filePath")
        
        val completer = synchronized(screenshotCompleterLock) {
          val currentCompleter = screenshotCompleter
          if (currentCompleter != null) {
            screenshotCompleter = null
          }
          currentCompleter
        }
        
        if (completer != null) {
          completer.invoke(file)
          // Send success response to Flutter
          result.success(mapOf("success" to true, "message" to "Screenshot processed"))
        } else {
          println("⚠️ [SNAPSHOT] No screenshot completer available, requesting cleanup")
          // Send failure response to Flutter so it can clean up the file
          result.success(mapOf("success" to false, "message" to "No completer available", "cleanup" to true))
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  // SnapshotCallback implementation
  override fun requestScreenshot(onComplete: SnapshotCallback.OnCompleteListener) {
    println("🟡 [SNAPSHOT] Native SDK requested screenshot")
    
    var alreadyPending = false
    synchronized(screenshotCompleterLock) {
      if (screenshotCompleter != null) {
        alreadyPending = true
      } else {
        screenshotCompleter = { file -> 
          println("🟢 [SNAPSHOT] Flutter returned file: ${file?.absolutePath ?: "null"}")
          onComplete.onComplete(file) 
        }
      }
    }
    if (alreadyPending) {
      println("⚠️ [SNAPSHOT] Already have a pending screenshot request, ignoring")
      return
    }
    
    try {
      snapshotChannel.invokeMethod("takeScreenshot", null)
    } catch (e: Exception) {
      println("❌ [SNAPSHOT] Failed to invoke takeScreenshot: ${e.message}")
      synchronized(screenshotCompleterLock) {
        screenshotCompleter = null
      }
      onComplete.onComplete(null)
    }
  }

  override fun onDetachedFromEngine( binding: FlutterPlugin.FlutterPluginBinding) {
    unregisterContextTriggerListener()
    channel.setMethodCallHandler(null)
    snapshotChannel.setMethodCallHandler(null)
    
    // Clean up screenshot completer to prevent memory leaks
    synchronized(screenshotCompleterLock) {
      screenshotCompleter = null
    }
    
    // Remove snapshot callback
    try {
      val config = dataroid.config.dataroidSnapshotConfig
        config.withSnapshotCallback(null)
        println("🧹 [SNAPSHOT] Callback unregistered in onDetachedFromEngine")
    } catch (e: Exception) {
      println("⚠️ [SNAPSHOT] Failed to unregister callback: ${e.message}")
    }
    
    pluginInstance = null
  }

  @Throws(MissingArgumentException::class)
  private fun handleCollectCustomEvent(arguments: Map<String, Any>,  result: Result) {
    val eventName = arguments[ARGUMENT_EVENT_NAME] as? String
    if (eventName.isNullOrEmpty()) {
      dataroid.logExternal(6, "Flutter", "handleCollectCustomEvent: missing eventName")
      throw MissingArgumentException()
    }

    val attributes = Attributes().apply {
      // Handle the main attributes map containing nested special attribute maps
      val attributesMap = arguments[ARGUMENT_ATTRIBUTES] as? Map<String, Any>
      
      // Extract and process dateAttributes
      val dateAttrs = attributesMap?.get(ARGUMENT_DATE_ATTRIBUTES) as? Map<String, Any>
      dateAttrs?.forEach {
        var value = parseLong(it.value)
        if (value != null) {
          val date = Date(Timestamp(value).time)
          put(it.key, date)
        }
      }

      // Extract and process intListAttributes
      val intListAttrs = attributesMap?.get(ARGUMENT_INT_LIST_ATTRIBUTES) as? Map<String, Any?>
      intListAttrs?.forEach {
        val typedVal = (it.value as? List<Int>) ?: listOf<Int>()
        var value = IntArray(typedVal.size)
        for (i in typedVal.indices) {
          value[i] = typedVal[i]
        }
        put(it.key, value)
      }

      // Extract and process stringListAttributes
      val stringListAttrs = attributesMap?.get(ARGUMENT_STRING_LIST_ATTRIBUTES) as? Map<String, Any>
      stringListAttrs?.forEach {
        val typedVal = (it.value as? List<String>) ?: listOf<String>()
        var value = Array<String?>(typedVal.size) {null}
        for (i in typedVal.indices) {
          value[i] = typedVal[i]
        }
        put(it.key, value)
      }

      // Process regular attributes
      val regularAttrs = attributesMap?.get(ARGUMENT_ATTRIBUTES) as? Map<String, Any>
      regularAttrs?.forEach {
        when(it.value) {
          is Int -> put(it.key, it.value as Int?)
          is Double -> put(it.key, it.value as Double?)
          is Float -> put(it.key, it.value as Float?)
          is Boolean -> put(it.key, it.value as Boolean?)
          is String -> put(it.key, it.value as String?)
          else -> {}
        }
      }
    }

    dataroid.collectEvent(eventName, attributes)
    dataroid.logExternal(3, "Flutter", "handleCollectCustomEvent: completed with eventName=$eventName, attributes=$attributes")
    result.success(true)
  }

  private fun parseUserAttributes(key: String, value : Any, userAttributes : UserAttributes) {
    when(value) {
      is Boolean -> userAttributes.put(key, value as Boolean?)
      is Double -> userAttributes.put(key, value as Double?)
      is Float -> userAttributes.put(key, value as Float?)
      is Int -> userAttributes.put(key, value as Int?)
      is String -> userAttributes.put(key, value as String?)
      else -> {}
    }
  }

  @Throws(MissingArgumentException::class)
  private fun handleSetUser(arguments: Map<String, Any>,  result: Result) {
    val customerId = arguments[ARGUMENT_CUSTOMER_ID] as? String
    if (customerId.isNullOrEmpty()) {
      dataroid.logExternal(6, "Flutter", "handleSetUser: missing customerId")
      throw MissingArgumentException()
    }

    val userAttributes = UserAttributes()
    (arguments[ARGUMENT_EMAIL] as? String)?.let {
      userAttributes.setEmail(it)
    }
    (arguments[ARGUMENT_PHONE] as? String)?.let {
      userAttributes.setPhoneNumber(it)
    }
    (arguments[ARGUMENT_NATIONAL_ID] as? String)?.let {
      userAttributes.setNationalId(it)
    }
    (arguments[ARGUMENT_FIRST_NAME] as? String)?.let {
      userAttributes.setFirstName(it)
    }
    (arguments[ARGUMENT_LAST_NAME] as? String)?.let {
      userAttributes.setLastName(it)
    }
    parseLong(arguments[ARGUMENT_DATE_OF_BIRTH])?.let {
      val date = Date(Timestamp(it).time)
      userAttributes.setDateOfBirth(date)
    }
    (arguments[ARGUMENT_GENDER_INDEX] as? Int)?.let {
      when (it) {
        1 -> userAttributes.setGender(Gender.MALE)
        2 -> userAttributes.setGender(Gender.FEMALE)
        3 -> userAttributes.setGender(Gender.NONBINARY)
        4 -> userAttributes.setGender(Gender.UNKNOWN)
        else -> { }
      }
    }
    (arguments[ARGUMENT_DATE_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      var value = parseLong(it.value)

      if (value != null) {
        val date = Date(Timestamp(value).time)
        userAttributes.put(it.key, date)
      }

    }

    (arguments[ARGUMENT_ATTRIBUTES] as? Map<String, Any>)?.forEach {
        parseUserAttributes(it.key, it.value, userAttributes)
    }
    dataroid.setUser(customerId, userAttributes)
    dataroid.logExternal(3, "Flutter", "handleSetUser: completed with customerId=$customerId, userAttributes=$userAttributes")
    result.success(true)
  }

  private fun handleClearUser(result: Result) {
    dataroid.clearUser()
    dataroid.logExternal(3, "Flutter", "handleClearUser: completed")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleSetSuperAttribute(arguments: Map<String, Any>,  result: Result) {

    val key = arguments[ARGUMENT_KEY] as? String
    if (key == null) {
      dataroid.logExternal(6, "Flutter", "handleSetSuperAttribute: missing key")
      throw MissingArgumentException()
    }

    arguments[ARGUMENT_DATE_ATTRIBUTES]?.let {
      val timestamp = when(it) {
        is Double -> it.toLong()
        is Long -> it
        is Int -> it.toLong()
        else -> null
      }
      
      if (timestamp != null) {
        val date = Date(timestamp)
        dataroid.setSuperAttribute(key, date)
      }
    }

    arguments[ARGUMENT_ATTRIBUTES]?.let {
      when(it) {
        is Int -> dataroid.setSuperAttribute(key, it)
        is Double -> dataroid.setSuperAttribute(key, it)
        is Float -> dataroid.setSuperAttribute(key, it)
        is Boolean -> dataroid.setSuperAttribute(key, it)
        is String -> dataroid.setSuperAttribute(key, it)
        else -> {}
      }
    }

    dataroid.logExternal(3, "Flutter", "handleSetSuperAttribute: completed with key=$key")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleClearSuperAttribute(arguments: Map<String, Any>,  result: Result) {

    val key = arguments[ARGUMENT_KEY] as? String
    if (key.isNullOrEmpty()) {
      dataroid.logExternal(6, "Flutter", "handleClearSuperAttribute: missing key")
      throw MissingArgumentException()
    }
    dataroid.clearSuperAttribute(key)
    dataroid.logExternal(3, "Flutter", "handleClearSuperAttribute: completed with key=$key")
    result.success(true)
  }

  private fun handleGetAllSuperAttributes(result: Result) {
    try {
      val superAttributes = dataroid.getAllSuperAttributes()
      val resultMap = mutableMapOf<String, Any?>()
      
      superAttributes?.forEach { (key, value) ->
        when (value) {
          is Date -> resultMap[key] = value.time
          else -> resultMap[key] = value
        }
      }
      
      dataroid.logExternal(3, "Flutter", "handleGetAllSuperAttributes: completed with ${resultMap.size} attributes")
      result.success(resultMap)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleGetAllSuperAttributes: failed with error: ${e.message}")
      result.error("GET_ALL_SUPER_ATTRIBUTES_ERROR", e.message, null)
    }
  }

  private fun handleClearAllSuperAttributes(result: Result) {
    try {
      dataroid.clearAllSuperAttributes()
      dataroid.logExternal(3, "Flutter", "handleClearAllSuperAttributes: completed")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleClearAllSuperAttributes: failed with error: ${e.message}")
      result.error("CLEAR_ALL_SUPER_ATTRIBUTES_ERROR", e.message, null)
    }
  }

  @Throws(MissingArgumentException::class)
  private fun handleCollectAPMHTTPRecord(arguments: Map<String, Any>, result: Result) {
    val url = arguments[ARGUMENT_URL] as? String
    val statusCode = arguments[ARGUMENT_STATUS_CODE] as? Int
    val duration = arguments[ARGUMENT_DURATION] as? Int
    val success = arguments[ARGUMENT_SUCCESS] as? Boolean
    val methodString = arguments[ARGUMENT_METHOD] as? String

    val method = convertToHttpMethod(methodString)

    if (url.isNullOrEmpty() || method.isNullOrEmpty() || statusCode == null ||
            duration == null || success == null) {
      dataroid.logExternal(6, "Flutter", "handleCollectAPMHTTPRecord: missing required arguments")
      throw MissingArgumentException()
    }

    val httpCallAttributes = HttpCallAttributes(url, method, statusCode, duration.toLong(), success)

    (arguments[ARGUMENT_REQUEST_SIZE] as? Double)?.let {
      httpCallAttributes.setRequestPayloadSize(it.toLong())
    }
    (arguments[ARGUMENT_RESPONSE_SIZE] as? Double)?.let {
      httpCallAttributes.setResponsePayloadSize(it.toLong())
    }
    (arguments[ARGUMENT_ERROR_TYPE] as? String)?.let {
      httpCallAttributes.setErrorType(it)
    }
    (arguments[ARGUMENT_ERROR_CODE] as? String)?.let {
      httpCallAttributes.setErrorCode(it)
    }
    (arguments[ARGUMENT_ERROR_MESSAGE] as? String)?.let {
      httpCallAttributes.setErrorMessage(it)
    }

    (arguments[ARGUMENT_DATE_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      var value = parseLong(it.value)

      if (value != null) {
        val date = Date(Timestamp(value).time)
        httpCallAttributes.put(it.key, date)
      }
    }

    (arguments[ARGUMENT_INT_LIST_ATTRIBUTES] as? Map<String, Any?>)?.forEach {
      val typedVal = (it.value as? List<Int>) ?: listOf<Int>()
      var value = IntArray(typedVal.size)
      for (i in typedVal.indices) {
        value[i] = typedVal[i]
      }
      httpCallAttributes.put(it.key, value)

    }

    (arguments[ARGUMENT_STRING_LIST_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      val typedVal = (it.value as? List<String>) ?: listOf<String>()
      var value = Array<String?>(typedVal.size) {null}
      for (i in typedVal.indices) {
        value[i] = typedVal[i]
      }
      httpCallAttributes.put(it.key, value)
    }

    (arguments[ARGUMENT_CUSTOM_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      when(it.value) {
        is Int -> httpCallAttributes.put(it.key, it.value as Int?)
        is Double -> httpCallAttributes.put(it.key, it.value as Double?)
        is Float -> httpCallAttributes.put(it.key, it.value as Float?)
        is Boolean -> httpCallAttributes.put(it.key, it.value as Boolean?)
        is String -> httpCallAttributes.put(it.key, it.value as String?)
        else -> {}
      }
    }
    dataroid.apmClient.collectHttpCall(httpCallAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectAPMHTTPRecord: completed with url=$url, attributes=$httpCallAttributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleCollectAPMNetworkRecord(arguments: Map<String, Any>,  result: Result) {
    val url = arguments[ARGUMENT_URL] as? String
    val methodString = arguments[ARGUMENT_METHOD] as? String
    val exception = arguments[ARGUMENT_EXCEPTION] as? String
    val duration = arguments[ARGUMENT_DURATION] as? Int

    var method = convertToHttpMethod(methodString)

    if (url.isNullOrEmpty() || method.isNullOrEmpty() || exception == null || duration == null) {
      dataroid.logExternal(6, "Flutter", "handleCollectAPMNetworkRecord: missing required arguments")
      throw MissingArgumentException()
    }

    val errorTypeValue = arguments[ARGUMENT_TYPE] as? Int
    val errorType = parseErrorType(errorTypeValue) ?: throw MissingArgumentException()



    val networkErrorAttributes = NetworkErrorAttributes(url, method, duration.toLong(), errorType, exception)

    (arguments[ARGUMENT_MESSAGE] as? String)?.let {
      networkErrorAttributes.setMessage(it)
    }

    (arguments[ARGUMENT_DATE_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      var value = parseLong(it.value)

      if (value != null) {
        val date = Date(Timestamp(value).time)
        networkErrorAttributes.put(it.key, date)
      }
    }

    (arguments[ARGUMENT_INT_LIST_ATTRIBUTES] as? Map<String, Any?>)?.forEach {
      val typedVal = (it.value as? List<Int>) ?: listOf<Int>()
      var value = IntArray(typedVal.size)
      for (i in typedVal.indices) {
        value[i] = typedVal[i]
      }
      networkErrorAttributes.put(it.key, value)

    }

    (arguments[ARGUMENT_STRING_LIST_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      val typedVal = (it.value as? List<String>) ?: listOf<String>()
      var value = Array<String?>(typedVal.size) {null}
      for (i in typedVal.indices) {
        value[i] = typedVal[i]
      }
      networkErrorAttributes.put(it.key, value)
    }

    (arguments[ARGUMENT_CUSTOM_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      when(it.value) {
        is Int -> networkErrorAttributes.put(it.key, it.value as Int?)
        is Double -> networkErrorAttributes.put(it.key, it.value as Double?)
        is Float -> networkErrorAttributes.put(it.key, it.value as Float?)
        is Boolean -> networkErrorAttributes.put(it.key, it.value as Boolean?)
        is String -> networkErrorAttributes.put(it.key, it.value as String?)
        else -> {}
      }
    }

    dataroid.apmClient.collectNetworkError(networkErrorAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectAPMNetworkRecord: completed with url=$url, attributes=$networkErrorAttributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleAddToCart(arguments: Map<String, Any>,  result: Result) {
    val productArguments = arguments[ARGUMENT_PRODUCT] as? Map<String, Any>
    
    if (productArguments == null) {
      dataroid.logExternal(6, "Flutter", "handleAddToCart: missing product")
      throw MissingArgumentException()
    }
    val product = parseProduct(productArguments)
    val attributes = CartAttributes(product)
    (arguments[ARGUMENT_VALUE] as? Int)?.let {
      attributes.setValue(BigDecimal(it))
    }
    (arguments[ARGUMENT_TOTAL_CART_VALUE] as? Int)?.let {
      attributes.setTotalCartValue(BigDecimal(it))
    }

    putCustomAttributes(arguments, attributes)

    dataroid.collectAddToCart(attributes)
    dataroid.logExternal(3, "Flutter", "handleAddToCart: completed with attributes=$attributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleAddToWishList(arguments: Map<String, Any>,  result: Result) {
    val productArguments = arguments[ARGUMENT_PRODUCT] as? Map<String, Any>
    
    if (productArguments == null) {
      dataroid.logExternal(6, "Flutter", "handleAddToWishList: missing product")
      throw MissingArgumentException()
    }
    val product = parseProduct(productArguments)
    val attributes = WishListAttributes(product)

    putCustomAttributes(arguments, attributes)

    dataroid.collectAddToWishList(attributes)
    dataroid.logExternal(3, "Flutter", "handleAddToWishList: completed with attributes=$attributes")
    result.success(true)
  }

  private fun handleClearCart(arguments: Map<String, Any>,  result: Result) {
    val attributes = ClearCartAttributes()
    putCustomAttributes(arguments, attributes)

    dataroid.collectClearCart(attributes)
    dataroid.logExternal(3, "Flutter", "handleClearCart: completed")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handlePurchase(arguments: Map<String, Any>,  result: Result) {
    val productsList = arguments[ARGUMENT_PRODUCTS] as? List<Map<String, Any>>
    val currency = arguments[ARGUMENT_CURRENCY] as? String
    val value = arguments[ARGUMENT_VALUE] as? Double
    val success = arguments[ARGUMENT_SUCCESS] as? Boolean
    
    if (productsList == null) {
      dataroid.logExternal(6, "Flutter", "handlePurchase: missing products")
      throw MissingArgumentException()
    }
    val products = productsList.map { parseProduct(it) }

    if (currency.isNullOrEmpty() || value == null || success == null) {
      dataroid.logExternal(6, "Flutter", "handlePurchase: missing required arguments")
      throw MissingArgumentException()
    }

    val purchaseAttributes = PurchaseAttributes(currency, BigDecimal(value), success).apply {
      setProductList(products)
      (arguments[ARGUMENT_TAX] as? Double)?.let {
        setTax(BigDecimal((it)))
      }
      (arguments[ARGUMENT_SHIP] as? Double)?.let {
        setShip(BigDecimal(it))
      }
      (arguments[ARGUMENT_DISCOUNT] as? Double)?.let {
        setDiscount(BigDecimal((it)))
      }
      (arguments[ARGUMENT_COUPON] as? String)?.let {
        setCoupon(it)
      }
      (arguments[ARGUMENT_TRX_ID] as? String)?.let {
        setTransactionId(it)
      }
      (arguments[ARGUMENT_PAYMENT_METHOD] as? String)?.let {
        setPaymentMethod(it)
      }
      (arguments[ARGUMENT_QUANTITY] as? Int)?.let {
        setQuantity(it)
      }
      (arguments[ARGUMENT_ERROR_CODE] as? String)?.let {
        setErrorCode(it)
      }
      (arguments[ARGUMENT_ERROR_MESSAGE] as? String)?.let {
        setErrorMessage(it)
      }
    }

    putCustomAttributes(arguments, purchaseAttributes)

    dataroid.collectPurchase(purchaseAttributes)
    dataroid.logExternal(3, "Flutter", "handlePurchase: completed with attributes=$purchaseAttributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleRemoveFromCart(arguments: Map<String, Any>,  result: Result) {
    val productArguments = arguments[ARGUMENT_PRODUCT] as? Map<String, Any>
    
    if (productArguments == null) {
      dataroid.logExternal(6, "Flutter", "handleRemoveFromCart: missing product")
      throw MissingArgumentException()
    }
    val product = parseProduct(productArguments)
    val attributes = CartAttributes(product)
    (arguments[ARGUMENT_VALUE] as? Int)?.let {
      attributes.setValue(BigDecimal(it))
    }
    (arguments[ARGUMENT_TOTAL_CART_VALUE] as? Int)?.let {
      attributes.setTotalCartValue(BigDecimal(it))
    }

    putCustomAttributes(arguments, attributes)

    dataroid.collectRemoveFromCart(attributes)
    dataroid.logExternal(3, "Flutter", "handleRemoveFromCart: completed with attributes=$attributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleSearch(arguments: Map<String, Any>,  result: Result) {
    val query = arguments[ARGUMENT_QUERY] as? String
    
    if (query == null) {
      dataroid.logExternal(6, "Flutter", "handleSearch: missing query")
      throw MissingArgumentException()
    }
    val attributes = SearchAttributes(query)

    putCustomAttributes(arguments, attributes)

    dataroid.collectSearch(attributes)
    dataroid.logExternal(3, "Flutter", "handleSearch: completed with attributes=$attributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleStartCheckout(arguments: Map<String, Any>,  result: Result) {
    val value = arguments[ARGUMENT_VALUE] as? Int
    val currency = arguments[ARGUMENT_CURRENCY] as? String
    if (currency.isNullOrEmpty() || value == null) {
      dataroid.logExternal(6, "Flutter", "handleStartCheckout: missing required arguments")
      throw MissingArgumentException()
    }

    val attributes = StartCheckoutAttributes(BigDecimal(value), currency).apply {
      (arguments[ARGUMENT_QUANTITY] as? Int)?.let {
        setQuantity(it)
      }
    }

    putCustomAttributes(arguments, attributes)

    dataroid.collectStartCheckout(attributes)
    dataroid.logExternal(3, "Flutter", "handleStartCheckout: completed with attributes=$attributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleRemoveFromWishList(arguments: Map<String, Any>,  result: Result) {
    val productArguments = arguments[ARGUMENT_PRODUCT] as? Map<String, Any>
    
    if (productArguments == null) {
      dataroid.logExternal(6, "Flutter", "handleRemoveFromWishList: missing product")
      throw MissingArgumentException()
    }
    val product = parseProduct(productArguments)
    val attributes = WishListAttributes(product)

    putCustomAttributes(arguments, attributes)

    dataroid.collectRemoveFromWishList(attributes)
    dataroid.logExternal(3, "Flutter", "handleRemoveFromWishList: completed with attributes=$attributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleViewCategory(arguments: Map<String, Any>,  result: Result) {
    val category = arguments[ARGUMENT_CATEGORY] as? String
    
    if (category == null) {
      dataroid.logExternal(6, "Flutter", "handleViewCategory: missing category")
      throw MissingArgumentException()
    }
    val attributes = ViewCategoryAttributes(category)

    putCustomAttributes(arguments, attributes)

    dataroid.collectViewCategory(attributes)
    dataroid.logExternal(3, "Flutter", "handleViewCategory: completed with attributes=$attributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleViewProduct(arguments: Map<String, Any>,  result: Result) {
    val productArguments = arguments[ARGUMENT_PRODUCT] as? Map<String, Any>
    
    if (productArguments == null) {
      dataroid.logExternal(6, "Flutter", "handleViewProduct: missing product")
      throw MissingArgumentException()
    }
    val product = parseProduct(productArguments)
    val attributes = ViewProductAttributes(product)

    putCustomAttributes(arguments, attributes)

    dataroid.collectViewProduct(attributes)
    dataroid.logExternal(3, "Flutter", "handleViewProduct: completed with attributes=$attributes")
    result.success(true)
  }

  private fun handleEnableGeofencing( result: Result) {
    dataroid.geofenceClient.enableGeoFencing()
    dataroid.logExternal(3, "Flutter", "handleEnableGeofencing: completed")
    result.success(true)
  }

  private fun handleDisableGeofencing( result: Result) {
    dataroid.geofenceClient.disableGeoFencing()
    dataroid.logExternal(3, "Flutter", "handleDisableGeofencing: completed")
    result.success(true)
  }

  private fun handleUpdateLanguage(arguments: Map<String, Any>,  result: Result) {
    val languageCode = arguments[ARGUMENT_LANGUAGE_CODE] as? String
    languageCode?.let {
      dataroid.updateLanguage(Locale(it))
    }
    dataroid.logExternal(3, "Flutter", "handleUpdateLanguage: completed with languageCode=$languageCode")
    result.success(true)
  }

  private fun handleEnablePush( result: Result) {
    dataroid.enablePush { result ->
      when (result) {
        PushRegistrationResult.RESULT_CODE_FAILED -> {}
        PushRegistrationResult.RESULT_CODE_OK -> {}
        PushRegistrationResult.RESULT_CODE_PENDING -> {}
      }
    }
    dataroid.logExternal(3, "Flutter", "handleEnablePush: completed")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleStartTracking(arguments: Map<String, Any>,  result: Result) {
    val viewClass = (arguments[ARGUMENT_VIEW_CLASS] as? String)
    val label = (arguments[ARGUMENT_LABEL] as? String)
    
    if (viewClass == null || label == null) {
      dataroid.logExternal(6, "Flutter", "handleStartTracking: missing required arguments")
      throw MissingArgumentException()
    }

    var screenTrackingAttributes = ScreenTrackingAttributes(viewClass, label).apply {
      (arguments[ARGUMENT_DATE_ATTRIBUTES] as? Map<String, Any>)?.forEach {
        var value = parseLong(it.value)

        if (value != null) {
          val date = Date(Timestamp(value).time)
          put(it.key, date)
        }
      }

      (arguments[ARGUMENT_INT_LIST_ATTRIBUTES] as? Map<String, Any?>)?.forEach {
        val typedVal = (it.value as? List<Int>) ?: listOf<Int>()
        var value = IntArray(typedVal.size)
        for (i in typedVal.indices) {
          value[i] = typedVal[i]
        }
        put(it.key, value)

      }

      (arguments[ARGUMENT_STRING_LIST_ATTRIBUTES] as? Map<String, Any>)?.forEach {

        val typedVal = (it.value as? List<String>) ?: listOf<String>()
        var value = Array<String?>(typedVal.size) {null}
        for (i in typedVal.indices) {
          value[i] = typedVal[i]
        }
        put(it.key, value)
      }

      (arguments[ARGUMENT_ATTRIBUTES] as? Map<String, Any>)?.forEach {
        when(it.value) {
          is Int -> put(it.key, it.value as Int?)
          is Double -> put(it.key, it.value as Double?)
          is Float -> put(it.key, it.value as Float?)
          is Boolean -> put(it.key, it.value as Boolean?)
          is String -> put(it.key, it.value as String?)
          else -> {}
        }
      }
    }
    dataroid.screenTracker.viewStart(screenTrackingAttributes)
    dataroid.logExternal(3, "Flutter", "handleStartTracking: completed with attributes=$screenTrackingAttributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleStopTracking(arguments: Map<String, Any>,  result: Result) {
    val viewClass = (arguments[ARGUMENT_VIEW_CLASS] as? String)
    val label = (arguments[ARGUMENT_LABEL] as? String)
    
    if (viewClass == null || label == null) {
      dataroid.logExternal(6, "Flutter", "handleStopTracking: missing required arguments")
      throw MissingArgumentException()
    }

    var screenTrackingAttributes = ScreenTrackingAttributes(viewClass, label)

    dataroid.screenTracker.viewStop(screenTrackingAttributes)
    dataroid.logExternal(3, "Flutter", "handleStopTracking: completed with attributes=$screenTrackingAttributes")
    result.success(true)
  }

  private fun handleFetchInboxMessages(arguments: Map<String, Any>,  result: Result) {
    val queryJSON = arguments[ARGUMENT_QUERY] as? Map<String, Any>
    var inboxQuery: InboxQuery? = null
    queryJSON?.let { json ->
      val queryBuilder = InboxQuery.Builder()
      (json[ARGUMENT_MESSAGE_TYPE] as? Int)?.let {
        when (it) {
          0 -> queryBuilder.type(InboxMessageType.PUSH_MESSAGE)
          1 -> queryBuilder.type(InboxMessageType.INAPP_MESSAGE)
          2 -> queryBuilder.type(InboxMessageType.GEOFENCE_MESSAGE)
          3 -> queryBuilder.type(InboxMessageType.ACTION_BASED_MESSAGE)
          else -> print("")
        }
      }
      (json[ARGUMENT_MESSAGE_STATUS] as? Int)?.let {
        when (it) {
          0 -> queryBuilder.status(InboxMessageStatus.UNREAD)
          1 -> queryBuilder.status(InboxMessageStatus.READ)
          2 -> queryBuilder.status(InboxMessageStatus.DISMISSED)
          else -> print("")
        }
      }
      (json[ARGUMENT_IS_ANONYMOUS] as? Boolean)?.let {
        queryBuilder.anonymous(it)
      }
      (json[ARGUMENT_FROM] as? Long)?.let {
        val date = Date(Timestamp(it).time)
        queryBuilder.from(date)
      }
      (json[ARGUMENT_TO] as? Long)?.let {
        val date = Date(Timestamp(it).time)
        queryBuilder.to(date)
      }
      inboxQuery = queryBuilder.build()
    }

    fun onGetCallback(messages: List<InboxMessage>): List<Map<String, Any>> {
      val messageList = messages.map { inboxMessage ->
        // Convert message type to index for Flutter enum
        var messageTypeIndex = when (inboxMessage.type) {
          InboxMessageType.PUSH_MESSAGE -> 0
          InboxMessageType.INAPP_MESSAGE -> 1
          InboxMessageType.GEOFENCE_MESSAGE -> 2
          InboxMessageType.ACTION_BASED_MESSAGE -> 3
          else -> 0
        }
        
        // Convert message status to index for Flutter enum
        var messageStatusIndex = when (inboxMessage.status) {
          InboxMessageStatus.UNREAD -> 0
          InboxMessageStatus.READ -> 1
          InboxMessageStatus.DISMISSED -> 2
          else -> 0
        }
        
        // Create the base message map with common properties
        val messageMap = mutableMapOf<String, Any>(
          ARGUMENT_ID to inboxMessage.id.toString(),
          ARGUMENT_MESSAGE_TYPE to messageTypeIndex,
          ARGUMENT_MESSAGE_STATUS to messageStatusIndex
        )
        
        // Add dates if available
        inboxMessage.expirationDate?.let { date ->
          messageMap[ARGUMENT_EXPIRATION_DATE] = date.time.toDouble()
        }
        
        inboxMessage.receivedDate?.let { date ->
          messageMap[ARGUMENT_RECEIVED_DATE] = date.time.toDouble()
        }
        
        // Add customer ID if available
        inboxMessage.customerId?.let { customerId ->
          messageMap[ARGUMENT_CUSTOMER_ID] = customerId
        }

        // Process different message types with their specific data structures
        when (inboxMessage.type) {
          InboxMessageType.PUSH_MESSAGE, InboxMessageType.GEOFENCE_MESSAGE -> {
            val pushPayload = inboxMessage.getPayload()
            val pushNotification = pushPayload?.getPushNotification()
            
            if (pushNotification != null) {
              val pushEventMap = mutableMapOf<String, Any>()
              
              // Create alert map with title and body
              val alertMap = mutableMapOf<String, String>()
              pushNotification.contentTitle?.let { title -> 
                alertMap["title"] = title 
              }
              pushNotification.contentBody?.let { body -> 
                alertMap["body"] = body 
              }
              
              if (alertMap.isNotEmpty()) {
                pushEventMap["alert"] = alertMap
              }
              
              // Add push notification properties
              pushNotification.sound?.let { soundName -> 
                pushEventMap["soundName"] = soundName 
              }
              pushNotification.notificationId?.let { pushId -> 
                pushEventMap["pushId"] = pushId 
              }
              pushNotification.scheduleId?.let { scheduleId -> 
                pushEventMap["scheduleId"] = scheduleId 
              }
              pushNotification.notificationImageUrl?.let { mediaUrl -> 
                pushEventMap["mediaURL"] = mediaUrl 
              }
              pushNotification.actionUrl?.let { targetUrl -> 
                pushEventMap["targetURL"] = targetUrl 
              }
              
              // Map action type to Flutter enum index
              val actionTypeIndex = when (pushNotification.actionType) {
                "NOTHING" -> 0
                "OPEN_APP" -> 1
                "GO_TO_URL" -> 2
                "GO_TO_DEEPLINK" -> 3
                else -> null
              }
              
              if (actionTypeIndex != null) {
                pushEventMap["actionType"] = actionTypeIndex
              }
              
              // Add pushEvent to message map if not empty
              if (pushEventMap.isNotEmpty()) {
                messageMap["pushEvent"] = pushEventMap
              }
            }
          }
            InboxMessageType.ACTION_BASED_MESSAGE -> {
                val pushPayload = inboxMessage.getPayload()
                val pushNotification = pushPayload?.getPushNotification()

                val actionBasedMap = mutableMapOf<String, Any>()

                if (pushNotification != null) {

                    pushNotification.contentTitle?.let { title ->
                        actionBasedMap["title"] = title
                    }
                    pushNotification.contentBody?.let { body ->
                        actionBasedMap["text"] = body
                    }

                    // Add push notification properties
                    pushNotification.sound?.let { soundName ->
                        actionBasedMap["sound"] = soundName
                    }
                    pushNotification.notificationId?.let { pushId ->
                        actionBasedMap["pushId"] = pushId
                    }
                    pushNotification.scheduleId?.let { scheduleId ->
                        actionBasedMap["scheduleId"] = scheduleId
                    }
                    pushNotification.notificationImageUrl?.let { mediaUrl ->
                        actionBasedMap["imageUrl"] = mediaUrl
                    }
                    pushNotification.actionUrl?.let { targetUrl ->
                        actionBasedMap["actionTargetUrl"] = targetUrl
                    }

                    pushNotification.customActionParameters?.let { parameters ->
                        actionBasedMap["parameters"] = parameters
                    }

                    // Map action type to Flutter enum index
                    val actionTypeIndex = when (pushNotification.actionType) {
                        "NOTHING" -> 0
                        "OPEN_APP" -> 1
                        "GO_TO_URL" -> 2
                        "GO_TO_DEEPLINK" -> 3
                        else -> null
                    }

                    if (actionTypeIndex != null) {
                        actionBasedMap["actionTypeIndex"] = actionTypeIndex
                    }

                    messageMap["actionBasedMessage"] = actionBasedMap
                }
            }

          InboxMessageType.INAPP_MESSAGE -> {
            val inAppMessage = inboxMessage.getPayload()?.getInAppMessage()
            if (inAppMessage != null) {
              val inAppMap = mutableMapOf<String, Any>()
              
              inAppMessage.getInAppMessageId()?.let { messageId -> inAppMap["messageId"] = messageId }
              
              if (inAppMap.isNotEmpty()) {
                messageMap["inAppMessage"] = inAppMap
              }
            }
          }
          
          else -> {
            // Handle other message types if needed
          }
        }
        
        messageMap
      }
      return messageList
    }

    val query = inboxQuery
    if (query == null) {
      dataroid.inboxClient.getMessages {
        dataroid.logExternal(3, "Flutter", "handleFetchInboxMessages: completed with ${it.size} messages")
        result.success(JSONArray(onGetCallback(it)).toString())
      }
    } else {
      dataroid.inboxClient.getMessages(query) {
        dataroid.logExternal(3, "Flutter", "handleFetchInboxMessages: completed with ${it.size} messages")
        result.success(JSONArray(onGetCallback(it)).toString())
      }
    }
  }

  private fun handleDeleteInboxMessages(arguments: Map<String, Any>,  result: Result) {
    val messageIDList = (arguments[ARGUMENT_MESSAGE_ID_LIST] as? List<String>) ?: emptyList()
    val validMessageIds = messageIDList.mapNotNull { it.toLongOrNull() }
    if (validMessageIds.size != messageIDList.size) {
      dataroid.logExternal(4, "Flutter", "handleDeleteInboxMessages: Some message IDs could not be converted to Long")
    }
    dataroid.inboxClient.deleteMessages(validMessageIds, null)
    dataroid.logExternal(3, "Flutter", "handleDeleteInboxMessages: completed with ${validMessageIds.size} message IDs")
    result.success(true)
  }

  private fun handleReadInboxMessages(arguments: Map<String, Any>,  result: Result) {
    val messageIDList = (arguments[ARGUMENT_MESSAGE_ID_LIST] as? List<String>) ?: emptyList()
    val validMessageIds = messageIDList.mapNotNull { it.toLongOrNull() }
    if (validMessageIds.size != messageIDList.size) {
      dataroid.logExternal(4, "Flutter", "handleReadInboxMessages: Some message IDs could not be converted to Long")
    }
    dataroid.inboxClient.readMessage(validMessageIds, null)
    dataroid.logExternal(3, "Flutter", "handleReadInboxMessages: completed with ${validMessageIds.size} message IDs")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleCollectDeeplink(arguments: Map<String, Any>,  result: Result) {
    val url = (arguments[ARGUMENT_URL] as? String)
    
    if (url == null) {
      dataroid.logExternal(6, "Flutter", "handleCollectDeeplink: missing url")
      throw MissingArgumentException()
    }

    val attributes: DeeplinkLaunchedAttributes = DeeplinkLaunchedAttributes(Uri.parse(url)).apply {
      (arguments[ARGUMENT_DATE_ATTRIBUTES] as? Map<String, Any>)?.forEach {
        var value = parseLong(it.value)

        if (value != null) {
          val date = Date(Timestamp(value).time)
          put(it.key, date)
        }
      }

      (arguments[ARGUMENT_INT_LIST_ATTRIBUTES] as? Map<String, Any?>)?.forEach {
        val typedVal = (it.value as? List<Int>) ?: listOf<Int>()
        var value = IntArray(typedVal.size)
        for (i in typedVal.indices) {
          value[i] = typedVal[i]
        }
        put(it.key, value)

      }

      (arguments[ARGUMENT_STRING_LIST_ATTRIBUTES] as? Map<String, Any>)?.forEach {

        val typedVal = (it.value as? List<String>) ?: listOf<String>()
        var value = Array<String?>(typedVal.size) {null}
        for (i in typedVal.indices) {
          value[i] = typedVal[i]
        }
        put(it.key, value)
      }

      (arguments[ARGUMENT_ATTRIBUTES] as? Map<String, Any>)?.forEach {
        when(it.value) {
          is Int -> put(it.key, it.value as Int?)
          is Double -> put(it.key, it.value as Double?)
          is Float -> put(it.key, it.value as Float?)
          is Boolean -> put(it.key, it.value as Boolean?)
          is String -> put(it.key, it.value as String?)
          else -> {}
        }
      }
    }

    dataroid.collectDeeplinkLaunched(attributes)
    dataroid.logExternal(3, "Flutter", "handleCollectDeeplink: completed with url=$url, attributes=$attributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleCollectButtonClickEvent(arguments: Map<String, Any>,  result: Result) {
    val buttonClickAttributes = ButtonClickAttributes().apply {

      (arguments[ARGUMENT_LABEL] as? String)?.let {
        setLabel(it)
      }

      (arguments[ARGUMENT_ACCESSIBILITY_LABEL] as? String)?.let {
        setAccessibilityLabel(it)
      }

      (arguments[ARGUMENT_COMPONENT_ID] as? String)?.let {
        setComponentId(it)
      }

      (arguments[ARGUMENT_CLASS_NAME] as? String)?.let {
        setClassName(it)
      }

      (arguments[ARGUMENT_COORDINATES] as? Map<String, Any>)?.let {coordinates ->
        val left = (coordinates[ARGUMENT_LEFT]) as? Int ?: throw MissingArgumentException()
        val top = (coordinates[ARGUMENT_TOP]) as? Int ?: throw MissingArgumentException()
        val right = (coordinates[ARGUMENT_RIGHT]) as? Int ?: throw MissingArgumentException()
        val bottom = (coordinates[ARGUMENT_BOTTOM]) as? Int ?: throw MissingArgumentException()

        setCoordinates(Coordinates(left, top, right, bottom))
      }

      (arguments[ARGUMENT_SCREEN_TRACKING_ATTRIBUTES] as? Map<String, Any>)?.let { attributes ->
        val viewClass = (attributes[ARGUMENT_VIEW_CLASS]) as? String ?: throw MissingArgumentException()
        val viewLabel = (attributes[ARGUMENT_LABEL]) as? String ?: throw MissingArgumentException()
        setScreenTrackingAttributes(ScreenTrackingAttributes(viewClass, viewLabel))
      }
    }

    dataroid.autoCaptureClient.collectButtonClick(buttonClickAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectButtonClickEvent: completed with attributes=$buttonClickAttributes")
    result.success(true)
  }
  @Throws(MissingArgumentException::class)
  private fun handleCollectTextChangeEvent(arguments: Map<String, Any>,  result: Result) {
    val textChangeAttributes = TextChangeAttributes().apply {

      (arguments[ARGUMENT_PLACEHOLDER] as? String)?.let {
        setPlaceholder(it)
      }

      (arguments[ARGUMENT_VALUE] as? String)?.let {
        setTextValue(it)
      }

      (arguments[ARGUMENT_ACCESSIBILITY_LABEL] as? String)?.let {
        setAccessibilityLabel(it)
      }

      (arguments[ARGUMENT_COMPONENT_ID] as? String)?.let {
        setComponentId(it)
      }

      (arguments[ARGUMENT_CLASS_NAME] as? String)?.let {
        setClassName(it)
      }

      (arguments[ARGUMENT_COORDINATES] as? Map<String, Any>)?.let {coordinates ->
        val left = (coordinates[ARGUMENT_LEFT]) as? Int ?: throw MissingArgumentException()
        val top = (coordinates[ARGUMENT_TOP]) as? Int ?: throw MissingArgumentException()
        val right = (coordinates[ARGUMENT_RIGHT]) as? Int ?: throw MissingArgumentException()
        val bottom = (coordinates[ARGUMENT_BOTTOM]) as? Int ?: throw MissingArgumentException()

        setCoordinates(Coordinates(left, top, right, bottom))
      }

      (arguments[ARGUMENT_SCREEN_TRACKING_ATTRIBUTES] as? Map<String, Any>)?.let { attributes ->
        val viewClass = (attributes[ARGUMENT_VIEW_CLASS]) as? String ?: throw MissingArgumentException()
        val viewLabel = (attributes[ARGUMENT_LABEL]) as? String ?: throw MissingArgumentException()
        setScreenTrackingAttributes(ScreenTrackingAttributes(viewClass, viewLabel))
      }
    }

    dataroid.autoCaptureClient.collectTextChange(textChangeAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectTextChangeEvent: completed with attributes=$textChangeAttributes")
    result.success(true)
  }
  @Throws(MissingArgumentException::class)
  private fun handleCollectToggleChangeEvent(arguments: Map<String, Any>,  result: Result) {
    val toggleChangeAttributes = ToggleChangeAttributes().apply {

      (arguments[ARGUMENT_LABEL] as? String)?.let {
        setLabel(it)
      }

      (arguments[ARGUMENT_VALUE] as? Boolean)?.let {
        setIsChecked(it)
      }

      (arguments[ARGUMENT_ACCESSIBILITY_LABEL] as? String)?.let {
        setAccessibilityLabel(it)
      }

      (arguments[ARGUMENT_COMPONENT_ID] as? String)?.let {
        setComponentId(it)
      }

      (arguments[ARGUMENT_CLASS_NAME] as? String)?.let {
        setClassName(it)
      }

      (arguments[ARGUMENT_COORDINATES] as? Map<String, Any>)?.let {coordinates ->
        val left = (coordinates[ARGUMENT_LEFT]) as? Int ?: throw MissingArgumentException()
        val top = (coordinates[ARGUMENT_TOP]) as? Int ?: throw MissingArgumentException()
        val right = (coordinates[ARGUMENT_RIGHT]) as? Int ?: throw MissingArgumentException()
        val bottom = (coordinates[ARGUMENT_BOTTOM]) as? Int ?: throw MissingArgumentException()

        setCoordinates(Coordinates(left, top, right, bottom))
      }

      (arguments[ARGUMENT_SCREEN_TRACKING_ATTRIBUTES] as? Map<String, Any>)?.let { attributes ->
        val viewClass = (attributes[ARGUMENT_VIEW_CLASS]) as? String ?: throw MissingArgumentException()
        val viewLabel = (attributes[ARGUMENT_LABEL]) as? String ?: throw MissingArgumentException()
        setScreenTrackingAttributes(ScreenTrackingAttributes(viewClass, viewLabel))
      }
    }

    dataroid.autoCaptureClient.collectToggleChange(toggleChangeAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectToggleChangeEvent: completed with attributes=$toggleChangeAttributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleCollectRadioButtonSelectEvent(arguments: Map<String, Any>, result: Result) {
    val radioButtonSelectAttributes = RadioButtonSelectAttributes().apply {

      (arguments[ARGUMENT_LABEL] as? String)?.let {
        setSelectedButtonLabel(it)
      }

      (arguments[ARGUMENT_ACCESSIBILITY_LABEL] as? String)?.let {
        setAccessibilityLabel(it)
      }

      (arguments[ARGUMENT_COMPONENT_ID] as? String)?.let {
        setComponentId(it)
      }

      (arguments[ARGUMENT_CLASS_NAME] as? String)?.let {
        setClassName(it)
      }

      (arguments[ARGUMENT_COORDINATES] as? Map<String, Any>)?.let { coordinates ->
        val left = (coordinates[ARGUMENT_LEFT]) as? Int ?: throw MissingArgumentException()
        val top = (coordinates[ARGUMENT_TOP]) as? Int ?: throw MissingArgumentException()
        val right = (coordinates[ARGUMENT_RIGHT]) as? Int ?: throw MissingArgumentException()
        val bottom = (coordinates[ARGUMENT_BOTTOM]) as? Int ?: throw MissingArgumentException()

        setCoordinates(Coordinates(left, top, right, bottom))
      }

      (arguments[ARGUMENT_SCREEN_TRACKING_ATTRIBUTES] as? Map<String, Any>)?.let { attributes ->
        val viewClass = (attributes[ARGUMENT_VIEW_CLASS]) as? String ?: throw MissingArgumentException()
        val viewLabel = (attributes[ARGUMENT_LABEL]) as? String ?: throw MissingArgumentException()
        setScreenTrackingAttributes(ScreenTrackingAttributes(viewClass, viewLabel))
      }
    }

    dataroid.autoCaptureClient.collectRadioButtonSelected(radioButtonSelectAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectRadioButtonSelectEvent: completed with attributes=$radioButtonSelectAttributes")
    result.success(true)
  }

  @Throws(MissingArgumentException::class)
  private fun handleCollectTouchEvent (arguments: Map<String, Any>,  result: Result) {
    val touchAttributes = TouchAttributes().apply {

      (arguments[ARGUMENT_ACCESSIBILITY_LABEL] as? String)?.let {
        setAccessibilityLabel(it)
      }

      (arguments[ARGUMENT_COMPONENT_ID] as? String)?.let {
        setComponentId(it)
      }

      (arguments[ARGUMENT_CLASS_NAME] as? String)?.let {
        setClassName(it)
      }

      (arguments[ARGUMENT_COORDINATES] as? Map<String, Any>)?.let {coordinates ->
        val left = (coordinates[ARGUMENT_LEFT]) as? Int ?: throw MissingArgumentException()
        val top = (coordinates[ARGUMENT_TOP]) as? Int ?: throw MissingArgumentException()
        val right = (coordinates[ARGUMENT_RIGHT]) as? Int ?: throw MissingArgumentException()
        val bottom = (coordinates[ARGUMENT_BOTTOM]) as? Int ?: throw MissingArgumentException()

        setCoordinates(Coordinates(left, top, right, bottom))
      }

      (arguments[ARGUMENT_SCREEN_TRACKING_ATTRIBUTES] as? Map<String, Any>)?.let { attributes ->
        val viewClass = (attributes[ARGUMENT_VIEW_CLASS]) as? String ?: throw MissingArgumentException()
        val viewLabel = (attributes[ARGUMENT_LABEL]) as? String ?: throw MissingArgumentException()
        setScreenTrackingAttributes(ScreenTrackingAttributes(viewClass, viewLabel))
      }
      (arguments[ARGUMENT_TOUCH_POINT] as? Map<String, Any>)?.let { attributes ->
        val x = (attributes[ARGUMENT_X]) as? Int ?: throw MissingArgumentException()
        val y = (attributes[ARGUMENT_Y]) as? Int ?: throw MissingArgumentException()
        setTouchPoint(TouchPoint(x,y))
      }
    }

    dataroid.autoCaptureClient.collectTouch(touchAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectTouchEvent: completed with attributes=$touchAttributes")
    result.success(true)
  }
  @Throws(MissingArgumentException::class)
  private fun handleCollectDoubleTapEvent (arguments: Map<String, Any>,  result: Result) {
    val doubleTapAttributes = DoubleTapAttributes().apply {

      (arguments[ARGUMENT_ACCESSIBILITY_LABEL] as? String)?.let {
        setAccessibilityLabel(it)
      }

      (arguments[ARGUMENT_COMPONENT_ID] as? String)?.let {
        setComponentId(it)
      }

      (arguments[ARGUMENT_CLASS_NAME] as? String)?.let {
        setClassName(it)
      }

      (arguments[ARGUMENT_COORDINATES] as? Map<String, Any>)?.let {coordinates ->
        val left = (coordinates[ARGUMENT_LEFT]) as? Int ?: throw MissingArgumentException()
        val top = (coordinates[ARGUMENT_TOP]) as? Int ?: throw MissingArgumentException()
        val right = (coordinates[ARGUMENT_RIGHT]) as? Int ?: throw MissingArgumentException()
        val bottom = (coordinates[ARGUMENT_BOTTOM]) as? Int ?: throw MissingArgumentException()

        setCoordinates(Coordinates(left, top, right, bottom))
      }

      (arguments[ARGUMENT_SCREEN_TRACKING_ATTRIBUTES] as? Map<String, Any>)?.let { attributes ->
        val viewClass = (attributes[ARGUMENT_VIEW_CLASS]) as? String ?: throw MissingArgumentException()
        val viewLabel = (attributes[ARGUMENT_LABEL]) as? String ?: throw MissingArgumentException()
        setScreenTrackingAttributes(ScreenTrackingAttributes(viewClass, viewLabel))
      }
      (arguments[ARGUMENT_TOUCH_POINT] as? Map<String, Any>)?.let { attributes ->
        val x = (attributes[ARGUMENT_X]) as? Int ?: throw MissingArgumentException()
        val y = (attributes[ARGUMENT_Y]) as? Int ?: throw MissingArgumentException()
        setTouchPoint(TouchPoint(x,y))
      }
    }

    dataroid.autoCaptureClient.collectDoubleTap(doubleTapAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectDoubleTapEvent: completed with attributes=$doubleTapAttributes")
    result.success(true)
  }
  @Throws(MissingArgumentException::class)
  private fun handleCollectLongPressEvent (arguments: Map<String, Any>,  result: Result) {
    val longPressAttributes = LongPressAttributes().apply {

      (arguments[ARGUMENT_ACCESSIBILITY_LABEL] as? String)?.let {
        setAccessibilityLabel(it)
      }

      (arguments[ARGUMENT_COMPONENT_ID] as? String)?.let {
        setComponentId(it)
      }

      (arguments[ARGUMENT_CLASS_NAME] as? String)?.let {
        setClassName(it)
      }

      (arguments[ARGUMENT_COORDINATES] as? Map<String, Any>)?.let {coordinates ->
        val left = (coordinates[ARGUMENT_LEFT]) as? Int ?: throw MissingArgumentException()
        val top = (coordinates[ARGUMENT_TOP]) as? Int ?: throw MissingArgumentException()
        val right = (coordinates[ARGUMENT_RIGHT]) as? Int ?: throw MissingArgumentException()
        val bottom = (coordinates[ARGUMENT_BOTTOM]) as? Int ?: throw MissingArgumentException()

        setCoordinates(Coordinates(left, top, right, bottom))
      }

      (arguments[ARGUMENT_SCREEN_TRACKING_ATTRIBUTES] as? Map<String, Any>)?.let { attributes ->
        val viewClass = (attributes[ARGUMENT_VIEW_CLASS]) as? String ?: throw MissingArgumentException()
        val viewLabel = (attributes[ARGUMENT_LABEL]) as? String ?: throw MissingArgumentException()
        setScreenTrackingAttributes(ScreenTrackingAttributes(viewClass, viewLabel))
      }
      (arguments[ARGUMENT_TOUCH_POINT] as? Map<String, Any>)?.let { attributes ->
        val x = (attributes[ARGUMENT_X]) as? Int ?: throw MissingArgumentException()
        val y = (attributes[ARGUMENT_Y]) as? Int ?: throw MissingArgumentException()
        setTouchPoint(TouchPoint(x,y))
      }
    }

    dataroid.autoCaptureClient.collectLongPress(longPressAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectLongPressEvent: completed with attributes=$longPressAttributes")
    result.success(true)
  }
  @Throws(MissingArgumentException::class)
  private fun handleCollectSwipeEvent (arguments: Map<String, Any>,  result: Result) {
    val swipeAttributes = SwipeAttributes().apply {

      (arguments[ARGUMENT_ACCESSIBILITY_LABEL] as? String)?.let {
        setAccessibilityLabel(it)
      }

      (arguments[ARGUMENT_COMPONENT_ID] as? String)?.let {
        setComponentId(it)
      }

      (arguments[ARGUMENT_CLASS_NAME] as? String)?.let {
        setClassName(it)
      }

      (arguments[ARGUMENT_COORDINATES] as? Map<String, Any>)?.let {coordinates ->
        val left = (coordinates[ARGUMENT_LEFT]) as? Int ?: throw MissingArgumentException()
        val top = (coordinates[ARGUMENT_TOP]) as? Int ?: throw MissingArgumentException()
        val right = (coordinates[ARGUMENT_RIGHT]) as? Int ?: throw MissingArgumentException()
        val bottom = (coordinates[ARGUMENT_BOTTOM]) as? Int ?: throw MissingArgumentException()

        setCoordinates(Coordinates(left, top, right, bottom))
      }

      (arguments[ARGUMENT_SCREEN_TRACKING_ATTRIBUTES] as? Map<String, Any>)?.let { attributes ->
        val viewClass = (attributes[ARGUMENT_VIEW_CLASS]) as? String ?: throw MissingArgumentException()
        val viewLabel = (attributes[ARGUMENT_LABEL]) as? String ?: throw MissingArgumentException()
        setScreenTrackingAttributes(ScreenTrackingAttributes(viewClass, viewLabel))
      }
      (arguments[ARGUMENT_SWIPE_POINTS] as? Map<String, Any>)?.let { attributes ->
        val start = (attributes[ARGUMENT_START]) as? Map<String, Any> ?: throw MissingArgumentException()
        val end = (attributes[ARGUMENT_END]) as? Map<String, Any> ?: throw MissingArgumentException()

        val startX = (start[ARGUMENT_X]) as? Int ?: throw MissingArgumentException()
        val startY = (start[ARGUMENT_Y]) as? Int ?: throw MissingArgumentException()

        val endX = (end[ARGUMENT_X]) as? Int ?: throw MissingArgumentException()
        val endY = (end[ARGUMENT_Y]) as? Int ?: throw MissingArgumentException()

        setSwipePoints(TouchPoint(startX, startY), TouchPoint(endX, endY))
      }
    }

    dataroid.autoCaptureClient.collectSwipe(swipeAttributes)
    dataroid.logExternal(3, "Flutter", "handleCollectSwipeEvent: completed with attributes=$swipeAttributes")
    result.success(true)
  }

  @SuppressLint("RestrictedApi")
  @Throws(MissingArgumentException::class)
  private fun handlePushMessageReceived(arguments: Map<String, Any>, result: Result) {
      val logger = ConnectCommonLog.getInstance()
      try {
          if (DataroidInstanceRegistry.getRegistry().all.isEmpty()) {
              dataroid.logExternal(6, "Flutter", "Received push notification but no Dataroid instance found, skipping.")
              result.success(false)
              return
          }
          val args = arguments as Map<String, String>
          val isDataroid = RemoteNotificationHandler(
              DataroidPushNotificationConverter(DataroidJsonConverter.getInstance(), logger),
              SystemCurrentTimeProvider.newInstance(),
              logger
          ).handle(args)
          dataroid.logExternal(3, "Flutter", "handlePushMessageReceived: completed with result=$isDataroid")
          result.success(isDataroid)
      } catch (e: Exception) {
          dataroid.logExternal(6, "Flutter", "handlePushMessageReceived: failed with error: ${e.message}")
          result.error("PUSH_MESSAGE_ERROR", "Failed to handle push message: ${e.message}", null)
      }
  }

  private fun handleUpdateSessionConfig(arguments: Map<String, Any>, result: Result) {
    val sessionDropDuration = arguments[ARGUMENT_SESSION_DROP_DURATION] as? Double
    try {
      sessionDropDuration?.let {
        dataroid.config.sessionConfig.timeout = it.toInt() * 1000 // convert to milliseconds
      }
      dataroid.logExternal(3, "Flutter", "handleUpdateSessionConfig: completed with sessionDropDuration=$sessionDropDuration")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleUpdateSessionConfig: failed with error: ${e.message}")
      result.error("UPDATE_SESSION_CONFIG_ERROR", e.message, null)
    }
  }

  private fun handleUpdateInAppConfig(arguments: Map<String, Any>, result: Result) {
    val inAppMessagingEnabled = arguments[ARGUMENT_IN_APP_MESSAGING_ENABLED] as? Boolean
    try {
      inAppMessagingEnabled?.let { isEnabled ->
        dataroid.config.inAppMessagingConfig.isEnabled = isEnabled
      }
      dataroid.logExternal(3, "Flutter", "handleUpdateInAppConfig: completed with inAppMessagingEnabled=$inAppMessagingEnabled")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleUpdateInAppConfig: failed with error: ${e.message}")
      result.error("UPDATE_IN_APP_CONFIG_ERROR", e.message, null)
    }
  }

  private fun handleUpdateApmConfig(arguments: Map<String, Any>, result: Result) {
    try {
      (arguments[ARGUMENT_RECORD_COLLECTION_ENABLED] as? Boolean)?.let { isEnabled ->
        dataroid.config.apmConfig.isEnabled = isEnabled
      }
      (arguments[ARGUMENT_APM_AUTO_CAPTURE_ENABLED] as? Boolean)?.let { autoCaptureEnabled ->
        dataroid.config.apmConfig.withAutoCollectingEnabled(autoCaptureEnabled)
      }
      (arguments[ARGUMENT_RECORD_STORAGE_LIMIT] as? Int)?.let { storageLimit ->
        dataroid.config.apmConfig.storageLimit = storageLimit
      }
      dataroid.logExternal(3, "Flutter", "handleUpdateApmConfig: completed")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleUpdateApmConfig: failed with error: ${e.message}")
      result.error("UPDATE_APM_CONFIG_ERROR", e.message, null)
    }
  }

  private fun handleUpdateScreenTrackingConfig(arguments: Map<String, Any>, result: Result) {
    val enabled = arguments[ARGUMENT_ENABLED] as? Boolean
    try {
      enabled?.let { isEnabled ->
        dataroid.config.screenTrackingConfig.setEnabled(isEnabled)
      }
      dataroid.logExternal(3, "Flutter", "handleUpdateScreenTrackingConfig: completed with enabled=$enabled")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleUpdateScreenTrackingConfig: failed with error: ${e.message}")
      result.error("UPDATE_SCREEN_TRACKING_CONFIG_ERROR", e.message, null)
    }
  }

  private fun handleUpdateComponentInteractionConfig(arguments: Map<String, Any>, result: Result) {
    try {
      val config = dataroid.config.componentInteractionConfig
      
      (arguments[ARGUMENT_AUTO_COLLECTING_ENABLED] as? Boolean)?.let { autoCollectingEnabled ->
        config.withAutoCollectingEnabled(autoCollectingEnabled)
      }
      
      (arguments[ARGUMENT_DEBOUNCE_THRESHOLD] as? Int)?.let { threshold ->
        config.withDebounceThreshold(threshold)
      }
      
      dataroid.logExternal(3, "Flutter", "handleUpdateComponentInteractionConfig: completed")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleUpdateComponentInteractionConfig: failed with error: ${e.message}")
      result.error("UPDATE_COMPONENT_INTERACTION_CONFIG_ERROR", e.message, null)
    }
  }

  private fun handleUpdateScreenInteractionConfig(arguments: Map<String, Any>, result: Result) {
    try {
      val config = dataroid.config.screenInteractionConfig
      
      (arguments[ARGUMENT_AUTO_COLLECTING_ENABLED] as? Boolean)?.let { autoCollectingEnabled ->
        config.withAutoCollectingEnabled(autoCollectingEnabled)
      }
      
      dataroid.logExternal(3, "Flutter", "handleUpdateScreenInteractionConfig: completed")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleUpdateScreenInteractionConfig: failed with error: ${e.message}")
      result.error("UPDATE_SCREEN_INTERACTION_CONFIG_ERROR", e.message, null)
    }
  }

  private fun handleUpdateInboxConfig(arguments: Map<String, Any>, result: Result) {
    try {
      (arguments[ARGUMENT_ENABLED] as? Boolean)?.let { enabled ->
        dataroid.config.dataroidInboxConfig.isEnabled = enabled
      }
      
      (arguments[ARGUMENT_STORAGE_LIMIT] as? Int)?.let { limit ->
        dataroid.config.dataroidInboxConfig.storageLimit = limit
      }
      
      dataroid.logExternal(3, "Flutter", "handleUpdateInboxConfig: completed")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleUpdateInboxConfig: failed with error: ${e.message}")
      result.error("UPDATE_INBOX_CONFIG_ERROR", e.message, null)
    }
  }

  private fun handleSetEventCollectionEnabled(arguments: Map<String, Any>, result: Result) {
    val enabled = arguments[ARGUMENT_ENABLED] as? Boolean
    try {
      enabled?.let { en ->
        dataroid.config.setEventCollectingEnabled(en)
      }
      dataroid.logExternal(3, "Flutter", "handleSetEventCollectionEnabled: completed with enabled=$enabled")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleSetEventCollectionEnabled: failed with error: ${e.message}")
      result.error("SET_EVENT_COLLECTION_ENABLED_ERROR", e.message, null)
    }
  }

  private fun handleSetEventStorageLimit(arguments: Map<String, Any>, result: Result) {
    val limit = arguments[ARGUMENT_LIMIT] as? Int
    try {
      limit?.let { l ->
        dataroid.config.eventStorageLimit = l
      }
      dataroid.logExternal(3, "Flutter", "handleSetEventStorageLimit: completed with limit=$limit")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleSetEventStorageLimit: failed with error: ${e.message}")
      result.error("SET_EVENT_STORAGE_LIMIT_ERROR", e.message, null)
    }
  }

  private fun parseLong(value: Any?): Long? {
    if (value == null) {
      return null
    }
    val longValue = value as? Long
    val intValue = (value as? Int)?.toLong()
    return longValue ?: intValue
  }

  private fun parseErrorType(value: Int?): String? {
    if (value == null) {
      return null
    }
    when (value) {
      0 -> return NetworkErrorErrorType.UNKNOWN
      1 -> return NetworkErrorErrorType.NO_CONNECTION_ERROR
      2 -> return NetworkErrorErrorType.SSL_ERROR
      4 -> return NetworkErrorErrorType.TIMEOUT_ERROR
      8 -> return NetworkErrorErrorType.AUTH_FAILURE_ERROR
      16 -> return NetworkErrorErrorType.NETWORK_ERROR
      32 -> return NetworkErrorErrorType.PARSE_ERROR
      64 -> return NetworkErrorErrorType.SERVER_ERROR
      128 -> return NetworkErrorErrorType.CANCELLED_ERROR
    }
    return null
  }

  @Throws(MissingArgumentException::class)
  private fun parseProduct(productArguments: Map<String, Any>): Product {
    val id = productArguments[ARGUMENT_ID] as? String ?: throw MissingArgumentException()
    val name = productArguments[ARGUMENT_NAME] as? String ?: throw MissingArgumentException()
    val quantity = productArguments[ARGUMENT_QUANTITY] as? Int ?: throw MissingArgumentException()
    val price = productArguments[ARGUMENT_PRICE] as? Double ?: throw MissingArgumentException()
    val currency = productArguments[ARGUMENT_CURRENCY] as? String ?: throw MissingArgumentException()
    val productBuilder = Product.Builder.newInstance(id, name, quantity, BigDecimal(price),
            currency)
            ?: throw MissingArgumentException()
    (productArguments[ARGUMENT_VARIANT] as? String)?.let {
      productBuilder.setVariant(it)
    }
    (productArguments[ARGUMENT_DESCRIPTION] as? String)?.let { it ->
      productBuilder.setProductDescription(it)
    }
    (productArguments[ARGUMENT_BRAND] as? String)?.let {
      productBuilder.setBrand(it)
    }
    (productArguments[ARGUMENT_CATEGORY] as? String)?.let {
      productBuilder.setCategory(it)
    }
    return productBuilder.build()
  }

  private fun putCustomAttributes(arguments: Map<String, Any>, attributes: AttributeBuilder<*>) {
    (arguments[ARGUMENT_DATE_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      var value = parseLong(it.value)

      if (value != null) {
        val date = Date(Timestamp(value).time)
        attributes.put(it.key, date)
      }
    }

    (arguments[ARGUMENT_INT_LIST_ATTRIBUTES] as? Map<String, Any?>)?.forEach {
      val typedVal = (it.value as? List<Int>) ?: listOf<Int>()
      var value = IntArray(typedVal.size)
      for (i in typedVal.indices) {
        value[i] = typedVal[i]
      }
      attributes.put(it.key, value)

    }

    (arguments[ARGUMENT_STRING_LIST_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      val typedVal = (it.value as? List<String>) ?: listOf<String>()
      var value = Array<String?>(typedVal.size) {null}
      for (i in typedVal.indices) {
        value[i] = typedVal[i]
      }
      attributes.put(it.key, value)
    }

    (arguments[ARGUMENT_ATTRIBUTES] as? Map<String, Any>)?.forEach {
      when(it.value) {
        is Int -> attributes.put(it.key, it.value as Int?)
        is Double -> attributes.put(it.key, it.value as Double?)
        is Float -> attributes.put(it.key, it.value as Float?)
        is Boolean -> attributes.put(it.key, it.value as Boolean?)
        is String -> attributes.put(it.key, it.value as String?)
        else -> {}
      }
    }
  }

  private fun registerContextTriggerListener() {
    
    subscriber = object : Subscriber<CtxTriggerResult> {
      override fun onNext(result: CtxTriggerResult) {
        handleContextTriggered(result)
      }
    }
    
    dataroid.ctxTriggerClient.subscribeToResults(subscriber)
  }
  
  private fun unregisterContextTriggerListener() {
      dataroid.ctxTriggerClient.unsubscribeFromResults(subscriber)
  }
  
  private fun handleContextTriggered(result: CtxTriggerResult) {
    val contextTriggerId = result.contextTriggerId
    val machineOutput = result.machineOutput
    
    val attributes = HashMap<String, Any>()
    machineOutput?.forEach { pair ->
      val value = pair.second
      // Convert various Java types to Flutter-compatible types
      when (value) {
        is BigDecimal -> attributes[pair.first] = value.toDouble()
        is Array<*> -> {
          // Convert any array to a list
          attributes[pair.first] = value.filterNotNull().toList()
        }
        is IntArray -> attributes[pair.first] = value.toList()
        is LongArray -> attributes[pair.first] = value.toList()
        is FloatArray -> attributes[pair.first] = value.toList()
        is DoubleArray -> attributes[pair.first] = value.toList()
        is BooleanArray -> attributes[pair.first] = value.toList()
        null -> attributes[pair.first] = ""
        else -> attributes[pair.first] = value
      }
    }
    
    val arguments = HashMap<String, Any>()
    arguments[ARGUMENT_CONTEXT_TRIGGER_ID] = contextTriggerId
    arguments[ARGUMENT_CONTEXT_TRIGGER_ATTRIBUTES] = attributes
    
    channel?.invokeMethod(METHOD_CONTEXT_TRIGGERED, arguments)
  }

  @Throws(MissingArgumentException::class)
  private fun handleCollectNotificationOpenEvent(arguments: Map<String, Any>, result: Result) {
    try {
      val backgroundPushDataMap = arguments[ARGUMENT_BACKGROUND_PUSH_DATA] as? Map<String, Any>
      if (backgroundPushDataMap == null) {
        dataroid.logExternal(6, "Flutter", "handleCollectNotificationOpenEvent: missing backgroundPushData")
        result.error("MISSING_ARGUMENT", "backgroundPushData is null", null)
        return
      }

      val notificationId = backgroundPushDataMap["notificationId"] as? String
      val scheduleId = backgroundPushDataMap["scheduleId"] as? String
      
      val parametersRaw = backgroundPushDataMap["parameters"] as? Map<*, *> ?: emptyMap<String, String>()
      val parameters = parametersRaw.entries.associate { 
        (it.key as? String ?: "") to (it.value as? String ?: "") 
      }.filterKeys { it.isNotEmpty() }
      
      val dynamicStringAttributesRaw = backgroundPushDataMap["dynamicStringAttributes"] as? Map<*, *> ?: emptyMap<String, String>()
      val dynamicStringAttributes = dynamicStringAttributesRaw.entries.associate { 
        (it.key as? String ?: "") to (it.value as? String ?: "") 
      }.filterKeys { it.isNotEmpty() }
      
      val dynamicIntegerAttributesRaw = backgroundPushDataMap["dynamicIntegerAttributes"] as? Map<*, *> ?: emptyMap<String, Int>()
      val dynamicIntegerAttributes = dynamicIntegerAttributesRaw.entries.mapNotNull { entry ->
        val key = entry.key as? String
        val value = entry.value as? Int ?: (entry.value as? Number)?.toInt()
        if (key != null && value != null) key to value else null
      }.toMap()
      
      val dynamicBooleanAttributesRaw = backgroundPushDataMap["dynamicBooleanAttributes"] as? Map<*, *> ?: emptyMap<String, Boolean>()
      val dynamicBooleanAttributes = dynamicBooleanAttributesRaw.entries.mapNotNull { entry ->
        val key = entry.key as? String
        val value = entry.value as? Boolean
        if (key != null && value != null) key to value else null
      }.toMap()

      val backgroundPushData = BackgroundPushData(
        notificationId,
        scheduleId,
        HashMap(parameters),
        dynamicStringAttributes,
        dynamicIntegerAttributes,
        dynamicBooleanAttributes
      )
      
      dataroid.collectNotificationOpenEvent(backgroundPushData)
      dataroid.logExternal(3, "Flutter", "handleCollectNotificationOpenEvent: completed with background push data $backgroundPushData")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleCollectNotificationOpenEvent: failed with error: ${e.message}")
      result.error("NOTIFICATION_OPEN_EVENT_ERROR", "Failed to parse BackgroundPushData: ${e.message}", e.toString())
    }
  }

  @Throws(MissingArgumentException::class)
  private fun handleLogExternal(arguments: Map<String, Any>, result: Result) {
    try {
      val logLevel = arguments[ARGUMENT_LOG_LEVEL] as? Int ?: 0 // default to NO_LOG
      val source = arguments[ARGUMENT_LOG_SOURCE] as? String ?: "Flutter"
      val message = arguments[ARGUMENT_LOG_MESSAGE] as? String ?: ""
      
      dataroid.logExternal(logLevel, source, message)
      result.success(true)
    } catch (e: Exception) {
      result.error("LOG_ERROR", "Failed to log message: ${e.message}", null)
    }
  }

  private fun handleCollectNotificationDismissedEvent(arguments: Map<String, Any>, result: Result) {
    try {
      val backgroundPushDataMap = arguments[ARGUMENT_BACKGROUND_PUSH_DATA] as? Map<String, Any>
      if (backgroundPushDataMap == null) {
        dataroid.logExternal(6, "Flutter", "handleCollectNotificationDismissedEvent: missing backgroundPushData")
        result.error("MISSING_ARGUMENT", "backgroundPushData is null", null)
        return
      }

      val notificationId = backgroundPushDataMap["notificationId"] as? String
      val scheduleId = backgroundPushDataMap["scheduleId"] as? String
      
      val parametersRaw = backgroundPushDataMap["parameters"] as? Map<*, *> ?: emptyMap<String, String>()
      val parameters = parametersRaw.entries.associate { 
        (it.key as? String ?: "") to (it.value as? String ?: "") 
      }.filterKeys { it.isNotEmpty() }
      
      val dynamicStringAttributesRaw = backgroundPushDataMap["dynamicStringAttributes"] as? Map<*, *> ?: emptyMap<String, String>()
      val dynamicStringAttributes = dynamicStringAttributesRaw.entries.associate { 
        (it.key as? String ?: "") to (it.value as? String ?: "") 
      }.filterKeys { it.isNotEmpty() }
      
      val dynamicIntegerAttributesRaw = backgroundPushDataMap["dynamicIntegerAttributes"] as? Map<*, *> ?: emptyMap<String, Int>()
      val dynamicIntegerAttributes = dynamicIntegerAttributesRaw.entries.mapNotNull { entry ->
        val key = entry.key as? String
        val value = entry.value as? Int ?: (entry.value as? Number)?.toInt()
        if (key != null && value != null) key to value else null
      }.toMap()
      
      val dynamicBooleanAttributesRaw = backgroundPushDataMap["dynamicBooleanAttributes"] as? Map<*, *> ?: emptyMap<String, Boolean>()
      val dynamicBooleanAttributes = dynamicBooleanAttributesRaw.entries.mapNotNull { entry ->
        val key = entry.key as? String
        val value = entry.value as? Boolean
        if (key != null && value != null) key to value else null
      }.toMap()

      val backgroundPushData = BackgroundPushData(
        notificationId,
        scheduleId,
        HashMap(parameters),
        dynamicStringAttributes,
        dynamicIntegerAttributes,
        dynamicBooleanAttributes
      )
      
      dataroid.collectNotificationDismissedEvent(backgroundPushData)
      dataroid.logExternal(3, "Flutter", "handleCollectNotificationDismissedEvent: completed with background push data $backgroundPushData")
      result.success(true)
    } catch (e: Exception) {
      dataroid.logExternal(6, "Flutter", "handleCollectNotificationDismissedEvent: failed with error: ${e.message}")
      result.error("NOTIFICATION_DISMISSED_EVENT_ERROR", "Failed to parse BackgroundPushData: ${e.message}", e.toString())
    }
  }

  companion object {

    private var pluginInstance: DataroidSdkAndroidPlugin? = null
    private val pendingNotificationActions: Queue<NotificationCallbackResult> = LinkedList()
    lateinit var dataroid: Dataroid
    
    fun initialize(context: Context, config: DataroidPluginConfig) : Dataroid {
      val builder = Dataroid.Builder(context as Application, config.sdkKey)
              .withUrl(config.serverURL)
              .withFramework("FLUTTER")

      config.apply {
        languageCode?.let { builder.withLanguage(Locale(it)) }
        eventCollectionEnabled?.let {
          builder.withEventCollectingEnabled(it)
        }
        eventStorageLimit?.let { builder.withEventStorageLimit(it) }


        val logConfig = DataroidLogConfig("LogTag").also { config ->
          logLevel?.let { config.withLogLevel(it.level) }

          val logDirectory: File? = context
            .getExternalFilesDir(null)

          isFileLoggingEnabled?.let {
            if (logDirectory != null) {
              config.withFileLogging(logDirectory, "AppConnectLog")
            }
          }
        }

        builder.withLogConfig(logConfig)

        // Flutter owns automatic collection through DataroidAutoCapture,
        // DataroidNavigatorObserver, and network interceptors. Disable native
        // auto-collection to keep Android aligned with iOS and avoid duplicate
        // screen, interaction, and APM events.
        val screenTrackingConfig = DataroidScreenTrackingConfig()
        isScreenTrackingEnabled?.let {
          screenTrackingConfig.setEnabled(it)
        }
        screenTrackingConfig.isAutoCollectingEnabled = false
        builder.withScreenTrackingConfig(screenTrackingConfig)
        isInAppMessagingEnabled?.let {
          val inAppMessagingConfig = DataroidInAppMessagingConfig()
          inAppMessagingConfig.isEnabled = it
          builder.withInAppMessagingConfig(inAppMessagingConfig)
        }
        val apmConfig = DataroidAPMConfig().apply {
          isAPMEnabled?.let { withEnabled(it) }
          withAutoCollectingEnabled(false)
        }
        builder.withAPMConfig(apmConfig)

        val screenInteractionConfig = DataroidScreenInteractionConfig()
        screenInteractionConfig.withAutoCollectingEnabled(false)
        builder.withScreenInteractionConfig(screenInteractionConfig)

        val componentInteractionConfig = DataroidComponentInteractionConfig()
            .withAutoCollectingEnabled(false)
        builder.withComponentInteractionConfig(componentInteractionConfig)

        if (!pinningEndpoint.isNullOrEmpty() && !pinningKey.isNullOrEmpty()) {
          val networkConfig = DataroidNetworkConfig();
          val certificatePinningConfig = DataroidCertificatePinningConfig()
          certificatePinningConfig.addCertificate(pinningEndpoint!!, pinningKey!!)
          networkConfig.setCertificatePinning(certificatePinningConfig)
          builder.withNetworkConfig(networkConfig)
        }

        val sessionConfig = DataroidSessionConfig()
        sessionDropDuration?.let {
            sessionConfig.timeout = it.toInt() * 1000
        }
        builder.withSessionConfig(sessionConfig)

        if (snapshot.enabled == true) {
          val allowedPackages = snapshot.allowedPackages ?: arrayOf<String>()
          val snapshotConfig = DataroidSnapshotConfig(*allowedPackages)
              .withEnabled(true)

          snapshot.latency?.let {
              snapshotConfig.withLatencyInMillis(it)
          }

          snapshot.hardwareBitmapSupport?.let {
              snapshotConfig.withHardwareBitmapSupport(it)
          }

          builder.withSnapshotConfig(snapshotConfig)
        } else {
          builder.withSnapshotConfig(DataroidSnapshotConfig(*arrayOf<String>()).withEnabled(false))
        }

      }

      dataroid = builder.build()
      return dataroid
    }
    
    /**
     * Public method to handle custom notification actions.
     * This method can be called even when the Flutter plugin is not attached.
     * If the plugin is not available, the action will be stored and processed later.
     */
    fun handleCustomNotificationAction(result: NotificationCallbackResult) {
      pluginInstance?.let { plugin ->
          // Plugin is available, send immediately
          val arguments: Map<String, Any?> = mapOf(
              ARGUMENT_ACTION_TYPE to result.actionType,
              ARGUMENT_NOTIFICATION_ID to result.notificationId,
              ARGUMENT_ATTRIBUTES to result.attributes
          )
          plugin.channel.invokeMethod(
              METHOD_HANDLE_PUSH_EVENT_ANDROID,
              arguments
          )
      } ?: run {
          // Plugin is not available, store for later processing
          synchronized(pendingNotificationActions) {
              pendingNotificationActions.offer(result)
          }
      }
    }
    
    /**
     * Internal method to process pending notification actions when plugin becomes available
     */
    internal fun processPendingNotificationActions() {
        synchronized(pendingNotificationActions) {
            if (pendingNotificationActions.isNotEmpty()) {
                pluginInstance?.let { plugin ->
                    while (pendingNotificationActions.isNotEmpty()) {
                        val result = pendingNotificationActions.poll()
                        result.let {
                            val arguments: Map<String, Any?> = mapOf(
                                ARGUMENT_ACTION_TYPE to it?.actionType,
                                ARGUMENT_NOTIFICATION_ID to it?.notificationId,
                                ARGUMENT_ATTRIBUTES to it?.attributes
                            )
                            plugin.channel.invokeMethod(
                                METHOD_HANDLE_PUSH_EVENT_ANDROID,
                                arguments
                            )
                        }
                    }
                }
            }
        }
    }

    /**
     * Public method to handle background push notifications.
     * This method converts BackgroundPushData to a proper map structure and sends it to the Flutter side.
     * Ensures the method channel call is executed on the main thread.
     * 
     * @param backgroundPushData The BackgroundPushData object from the Android SDK
     */
    fun handleBackgroundPushReceived(backgroundPushData: BackgroundPushData?) {
        pluginInstance?.let { plugin ->
            // Ensure we're on the main thread for Flutter method channel calls
            Handler(Looper.getMainLooper()).post {
                try {
                    if (backgroundPushData == null) {
                        val arguments: Map<String, Any?> = mapOf(ARGUMENT_PARAMETERS to null)
                        plugin.channel.invokeMethod(
                            METHOD_HANDLE_BACKGROUND_PUSH,
                            arguments
                        )
                        return@post
                    }
                    
                    val parametersMap = mutableMapOf<String, Any>()
                    
                    backgroundPushData.notificationId?.let { notificationId ->
                        parametersMap["notificationId"] = notificationId
                        parametersMap["pushId"] = notificationId
                    }
                    
                    backgroundPushData.scheduleId?.let { scheduleId ->
                        parametersMap["scheduleId"] = scheduleId
                    }
                    
                    parametersMap["parameters"] = backgroundPushData.parameters
                    parametersMap["dynamicStringAttributes"] = backgroundPushData.dynamicStringAttributes
                    parametersMap["dynamicIntegerAttributes"] = backgroundPushData.dynamicIntegerAttributes
                    parametersMap["dynamicBooleanAttributes"] = backgroundPushData.dynamicBooleanAttributes

                    val arguments: Map<String, Any?> = mapOf(ARGUMENT_PARAMETERS to parametersMap)
                    plugin.channel.invokeMethod(
                        METHOD_HANDLE_BACKGROUND_PUSH,
                        arguments
                    )
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }
}

private class MissingArgumentException(): Exception("Missing arguments")