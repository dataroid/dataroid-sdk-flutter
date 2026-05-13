import Flutter
import UIKit
import DataroidSDK

public class SwiftDataroidSdkIosPlugin: NSObject, FlutterPlugin {

    public static var shared: SwiftDataroidSdkIosPlugin?

    private let channel: FlutterMethodChannel
    private var dataroid: Dataroid?
    private let inAppDeeplinkHandler: InAppMessageDeeplinkHandler
    private let inAppSubscriber: InAppMessageSubscriber

    private var customEventAttributes: [String: Attributes] = [:]

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        self.inAppDeeplinkHandler = InAppMessageDeeplinkHandler(channel: channel)
        self.inAppSubscriber = InAppMessageSubscriber(channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            let arguments = call.arguments as? [String: Any] ?? [:]

            guard let dataroid = self.dataroid else {
                result(FlutterError.with("Dataroid must be initialized first!"))
                return
            }

            switch call.method {

            case MethodName.collectCustomEvent:
                self.handleCollectCustomEvent(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.setUser:
                self.handleSetUser(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.clearUser:
                self.handleClearUser(dataroid: dataroid, result: result)

            case MethodName.collectAPMHTTPRecord:
                self.handleCollectAPMHTTPRecord(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.collectAPMNetworkErrorRecord:
                self.handleCollectAPMNetworkRecord(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.addToCart:
                self.handleAddToCart(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.addToWishList:
                self.handleAddToWishList(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.clearCart:
                self.handleClearCart(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.purchase:
                self.handlePurchase(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.removeFromCart:
                self.handleRemoveFromCart(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.search:
                self.handleSearch(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.startCheckout:
                self.handleStartCheckout(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.removeFromWishList:
                self.handleRemoveFromWishList(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.viewCategory:
                self.handleViewCategory(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.viewProduct:
                self.handleViewProduct(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.updateSessionConfig:
                self.handleUpdateSessionConfig(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.updateInAppConfig:
                self.handleUpdateInAppConfig(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.updateApmConfig:
                self.handleUpdateApmConfig(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.updateScreenTrackingConfig:
                self.handleUpdateScreenTrackingConfig(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.setEventCollectionEnabled:
                self.handleSetEventCollectionEnabled(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.setEventStorageLimit:
                self.handleSetEventStorageLimit(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.updateComponentInteractionConfig:
                self.handleUpdateComponentInteractionConfig(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.updateScreenInteractionConfig:
                self.handleUpdateScreenInteractionConfig(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.updateInboxConfig:
                self.handleUpdateInboxConfig(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.enableGeofencing:
                self.handleEnableGeofencing(dataroid: dataroid, result: result)

            case MethodName.disableGeofencing:
                self.handleDisableGeofencing(dataroid: dataroid, result: result)

            case MethodName.updateLanguage:
                self.handleUpdateLanguage(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.collectDeeplink:
                self.handleCollectDeeplink(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.startTracking:
                self.handleStartTracking(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.stopTracking:
                self.handleStopTracking(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.fetchMessages:
                self.handleInboxFetchMessages(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.deleteMessages:
                self.handleInboxDeleteMessages(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.readMessages:
                self.handleInboxReadMessages(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.setSuperAttribute:
                self.handleSetSuperAttribute(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.clearSuperAttribute:
                self.handleClearSuperAttribute(dataroid: dataroid, arguments: arguments, result: result)
                
            case MethodName.getAllSuperAttributes:
                self.handleGetAllSuperAttributes(dataroid: dataroid, result: result)
                
            case MethodName.clearAllSuperAttributes:
                self.handleClearAllSuperAttributes(dataroid: dataroid, result: result)

            case MethodName.collectButtonClickEvent:
                self.handleCollectButtonClickEvent(dataroid: dataroid, arguments: arguments, result: result)
                
            case MethodName.collectTextChangeEvent:
                self.handleCollectTextChangeEvent(dataroid: dataroid, arguments: arguments, result: result)
                
            case MethodName.collectToggleChangeEvent:
                self.handleCollectToggleChangeEvent(dataroid: dataroid, arguments: arguments, result: result)
                
            case MethodName.collectTouchEvent:
                self.handleCollectTouchEvent(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.collectDoubleTapEvent:
                self.handleCollectDoubleTapEvent(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.collectLongPressEvent:
                self.handleCollectLongPressEvent(dataroid: dataroid, arguments: arguments, result: result)

            case MethodName.collectSwipeEvent:
                self.handleCollectSwipeEvent(dataroid: dataroid, arguments: arguments, result: result)
                
            case MethodName.registerContextTriggerListener:
                self.registerContextTriggerListener(dataroid: dataroid)
                result(nil)
                
            case MethodName.unregisterContextTriggerListener:
                self.unregisterContextTriggerListener(dataroid: dataroid)
                result(nil)
                
            case MethodName.logExternal:
                self.handleLogExternal(dataroid: dataroid, arguments: arguments, result: result)
                
            default:
                result(false)
                break
            }
        }
    }

    // MARK: - Component Interaction

    func handleCollectButtonClickEvent(dataroid: Dataroid,
                                       arguments: [String: Any],
                                       result: @escaping FlutterResult) {
        var coordinates : UIViewPixelCoordinate?

        guard let className = arguments[ArgumentName.className] as? String else {
            dataroid.error("[Flutter] handleCollectButtonClickEvent: missing className")
            result(FlutterError.insufficientArguments)
            return
        }

        let label = arguments[ArgumentName.label] as? String
        let accessibilityLabel = arguments[ArgumentName.accessibilityLabel] as? String
        let componentId = arguments[ArgumentName.componentId] as? String

        if let coordinatesList = arguments[ArgumentName.coordinates] as? [String: AnyHashable] {
            guard let left = coordinatesList[ArgumentName.left] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let top = coordinatesList[ArgumentName.top] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let right = coordinatesList[ArgumentName.right] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let bottom = coordinatesList[ArgumentName.bottom] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            coordinates = UIViewPixelCoordinate(frame: convertCoordinatesToCGRect(left: left,
                                                                                  top: top,
                                                                                  right: right,
                                                                                  bottom: bottom))
        }

        var viewLabel : String?
        var viewClass : String?

        if let screenTrackingAttributes = arguments[ArgumentName.screenTrackingAttributes] as? [String: AnyHashable] {
            guard let viewLabelInput = screenTrackingAttributes[ArgumentName.label] as? String else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let viewClassInput = screenTrackingAttributes[ArgumentName.viewClass] as? String else {
                result(FlutterError.insufficientArguments)
                return
            }
            viewLabel = viewLabelInput
            viewClass = viewClassInput
        }

        let buttonAttributes = ButtonTrackingAttributes(
            className: className,
            label: label,
            accessibilityLabel: accessibilityLabel,
            componentId: componentId,
            coordinates: coordinates,
            viewLabel: viewLabel,
            viewClass: viewClass
        )

        dataroid.componentInteraction.collectButtonClick(buttonAttributes)
        dataroid.debug("[Flutter] handleCollectButtonClickEvent: completed with attributes \(buttonAttributes)")
        result(true)
    }

    func handleCollectTextChangeEvent(dataroid: Dataroid,
                                      arguments: [String: Any],
                                      result: @escaping FlutterResult) {
        var coordinates : UIViewPixelCoordinate?
        
        guard let className = arguments[ArgumentName.className] as? String else {
            dataroid.error("[Flutter] handleCollectTextChangeEvent: missing className")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let value = arguments[ArgumentName.value] as? String else {
            dataroid.error("[Flutter] handleCollectTextChangeEvent: missing value")
            result(FlutterError.insufficientArguments)
            return
        }

        let placeholder = arguments[ArgumentName.placeholder] as? String
        let accessibilityLabel = arguments[ArgumentName.accessibilityLabel] as? String
        let componentId = arguments[ArgumentName.componentId] as? String

        if let coordinatesList = arguments[ArgumentName.coordinates] as? [String: AnyHashable] {
            guard let left = coordinatesList[ArgumentName.left] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let top = coordinatesList[ArgumentName.top] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let right = coordinatesList[ArgumentName.right] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let bottom = coordinatesList[ArgumentName.bottom] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            coordinates = UIViewPixelCoordinate(frame: convertCoordinatesToCGRect(left: left,
                                                                                  top: top,
                                                                                  right: right,
                                                                                  bottom: bottom))
        }

        var viewLabel: String?
        var viewClass: String?

        if let screenTrackingAttributes = arguments[ArgumentName.screenTrackingAttributes] as? [String: AnyHashable] {
            guard let viewLabelInput = screenTrackingAttributes[ArgumentName.label] as? String else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let viewClassInput = screenTrackingAttributes[ArgumentName.viewClass] as? String else {
                result(FlutterError.insufficientArguments)
                return
            }
            viewLabel = viewLabelInput
            viewClass = viewClassInput
        }

        let textFieldAttributes = TextFieldTrackingAttributes(
            className: className,
            value: value,
            placeholder: placeholder,
            accessibilityLabel: accessibilityLabel,
            componentId: componentId,
            coordinates: coordinates,
            viewLabel: viewLabel,
            viewClass: viewClass
        )

        dataroid.componentInteraction.collectTextChange(textFieldAttributes)
        dataroid.debug("[Flutter] handleCollectTextChangeEvent: completed with attributes \(textFieldAttributes)")
        result(true)
    }
    
    func handleCollectToggleChangeEvent(dataroid: Dataroid,
                                        arguments: [String: Any],
                                        result: @escaping FlutterResult) {
        var coordinates : UIViewPixelCoordinate?
        
        guard let className = arguments[ArgumentName.className] as? String else {
            dataroid.error("[Flutter] handleCollectToggleChangeEvent: missing className")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let isChecked = arguments[ArgumentName.value] as? Bool else {
            dataroid.error("[Flutter] handleCollectToggleChangeEvent: missing value")
            result(FlutterError.insufficientArguments)
            return
        }

        let accessibilityLabel = arguments[ArgumentName.accessibilityLabel] as? String
        let componentId = arguments[ArgumentName.componentId] as? String

        if let coordinatesList = arguments[ArgumentName.coordinates] as? [String: AnyHashable] {
            guard let left = coordinatesList[ArgumentName.left] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let top = coordinatesList[ArgumentName.top] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let right = coordinatesList[ArgumentName.right] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let bottom = coordinatesList[ArgumentName.bottom] as? Int else {
                result(FlutterError.insufficientArguments)
                return
            }
            coordinates = UIViewPixelCoordinate(frame: convertCoordinatesToCGRect(left: left,
                                                                                  top: top,
                                                                                  right: right,
                                                                                  bottom: bottom))
        }

        var viewLabel : String?
        var viewClass : String?

        if let screenTrackingAttributes = arguments[ArgumentName.screenTrackingAttributes] as? [String: AnyHashable] {
            guard let viewLabelInput = screenTrackingAttributes[ArgumentName.label] as? String else {
                result(FlutterError.insufficientArguments)
                return
            }
            guard let viewClassInput = screenTrackingAttributes[ArgumentName.viewClass] as? String else {
                result(FlutterError.insufficientArguments)
                return
            }
            viewLabel = viewLabelInput
            viewClass = viewClassInput
        }

        let switchButtonAttributes = SwitchButtonTrackingAttributes(
            className: className,
            isChecked: isChecked,
            accessibilityLabel: accessibilityLabel,
            componentId: componentId,
            coordinates: coordinates,
            viewLabel: viewLabel,
            viewClass: viewClass
        )

        dataroid.componentInteraction.collectToggleChange(switchButtonAttributes)
        dataroid.debug("[Flutter] handleCollectToggleChangeEvent: completed with attributes \(switchButtonAttributes)")
        result(true)
    }
    
    func convertCoordinatesToCGRect(left: Int, top: Int, right: Int, bottom: Int) -> CGRect {
        return CGRect(x: left, y: bottom, width: right - left, height: top - bottom)
    }
    
    // MARK: - Screen Tracking

    func handleCollectTouchEvent(dataroid: Dataroid,
                                 arguments: [String: Any],
                                 result: @escaping FlutterResult) {
        var viewLabel : String?
        var viewClass : String?

        if let screenTrackingAttributes = arguments[ArgumentName.screenTrackingAttributes] as? [String: AnyHashable] {
            guard let viewLabelInput = screenTrackingAttributes[ArgumentName.label] as? String else {
                dataroid.error("[Flutter] handleCollectTouchEvent: missing screen tracking label")
                result(FlutterError.insufficientArguments)
                return
            }
            guard let viewClassInput = screenTrackingAttributes[ArgumentName.viewClass] as? String else {
                dataroid.error("[Flutter] handleCollectTouchEvent: missing screen tracking viewClass")
                result(FlutterError.insufficientArguments)
                return
            }
            viewLabel = viewLabelInput
            viewClass = viewClassInput
        }
        
        guard let touchPointData = arguments[ArgumentName.touchPoint] as? [String: Any] else {
            dataroid.error("[Flutter] handleCollectTouchEvent: missing touchPoint")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let touchPointX = touchPointData[ArgumentName.x] as? Int else {
            dataroid.error("[Flutter] handleCollectTouchEvent: missing touchPoint x")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let touchPointY = touchPointData[ArgumentName.y] as? Int else {
            dataroid.error("[Flutter] handleCollectTouchEvent: missing touchPoint y")
            result(FlutterError.insufficientArguments)
            return
        }
        
        let touchPoint = TouchPoint(point: CGPoint(x: touchPointX, y: touchPointY))
        let tapAttributes = TapTrackingAttributes(
            touchPoint: touchPoint,
            viewLabel: viewLabel,
            viewClass: viewClass
        )

        dataroid.screenInteraction.collectTouch(tapAttributes)
        dataroid.debug("[Flutter] handleCollectTouchEvent: completed with attributes \(tapAttributes)")
        result(true)
    }
    
    func handleCollectDoubleTapEvent(dataroid: Dataroid,
                                     arguments: [String: Any],
                                     result: @escaping FlutterResult) {
        var viewLabel : String?
        var viewClass : String?

        if let screenTrackingAttributes = arguments[ArgumentName.screenTrackingAttributes] as? [String: AnyHashable] {
            guard let viewLabelInput = screenTrackingAttributes[ArgumentName.label] as? String else {
                dataroid.error("[Flutter] handleCollectDoubleTapEvent: missing screen tracking label")
                result(FlutterError.insufficientArguments)
                return
            }
            guard let viewClassInput = screenTrackingAttributes[ArgumentName.viewClass] as? String else {
                dataroid.error("[Flutter] handleCollectDoubleTapEvent: missing screen tracking viewClass")
                result(FlutterError.insufficientArguments)
                return
            }
            viewLabel = viewLabelInput
            viewClass = viewClassInput
        }
        
        guard let touchPointData = arguments[ArgumentName.touchPoint] as? [String: Any] else {
            dataroid.error("[Flutter] handleCollectDoubleTapEvent: missing touchPoint")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let touchPointX = touchPointData[ArgumentName.x] as? Int else {
            dataroid.error("[Flutter] handleCollectDoubleTapEvent: missing touchPoint x")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let touchPointY = touchPointData[ArgumentName.y] as? Int else {
            dataroid.error("[Flutter] handleCollectDoubleTapEvent: missing touchPoint y")
            result(FlutterError.insufficientArguments)
            return
        }
        
        let touchPoint = TouchPoint(point: CGPoint(x: touchPointX, y: touchPointY))
        let doubleTapAttributes = DoubleTapTrackingAttributes(
            touchPoint: touchPoint,
            viewLabel: viewLabel,
            viewClass: viewClass
        )

        dataroid.screenInteraction.collectDoubleTap(doubleTapAttributes)
        dataroid.debug("[Flutter] handleCollectDoubleTapEvent: completed with attributes \(doubleTapAttributes)")
        result(true)
    }

    func handleCollectLongPressEvent(dataroid: Dataroid,
                                     arguments: [String: Any],
                                     result: @escaping FlutterResult) {
        var viewLabel : String?
        var viewClass : String?

        if let screenTrackingAttributes = arguments[ArgumentName.screenTrackingAttributes] as? [String: AnyHashable] {
            guard let viewLabelInput = screenTrackingAttributes[ArgumentName.label] as? String else {
                dataroid.error("[Flutter] handleCollectLongPressEvent: missing screen tracking label")
                result(FlutterError.insufficientArguments)
                return
            }
            guard let viewClassInput = screenTrackingAttributes[ArgumentName.viewClass] as? String else {
                dataroid.error("[Flutter] handleCollectLongPressEvent: missing screen tracking viewClass")
                result(FlutterError.insufficientArguments)
                return
            }
            viewLabel = viewLabelInput
            viewClass = viewClassInput
        }
        
        guard let touchPointData = arguments[ArgumentName.touchPoint] as? [String: Any] else {
            dataroid.error("[Flutter] handleCollectLongPressEvent: missing touchPoint")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let touchPointX = touchPointData[ArgumentName.x] as? Int else {
            dataroid.error("[Flutter] handleCollectLongPressEvent: missing touchPoint x")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let touchPointY = touchPointData[ArgumentName.y] as? Int else {
            dataroid.error("[Flutter] handleCollectLongPressEvent: missing touchPoint y")
            result(FlutterError.insufficientArguments)
            return
        }
        
        let touchPoint = TouchPoint(point: CGPoint(x: touchPointX, y: touchPointY))
        let longPressAttributes = LongPressTrackingAttributes(
            touchPoint: touchPoint,
            viewLabel: viewLabel,
            viewClass: viewClass
        )

        dataroid.screenInteraction.collectLongPress(longPressAttributes)
        dataroid.debug("[Flutter] handleCollectLongPressEvent: completed with \(longPressAttributes)")
        result(true)
    }
    
    func handleCollectSwipeEvent(dataroid: Dataroid,
                                 arguments: [String: Any],
                                 result: @escaping FlutterResult) {
        var viewLabel : String?
        var viewClass : String?

        if let screenTrackingAttributes = arguments[ArgumentName.screenTrackingAttributes] as? [String: AnyHashable] {
            guard let viewLabelInput = screenTrackingAttributes[ArgumentName.label] as? String else {
                dataroid.error("[Flutter] handleCollectSwipeEvent: missing screen tracking label")
                result(FlutterError.insufficientArguments)
                return
            }
            guard let viewClassInput = screenTrackingAttributes[ArgumentName.viewClass] as? String else {
                dataroid.error("[Flutter] handleCollectSwipeEvent: missing screen tracking viewClass")
                result(FlutterError.insufficientArguments)
                return
            }
            viewLabel = viewLabelInput
            viewClass = viewClassInput
        }
        
        guard let swipePoints = arguments[ArgumentName.swipePoints] as? [String: Any] else {
            dataroid.error("[Flutter] handleCollectSwipeEvent: missing swipePoints")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let startPointData = swipePoints[ArgumentName.start] as? [String: Any] else {
            dataroid.error("[Flutter] handleCollectSwipeEvent: missing start point")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let endPointData = swipePoints[ArgumentName.end] as? [String: Any] else {
            dataroid.error("[Flutter] handleCollectSwipeEvent: missing end point")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let startPointX = startPointData[ArgumentName.x] as? Int else {
            dataroid.error("[Flutter] handleCollectSwipeEvent: missing start point x")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let startPointY = startPointData[ArgumentName.y] as? Int else {
            dataroid.error("[Flutter] handleCollectSwipeEvent: missing start point y")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let endPointX = endPointData[ArgumentName.x] as? Int else {
            dataroid.error("[Flutter] handleCollectSwipeEvent: missing end point x")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let endPointY = endPointData[ArgumentName.y] as? Int else {
            dataroid.error("[Flutter] handleCollectSwipeEvent: missing end point y")
            result(FlutterError.insufficientArguments)
            return
        }
        
        let startPoint = CGPoint(x: startPointX, y: startPointY)
        let endPoint = CGPoint(x: endPointX, y: endPointY)
        let swipeAttributes = SwipeTrackingAttributes(
            startPoint: startPoint,
            endPoint: endPoint,
            viewLabel: viewLabel,
            viewClass: viewClass
        )

        dataroid.screenInteraction.collectSwipe(swipeAttributes)
        dataroid.debug("[Flutter] handleCollectSwipeEvent: completed with attributes=\(swipeAttributes)")
        result(true)
    }

    // MARK: - Custom events

    func handleCollectCustomEvent(dataroid: Dataroid,
                                  arguments: [String: Any],
                                  result: @escaping FlutterResult) {
        guard let eventName = arguments[ArgumentName.eventName] as? String else {
            dataroid.error("[Flutter] handleCollectCustomEvent: missing eventName")
            result(FlutterError.insufficientArguments)
            return
        }
        
        let attributes = Attributes()
        
        // Handle the main attributes map which contains nested special attributes
        if let attributesMap = arguments[ArgumentName.attributes] as? [String: Any] {
            
            // Extract and process dateAttributes
            if let dateAttrs = attributesMap[ArgumentName.dateAttributes] as? [String: Double] {
                for(key, value) in dateAttrs {
                    let date = Date(timeIntervalSince1970: value / 1000)
                    attributes.addDate(date, forKey: key)
                }
            }
            
            // Extract and process intListAttributes
            if let intListAttrs = attributesMap[ArgumentName.intListAttributes] as? [String: [Int]] {
                for(key, value) in intListAttrs {
                    attributes.addIntArray(value, forKey: key)
                }
            }
            
            // Extract and process stringListAttributes
            if let stringListAttrs = attributesMap[ArgumentName.stringListAttributes] as? [String: [String]] {
                for(key, value) in stringListAttrs {
                    attributes.addStringArray(value, forKey: key)
                }
            }
            
            // Process regular attributes
            if let regularAttrs = attributesMap[ArgumentName.attributes] as? [String: AnyHashable] {
                processAttributes(from: regularAttrs, to: attributes)
            }
        }

        dataroid.collectEvent(name: eventName, attributes: attributes)
        dataroid.debug("[Flutter] handleCollectCustomEvent: completed with eventName=\(eventName), attributes=\(attributes)")
        result(true)
    }

    // MARK: - User

    func handleSetUser(dataroid: Dataroid,
                       arguments: [String: Any],
                       result: @escaping FlutterResult) {
        guard let customerId = arguments[ArgumentName.customerId] as? String else {
            dataroid.error("[Flutter] handleSetUser: missing customerId")
            result(FlutterError.insufficientArguments)
            return
        }

        let user = DataroidUser(userId: customerId)
        user.email = arguments[ArgumentName.email] as? String
        user.phone = arguments[ArgumentName.phone] as? String
        user.nationalId = arguments[ArgumentName.nationalId] as? String
        user.firstName = arguments[ArgumentName.firstName] as? String
        user.lastName = arguments[ArgumentName.lastName] as? String

        if let timeInterval = arguments[ArgumentName.dateOfBirth] as? Double {
            user.dateOfBirth = Date(timeIntervalSince1970: timeInterval / 1000)
        }

        if let genderIndex = arguments[ArgumentName.genderIndex] as? Int,
           let gender = Gender(rawValue: genderIndex) {
            user.gender = gender
        }

        let userAttributes = UserAttributes()
        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: userAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                userAttributes.addDate(date, forKey: key)
            }
        }

        user.attributes = userAttributes
        dataroid.setUser(user)
        dataroid.debug("[Flutter] handleSetUser: completed with userId=\(customerId), attributes=\(userAttributes)")
        result(true)
    }

    func handleClearUser(dataroid: Dataroid, result: @escaping FlutterResult) {
        dataroid.clearUser()
        dataroid.debug("[Flutter] handleClearUser: completed")
        result(true)
    }

    // MARK: - APM

    func handleCollectAPMHTTPRecord(dataroid: Dataroid,
                                    arguments: [String: Any],
                                    result: @escaping FlutterResult) {
        guard let url = arguments[ArgumentName.url] as? String,
              let statusCode = arguments[ArgumentName.statusCode] as? Int,
              let duration = arguments[ArgumentName.duration] as? Double,
              let success = arguments[ArgumentName.success] as? Bool else {
            dataroid.error("[Flutter] handleCollectAPMHTTPRecord: missing required arguments")
            result(FlutterError.insufficientArguments)
            return
        }

        guard let httpMethod = SwiftDataroidSdkIosPlugin.parseHTTPMethod(value: arguments[ArgumentName.method]) else {
            dataroid.error("[Flutter] handleCollectAPMHTTPRecord: invalid HTTP method")
            result(FlutterError.insufficientArguments)
            return
        }

        // For multiple instances add domain
        let record = HTTPCallAttributes(
            url: url,
            method: httpMethod,
            statusCode: statusCode,
            duration: duration,
            success: success
        )
        if let value = arguments[ArgumentName.requestSize] as? Double {
            record.requestSize = value
        }
        if let value = arguments[ArgumentName.responseSize] as? Double {
            record.responseSize = value
        }

        record.errorType = arguments[ArgumentName.errorType] as? String
        record.errorCode = arguments[ArgumentName.errorCode] as? String
        record.errorMessage = arguments[ArgumentName.errorMessage] as? String

        let attributes = APMAttributes()

        if let attributesList = arguments[ArgumentName.customAttributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: attributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                attributes.addDate(date, forKey: key)
            }
        }

        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                attributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                attributes.addStringArray(value, forKey: key)
            }
        }

        record.attributes = attributes
        dataroid.apm.collectHTTPCall(record)
        dataroid.debug("[Flutter] handleCollectAPMHTTPRecord: completed with attributes=\(attributes)")
        result(true)
    }

    func handleCollectAPMNetworkRecord(dataroid: Dataroid,
                                       arguments: [String: Any],
                                       result: @escaping FlutterResult) {
        guard let url = arguments[ArgumentName.url] as? String,
              let duration = arguments[ArgumentName.duration] as? Double,
              let exception = arguments[ArgumentName.exception] as? String else {
            dataroid.error("[Flutter] handleCollectAPMNetworkRecord: missing required arguments")
            result(FlutterError.insufficientArguments)
            return
        }

        guard let httpMethod = SwiftDataroidSdkIosPlugin.parseHTTPMethod(value: arguments[ArgumentName.method]) else {
            dataroid.error("[Flutter] handleCollectAPMNetworkRecord: invalid HTTP method")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let typeIndex = arguments[ArgumentName.type] as? Int else {
            dataroid.error("[Flutter] handleCollectAPMNetworkRecord: missing type")
            result(FlutterError.insufficientArguments)
            return
        }

        let record = NetworkErrorAttributes(
            url: url,
            method: httpMethod,
            duration: duration,
            errorType: NetworkErrorAttributes.ErrorType(rawValue: typeIndex),
            exception: exception
        )

        record.errorMessage = arguments[ArgumentName.message] as? String

        let attributes = APMAttributes()

        if let attributesList = arguments[ArgumentName.customAttributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: attributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                attributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                attributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                attributes.addStringArray(value, forKey: key)
            }
        }

        record.attributes = attributes
        dataroid.apm.collectNetworkError(record)
        dataroid.debug("[Flutter] handleCollectAPMNetworkRecord: completed with attributes: \(attributes)")
        result(true)
    }

    // MARK: - Commerce

    func handleAddToCart(dataroid: Dataroid,
                         arguments: [String: Any],
                         result: @escaping FlutterResult) {
        guard let product = SwiftDataroidSdkIosPlugin.parseProduct(
            arguments: arguments[ArgumentName.product],
            result: result
        ) else {
            dataroid.error("[Flutter] handleAddToCart: missing product")
            result(FlutterError.insufficientArguments)
            return
        }
        //Add domain for multiple instance
        let addToCartAttributes = AddToCardEventAttributes(product: product)
        if let value = arguments[ArgumentName.value] as? Int {
            addToCartAttributes.addValue(Decimal(value))
        }
        if let totalValue = arguments[ArgumentName.totalCartValue] as? Int {
            addToCartAttributes.addTotalCartValue(Decimal(totalValue))
        }
        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: addToCartAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                addToCartAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                addToCartAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                addToCartAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectAddToCard(addToCartAttributes)
        dataroid.debug("[Flutter] handleAddToCart: completed with attributes: \(addToCartAttributes)")
        result(true)
    }

    func handleAddToWishList(dataroid: Dataroid,
                             arguments: [String: Any],
                             result: @escaping FlutterResult) {
        guard let product: Product = SwiftDataroidSdkIosPlugin.parseProduct(
            arguments: arguments[ArgumentName.product],
            result: result
        ) else {
            dataroid.error("[Flutter] handleAddToWishList: missing product")
            result(FlutterError.insufficientArguments)
            return
        }
        //Add domain for multiple instance
        let addToWishListEventAttributes = AddToWishListEventAttributes(product: product)

        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: addToWishListEventAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                addToWishListEventAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                addToWishListEventAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                addToWishListEventAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectAddToWishList(addToWishListEventAttributes)
        dataroid.debug("[Flutter] handleAddToWishList: completed with attributes: \(addToWishListEventAttributes)")
        result(true)
    }

    func handleClearCart(dataroid: Dataroid,
                         arguments: [String: Any],
                         result: @escaping FlutterResult) {
        //Add domain for multiple instance
        let clearCartEventAttributes = ClearCartEventAttributes()
        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: clearCartEventAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                clearCartEventAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                clearCartEventAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                clearCartEventAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectClearCart(clearCartEventAttributes)
        dataroid.debug("[Flutter] handleClearCart: completed with attributes \(clearCartEventAttributes)")
        result(true)
    }

    func handlePurchase(dataroid: Dataroid,
                        arguments: [String: Any],
                        result: @escaping FlutterResult) {
        guard let productsJSONArray = arguments[ArgumentName.products] as? [Any] else {
            dataroid.error("[Flutter] handlePurchase: missing products")
            result(FlutterError.insufficientArguments)
            return
        }
        let products = productsJSONArray.compactMap { SwiftDataroidSdkIosPlugin.parseProduct(arguments: $0, result: result) }

        guard let currency = arguments[ArgumentName.currency] as? String,
              let value = arguments[ArgumentName.value] as? Double,
              let success = arguments[ArgumentName.success] as? Bool else {
            dataroid.error("[Flutter] handlePurchase: missing required arguments")
            result(FlutterError.insufficientArguments)
            return
        }

        //Add domain for multiple instance
        let purchaseEventAttributes = PurchaseEventAttributes(
            currency: currency,
            value: Decimal(value),
            products: products,
            success: success
        )

        if let tax = arguments[ArgumentName.tax] as? Double {
            purchaseEventAttributes.addTax(Decimal(tax))
        }

        if let ship = arguments[ArgumentName.ship] as? Double {
            purchaseEventAttributes.addShip(Decimal(ship))
        }

        if let discount = arguments[ArgumentName.discount] as? Double {
            purchaseEventAttributes.addDiscount(Decimal(discount))
        }

        if let coupon = arguments[ArgumentName.coupon] as? String {
            purchaseEventAttributes.addCoupon(coupon)
        }

        if let trxId = arguments[ArgumentName.trxId] as? String {
            purchaseEventAttributes.addTrxId(trxId)
        }

        if let paymentMethod = arguments[ArgumentName.paymentMethod] as? String {
            purchaseEventAttributes.addPaymentMethod(paymentMethod)
        }

        if let quantity = arguments[ArgumentName.quantity] as? Int {
            purchaseEventAttributes.addQuantity(quantity)
        }

        if let errorCode = arguments[ArgumentName.errorCode] as? String {
            purchaseEventAttributes.addErrorCode(errorCode)
        }

        if let errorMessage = arguments[ArgumentName.errorMessage] as? String {
            purchaseEventAttributes.addErrorMessage(errorMessage)
        }

        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: purchaseEventAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                purchaseEventAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                purchaseEventAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                purchaseEventAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectPurchase(purchaseEventAttributes)
        dataroid.debug("[Flutter] handlePurchase: completed with attributes \(purchaseEventAttributes)")
        result(true)
    }

    func handleRemoveFromCart(dataroid: Dataroid,
                              arguments: [String: Any],
                              result: @escaping FlutterResult) {
        guard let product = SwiftDataroidSdkIosPlugin.parseProduct(
            arguments: arguments[ArgumentName.product],
            result: result
        ) else {
            dataroid.error("[Flutter] handleRemoveFromCart: missing product")
            result(FlutterError.insufficientArguments)
            return
        }
        //Add domain for multiple instance
        let removeFromCartEventAttributes = RemoveFromCartEventAttributes(
            product: product
        )

        if let value = arguments[ArgumentName.value] as? Int {
            removeFromCartEventAttributes.addValue(Decimal(value))
        }
        if let totalValue = arguments[ArgumentName.totalCartValue] as? Int {
            removeFromCartEventAttributes.addTotalCartValue(Decimal(totalValue))
        }
        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: removeFromCartEventAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String : Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                removeFromCartEventAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String : [Int]] {
            for(key, value) in intListAttributes {
                removeFromCartEventAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String : [String]] {
            for(key, value) in stringListAttributes {
                removeFromCartEventAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectRemoveFromCart(removeFromCartEventAttributes)
        dataroid.debug("[Flutter] handleRemoveFromCart: completed with attributes \(removeFromCartEventAttributes)")
        result(true)
    }

    func handleSearch(dataroid: Dataroid,
                      arguments: [String: Any],
                      result: @escaping FlutterResult) {
        guard let query = arguments[ArgumentName.query] as? String else {
            dataroid.error("[Flutter] handleSearch: missing query")
            result(FlutterError.insufficientArguments)
            return
        }

        //Add domain for multiple instance
        let searchAttributes = SearchEventAttributes(query: query)

        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: searchAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                searchAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                searchAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                searchAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectSearch(searchAttributes)
        dataroid.debug("[Flutter] handleSearch: completed with attributes=\(searchAttributes)")
        result(true)
    }

    func handleStartCheckout(dataroid: Dataroid,
                             arguments: [String: Any],
                             result: @escaping FlutterResult) {
        guard let value = arguments[ArgumentName.value] as? Int,
              let currency = arguments[ArgumentName.currency] as? String else {
            dataroid.error("[Flutter] handleStartCheckout: missing required arguments")
            result(FlutterError.insufficientArguments)
            return
        }

        //Add domain for multiple instance
        let startCheckoutEventAttributes = StartCheckoutEventAttributes(
            value: Decimal(value),
            currency: currency
        )

        if let quantity = arguments[ArgumentName.quantity] as? Int {
            startCheckoutEventAttributes.addQuantity(quantity)
        }

        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable]{
            processAttributes(from: attributesList, to: startCheckoutEventAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                startCheckoutEventAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                startCheckoutEventAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                startCheckoutEventAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectStartCheckout(startCheckoutEventAttributes)
        dataroid.debug("[Flutter] handleStartCheckout: completed with attributes: \(startCheckoutEventAttributes)")
        result(true)
    }

    func handleRemoveFromWishList(dataroid: Dataroid,
                                  arguments: [String: Any],
                                  result: @escaping FlutterResult) {
        guard let product = SwiftDataroidSdkIosPlugin.parseProduct(
            arguments: arguments[ArgumentName.product],
            result: result
        ) else {
            dataroid.error("[Flutter] handleRemoveFromWishList: missing product")
            result(FlutterError.insufficientArguments)
            return
        }

        //Add domain for multiple instance
        let removeFromWishListAttributes = RemoveFromWishListEventAttributes(
            product: product
        )

        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: removeFromWishListAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                removeFromWishListAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                removeFromWishListAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                removeFromWishListAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectRemoveFromWishList(removeFromWishListAttributes)
        dataroid.debug("[Flutter] handleRemoveFromWishList: completed with attributes \(removeFromWishListAttributes)")
        result(true)
    }

    func handleViewCategory(dataroid: Dataroid,
                            arguments: [String: Any],
                            result: @escaping FlutterResult) {
        guard let category = arguments[ArgumentName.category] as? String else {
            dataroid.error("[Flutter] handleViewCategory: missing category")
            result(FlutterError.insufficientArguments)
            return
        }

        //Add domain for multiple instance
        let viewCategoryEventAttributes = ViewCategoryEventAttributes(
            category: category
        )

        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: viewCategoryEventAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                viewCategoryEventAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                viewCategoryEventAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                viewCategoryEventAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectViewCategory(viewCategoryEventAttributes)
        dataroid.debug("[Flutter] handleViewCategory: completed with attributes: \(viewCategoryEventAttributes)")
        result(true)
    }

    func handleViewProduct(dataroid: Dataroid,
                           arguments: [String: Any],
                           result: @escaping FlutterResult) {
        guard let product = SwiftDataroidSdkIosPlugin.parseProduct(
            arguments: arguments[ArgumentName.product],
            result: result
        ) else {
            dataroid.error("[Flutter] handleViewProduct: missing product")
            result(FlutterError.insufficientArguments)
            return
        }

        //Add domain for multiple instance
        let viewProductEventAttributes = ViewProductEventAttributes(
            product: product
        )

        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: viewProductEventAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                viewProductEventAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                viewProductEventAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                viewProductEventAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.commerce.collectViewProduct(viewProductEventAttributes)
        dataroid.debug("[Flutter] handleViewProduct: completed with attributes: \(viewProductEventAttributes)")
        result(true)
    }

    // MARK: - Extras

    func handleEnableGeofencing(dataroid: Dataroid, result: @escaping FlutterResult) {
        dataroid.enableGeofencing()
        dataroid.debug("[Flutter] handleEnableGeofencing: completed")
        result(true)
    }

    func handleDisableGeofencing(dataroid: Dataroid, result: @escaping FlutterResult) {
        dataroid.disableGeofencing()
        dataroid.debug("[Flutter] handleDisableGeofencing: completed")
        result(true)
    }

    func handleUpdateLanguage(dataroid: Dataroid,
                              arguments: [String: Any],
                              result: @escaping FlutterResult) {
        guard let languageCode = arguments[ArgumentName.languageCode] as? String else {
            dataroid.error("[Flutter] handleUpdateLanguage: missing languageCode")
            result(FlutterError.insufficientArguments)
            return
        }
        dataroid.updateLanguage(languageCode)
        dataroid.debug("[Flutter] handleUpdateLanguage: completed with languageCode=\(languageCode)")
        result(true)
    }

    // MARK: - Screen Tracking

    func handleStartTracking(dataroid: Dataroid,
                             arguments: [String: Any],
                             result: @escaping FlutterResult) {
        guard let viewClass = arguments[ArgumentName.viewClass] as? String else {
            dataroid.error("[Flutter] handleStartTracking: missing viewClass")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let label = arguments[ArgumentName.label] as? String else {
            dataroid.error("[Flutter] handleStartTracking: missing label")
            result(FlutterError.insufficientArguments)
            return
        }

        let extras = ViewTrackingExtras()
        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: extras)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                extras.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                extras.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                extras.addStringArray(value, forKey: key)
            }
        }

        dataroid.screenTracking.viewStart(viewClass: viewClass, viewLabel: label, extras: extras)
        dataroid.debug("[Flutter] handleStartTracking: completed with viewClass=\(viewClass), label=\(label), extras=\(extras)")
        result(true)
    }

    func handleStopTracking(dataroid: Dataroid,
                            arguments: [String: Any],
                            result: @escaping FlutterResult) {
        guard let viewClass = arguments[ArgumentName.viewClass] as? String else {
            dataroid.error("[Flutter] handleStopTracking: missing viewClass")
            result(FlutterError.insufficientArguments)
            return
        }
        guard let label = arguments[ArgumentName.label] as? String else {
            dataroid.error("[Flutter] handleStopTracking: missing label")
            result(FlutterError.insufficientArguments)
            return
        }

        //TODO: Add view argument
        dataroid.screenTracking.viewStop(viewClass: viewClass, viewLabel: label)
        dataroid.debug("[Flutter] handleStopTracking: completed with viewClass=\(viewClass), label=\(label)")
        result(true)
    }

    // MARK: - Deeplink

    func handleCollectDeeplink(dataroid: Dataroid,
                               arguments: [String: Any],
                               result: @escaping FlutterResult) {
        guard let urlString = arguments[ArgumentName.url] as? String,
              let url = URL(string: urlString) else {
            dataroid.error("[Flutter] handleCollectDeeplink: missing or invalid url")
            result(FlutterError.insufficientArguments)
            return
        }
        // Not used in iOS SDK should be removed when it's removed from there.
        let options: [UIApplication.OpenURLOptionsKey: Any] = [:]

        //Add domain for multiple instance
        let deeplinkAttributes = DeeplinkAttributes(
            url: url,
            options: options
        )

        if let attributesList = arguments[ArgumentName.attributes] as? [String: AnyHashable] {
            processAttributes(from: attributesList, to: deeplinkAttributes)
        }

        if let dateAttributes = arguments[ArgumentName.dateAttributes] as? [String: Double] {
            for(key, value) in dateAttributes {
                let date = Date(timeIntervalSince1970: value / 1000)
                deeplinkAttributes.addDate(date, forKey: key)
            }
        }
        if let intListAttributes = arguments[ArgumentName.intListAttributes] as? [String: [Int]] {
            for(key, value) in intListAttributes {
                deeplinkAttributes.addIntArray(value, forKey: key)
            }
        }
        if let stringListAttributes = arguments[ArgumentName.stringListAttributes] as? [String: [String]] {
            for(key, value) in stringListAttributes {
                deeplinkAttributes.addStringArray(value, forKey: key)
            }
        }

        dataroid.collectDeeplink(deeplinkAttributes)
        dataroid.debug("[Flutter] handleCollectDeeplink: completed with url=\(urlString), attributes \(deeplinkAttributes)")
        result(true)
    }

    // MARK: - App Inbox

    func handleInboxFetchMessages(dataroid: Dataroid,
                                  arguments: [String: Any],
                                  result: @escaping FlutterResult) {
        var query: AppInboxQuery?
        if let queryJSON = arguments[ArgumentName.query] as? [String: Any] {
            query = AppInboxQuery()
            if let type = queryJSON[ArgumentName.messageType] as? Int,
               let messageType = InboxMessageType(rawValue: type) {
                query = query?.messageType(messageType)
            }
            if let status = queryJSON[ArgumentName.messageStatus] as? Int,
               let messageStatus = InboxMessageStatus(rawValue: status) {
                query = query?.status(messageStatus)
            }
            if let isAnonymous = queryJSON[ArgumentName.isAnonymous] as? Bool {
                query = query?.anonymous(isAnonymous)
            }
            if let fromInterval = queryJSON[ArgumentName.from] as? TimeInterval {
                let from = Date(timeIntervalSince1970: fromInterval / 1000)
                query = query?.from(from)
            }
            if let toInterval = queryJSON[ArgumentName.to] as? TimeInterval {
                let to = Date(timeIntervalSince1970: toInterval / 1000)
                query = query?.to(to)
            }
        }

        if let inboxMessages = dataroid.appInbox?.fetchMessages(query: query) {
            let messageList: [[String: Any]] = inboxMessages.map {
                var m: [String: Any] = [ArgumentName.id: "\($0.id ?? -1)",
                                        ArgumentName.messageType: $0.type.rawValue,
                                        ArgumentName.messageStatus: $0.status.rawValue]
                if let date = $0.receivedDate {
                    m[ArgumentName.receivedDate] = date.timeIntervalSince1970 * 1000
                }
                if let date = $0.expirationDate {
                    m[ArgumentName.expirationDate] = date.timeIntervalSince1970 * 1000
                }
                if let customerId = $0.userId {
                    m[ArgumentName.customerId] = customerId
                }
                if let payload = $0.payload {
                    m[ArgumentName.payload] = payload
                }
                
                // Add pushEvent for push notification and geofence message types
                if $0.type == .push || $0.type == .geofence, let pushEvent = $0.pushEvent {
                    var pushEventDict: [String: Any] = [:]
                    
                    if let alert = pushEvent.alert {

                        switch alert {
                            case .rich(title: let title, body: let body):
                            pushEventDict["alert"] = [
                               "title": title ?? "",
                               "body": body ?? ""
                            ]
                            case .plain(let body):
                            pushEventDict["alert"] = [
                                "title": "",
                                "body": body ?? ""
                            ]
                       }
                    }
                    
                    pushEventDict["soundName"] = pushEvent.soundName ?? ""
                    pushEventDict["pushId"] = pushEvent.pushID ?? ""
                    pushEventDict["scheduleId"] = pushEvent.scheduleID ?? ""
                    pushEventDict["mediaURL"] = pushEvent.mediaURL?.absoluteString ?? ""
                    pushEventDict["targetURL"] = pushEvent.targetURL?.absoluteString ?? ""
                    pushEventDict["actionType"] = pushEvent.actionType?.rawValue
                    
                    m["pushEvent"] = pushEventDict
                }
                
                // Add inAppMessage for in-app message types
                if $0.type == .inApp, let inAppMessage = $0.inAppMessage {
                    var inAppDict: [String: Any] = [:]
                    
                    inAppDict["messageId"] = inAppMessage.messageID ?? ""
                    inAppDict["defaultLanguage"] = inAppMessage.defaultLanguage ?? ""
                    
                    // Handle contents
                    if let contents = inAppMessage.contents, !contents.isEmpty {
                        var contentsArray: [[String: Any]] = []
                        
                        for content in contents {
                            var contentDict: [String: Any] = [:]
                            contentDict["language"] = content.language ?? ""
                            contentDict["title"] = content.title ?? ""
                            contentDict["body"] = content.text ?? ""
                            
                            contentsArray.append(contentDict)
                        }
                        
                        inAppDict["contents"] = contentsArray
                    }
                    
                    // Handle custom contents
                    if let customContents = inAppMessage.customContents, !customContents.isEmpty {
                        var customContentsArray: [[String: Any]] = []
                        
                        for content in customContents {
                            var contentDict: [String: Any] = [:]
                            contentDict["language"] = content.language ?? ""
                        
                            
                            customContentsArray.append(contentDict)
                        }
                        
                        inAppDict["customContents"] = customContentsArray
                    }
                    
                    m["inAppMessage"] = inAppDict
                }
                
                // Add actionBasedMessage for action-based message types
                if $0.type == .actionBased, let actionBasedMessage = $0.actionBasedMessage {
                    var actionBasedDict: [String: Any] = [:]
                    
                    actionBasedDict["pushId"] = actionBasedMessage.pushId ?? ""
                    actionBasedDict["sound"] = actionBasedMessage.sound ?? ""
                    actionBasedDict["defaultLanguage"] = actionBasedMessage.defaultLanguage ?? ""
                    actionBasedDict["hostAppLanguage"] = dataroid.config.languageCode ?? ""
                    
                    // Handle content map
                    if let contentMap = actionBasedMessage.contentMap, !contentMap.isEmpty {
                        var contentMapDict: [String: Any] = [:]

                        let actionTypeIndex: Int

                        if let languageKey = actionBasedDict["hostAppLanguage"] as? String, let content = contentMap[languageKey] {
                            switch content.actionType {
                                case "NOTHING": actionTypeIndex = 0
                                case "OPEN_APP": actionTypeIndex = 1
                                case "GO_TO_URL": actionTypeIndex = 2
                                case "GO_TO_DEEPLINK": actionTypeIndex = 3
                                default: actionTypeIndex = 0 // Default case is required in Swift
                            }

                            actionBasedDict["title"] = content.title ?? ""
                            actionBasedDict["text"] = content.text ?? ""
                            actionBasedDict["actionTypeIndex"] = actionTypeIndex
                            actionBasedDict["actionTargetUrl"] = content.actionTargetUrl ?? ""
                            actionBasedDict["imageUrl"] = content.imageUrl ?? ""
                            actionBasedDict["parameters"] = content.parameters ?? [:]
                            m["actionBasedMessage"] = actionBasedDict
                        } else {
                            m["actionBasedMessage"] = nil
                        }
                    } else {
                        m["actionBasedMessage"] = nil
                    }
                }
                
                return m;
            }
            dataroid.debug("[Flutter] handleInboxFetchMessages: completed with \(messageList.count) messages")
            result(messageList);
        } else {
            dataroid.debug("[Flutter] handleInboxFetchMessages: completed with 0 messages")
            result([])
        }
    }

    func handleInboxDeleteMessages(dataroid: Dataroid,
                                   arguments: [String: Any],
                                   result: @escaping FlutterResult) {
        let messageIDList = arguments[ArgumentName.messageIDList] as? [String] ?? []
        let ret = dataroid.appInbox?.deleteMessages(ids: messageIDList.compactMap { Int64($0) })
        dataroid.debug("[Flutter] handleInboxDeleteMessages: completed with \(messageIDList.count) message IDs")
        result(ret ?? false)
    }

    func handleInboxReadMessages(dataroid: Dataroid,
                                 arguments: [String: Any],
                                 result: @escaping FlutterResult) {
        let messageIDList = arguments[ArgumentName.messageIDList] as? [String] ?? []
        let ret = dataroid.appInbox?.readMessages(ids: messageIDList.compactMap { Int64($0) })
        dataroid.debug("[Flutter] handleInboxReadMessages: completed with \(messageIDList.count) message IDs")
        result(ret ?? false)
    }

    // MARK: - Super Attribute
    func handleSetSuperAttribute(dataroid: Dataroid,
                                 arguments: [String: Any],
                                 result: @escaping FlutterResult) {
        guard let key = arguments[ArgumentName.key] as? String else {
            dataroid.error("[Flutter] handleSetSuperAttribute: missing key")
            result(FlutterError.insufficientArguments)
            return
        }

        if let _value = arguments[ArgumentName.attributes] as? AnyHashable {
            safelyAddAttribute(_value, forKey: key,
                addInt: { value, key in dataroid.setSuperAttribute(key: key, intValue: value) },
                addFloat: { value, key in dataroid.setSuperAttribute(key: key, floatValue: value) },
                addDouble: { value, key in dataroid.setSuperAttribute(key: key, doubleValue: value) },
                addBool: { value, key in dataroid.setSuperAttribute(key: key, boolValue: value) },
                addString: { value, key in dataroid.setSuperAttribute(key: key, value: value) }
            )
        }

        if let dateValue = arguments[ArgumentName.dateAttributes] as? Double {
            let date = Date(timeIntervalSince1970: dateValue / 1000)
            dataroid.setSuperAttribute(key: key, dateValue: date)
        }
        dataroid.debug("[Flutter] handleSetSuperAttribute: completed with key=\(key)")
        result(true)
    }

    func handleClearSuperAttribute(dataroid: Dataroid,
                                   arguments: [String: Any],
                                   result: @escaping FlutterResult) {
        guard let key = arguments[ArgumentName.key] as? String else {
            dataroid.error("[Flutter] handleClearSuperAttribute: missing key")
            result(FlutterError.insufficientArguments)
            return
        }
        dataroid.clearSuperAttribute(key: key)
        dataroid.debug("[Flutter] handleClearSuperAttribute: completed with key=\(key)")
        result(true)
    }
    
    func handleGetAllSuperAttributes(dataroid: Dataroid,
                                     result: @escaping FlutterResult) {
        do {
            let superAttributes = dataroid.getAllSuperAttributes()
            var resultDict: [String: Any] = [:]
            
            for (key, value) in superAttributes {
                if let dateValue = value as? Date {
                    resultDict[key] = dateValue.timeIntervalSince1970 * 1000
                } else {
                    resultDict[key] = value
                }
            }
            
            dataroid.debug("[Flutter] handleGetAllSuperAttributes: completed with \(resultDict)")
            result(resultDict)
        } catch {
            dataroid.error("[Flutter] handleGetAllSuperAttributes: failed with error: \(error.localizedDescription)")
            result(FlutterError(code: "GET_ALL_SUPER_ATTRIBUTES_ERROR", 
                               message: error.localizedDescription, 
                               details: nil))
        }
    }
    
    func handleClearAllSuperAttributes(dataroid: Dataroid,
                                       result: @escaping FlutterResult) {
        do {
            dataroid.clearAllSuperAttributes()
            dataroid.debug("[Flutter] handleClearAllSuperAttributes: completed")
            result(true)
        } catch {
            dataroid.error("[Flutter] handleClearAllSuperAttributes: failed with error: \(error.localizedDescription)")
            result(FlutterError(code: "CLEAR_ALL_SUPER_ATTRIBUTES_ERROR", 
                               message: error.localizedDescription, 
                               details: nil))
        }
    }
    
    func handleLogExternal(dataroid: Dataroid,
                          arguments: [String: Any],
                          result: @escaping FlutterResult) {
        guard let logLevel = arguments[ArgumentName.logLevel] as? Int,
              let source = arguments[ArgumentName.logSource] as? String,
              let message = arguments[ArgumentName.logMessage] as? String else {
            result(false)
            return
        }
        
        // Format message with source prefix to match Android behavior
        let formattedMessage = "[\(source)] \(message)"
        
        // Map integer log level to iOS logger methods
        switch logLevel {
        case 2: dataroid.verbose(formattedMessage)
        case 3: dataroid.debug(formattedMessage)
        case 4: dataroid.info(formattedMessage)
        case 5: dataroid.warning(formattedMessage)
        case 6: dataroid.error(formattedMessage)
        default: dataroid.debug(formattedMessage)
        }
        
        result(true)
    }

    // MARK: - Configuration

    func handleUpdateSessionConfig(dataroid: Dataroid,
                                   arguments: [String: Any],
                                   result: @escaping FlutterResult) {
        let sessionDropDuration = arguments[ArgumentName.sessionDropDuration] as? Double
        if let duration = sessionDropDuration {
            dataroid.config.session.timeout = duration
        }
        dataroid.debug("[Flutter] handleUpdateSessionConfig: completed with sessionDropDuration=\(String(describing: sessionDropDuration))")
        result(true)
    }

    func handleUpdateInAppConfig(dataroid: Dataroid,
                                arguments: [String: Any],
                                result: @escaping FlutterResult) {
        let inAppMessagingEnabled = arguments[ArgumentName.inAppMessagingEnabled] as? Bool
        if let enabled = inAppMessagingEnabled {
            dataroid.config.inApp.enabled = enabled
        }
        dataroid.debug("[Flutter] handleUpdateInAppConfig: completed with inAppMessagingEnabled=\(String(describing: inAppMessagingEnabled))")
        result(true)
    }

    func handleUpdateApmConfig(dataroid: Dataroid,
                              arguments: [String: Any],
                              result: @escaping FlutterResult) {
        let recordCollectionEnabled = arguments[ArgumentName.recordCollectionEnabled] as? Bool
        let autoCaptureEnabled = arguments[ArgumentName.apmAutoCaptureEnabled] as? Bool
        let recordStorageLimit = arguments[ArgumentName.recordStorageLimit] as? Int
        
        if let enabled = recordCollectionEnabled {
            dataroid.config.apm.enabled = enabled
        }
        if let autoCapture = autoCaptureEnabled {
            dataroid.config.apm.autoCollectingEnabled = autoCapture
        }
        if let limit = recordStorageLimit {
            dataroid.config.apm.storageLimit = limit
        }
        dataroid.debug("[Flutter] handleUpdateApmConfig: completed with recordCollectionEnabled=\(String(describing: recordCollectionEnabled)), autoCaptureEnabled=\(String(describing: autoCaptureEnabled)), recordStorageLimit=\(String(describing: recordStorageLimit))")
        result(true)
    }

    func handleUpdateScreenTrackingConfig(dataroid: Dataroid,
                                         arguments: [String: Any],
                                         result: @escaping FlutterResult) {
        dataroid.config.screenTracking.autoCollectingEnabled = false

        let enabled = arguments[ArgumentName.enabled] as? Bool
        if let isEnabled = enabled {
            dataroid.config.screenTracking.enabled = isEnabled
        }
        dataroid.debug("[Flutter] handleUpdateScreenTrackingConfig: completed with enabled=\(String(describing: enabled))")
        result(true)
    }

    func handleUpdateComponentInteractionConfig(dataroid: Dataroid,
                                               arguments: [String: Any],
                                               result: @escaping FlutterResult) {
        let autoCollectingEnabled = arguments[ArgumentName.autoCollectingEnabled] as? Bool
        if let enabled = autoCollectingEnabled {
            dataroid.config.componentInteraction.autoCollectingEnabled = enabled
        }
        dataroid.debug("[Flutter] handleUpdateComponentInteractionConfig: completed with autoCollectingEnabled=\(String(describing: autoCollectingEnabled))")
        result(true)
    }

    func handleUpdateScreenInteractionConfig(dataroid: Dataroid,
                                            arguments: [String: Any],
                                            result: @escaping FlutterResult) {
        let autoCollectingEnabled = arguments[ArgumentName.autoCollectingEnabled] as? Bool
        if let enabled = autoCollectingEnabled {
            dataroid.config.screenInteraction.autoCollectingEnabled = enabled
        }
        dataroid.debug("[Flutter] handleUpdateScreenInteractionConfig: completed with autoCollectingEnabled=\(String(describing: autoCollectingEnabled))")
        result(true)
    }

    func handleUpdateInboxConfig(dataroid: Dataroid,
                                arguments: [String: Any],
                                result: @escaping FlutterResult) {
        let enabled = arguments[ArgumentName.enabled] as? Bool
        let storageLimit = arguments[ArgumentName.storageLimit] as? Int
        
        if let isEnabled = enabled {
            dataroid.config.appInbox.enabled = isEnabled
        }
        if let limit = storageLimit {
            dataroid.config.appInbox.storageLimit = limit
        }
        dataroid.debug("[Flutter] handleUpdateInboxConfig: completed with enabled=\(String(describing: enabled)), storageLimit=\(String(describing: storageLimit))")
        result(true)
    }

    func handleSetEventCollectionEnabled(dataroid: Dataroid,
                                         arguments: [String: Any],
                                         result: @escaping FlutterResult) {
        let enabled = arguments[ArgumentName.enabled] as? Bool
        if let isEnabled = enabled {
            dataroid.config.eventCollectingEnabled = isEnabled
        }
        dataroid.debug("[Flutter] handleSetEventCollectionEnabled: completed with enabled=\(String(describing: enabled))")
        result(true)
    }

    func handleSetEventStorageLimit(dataroid: Dataroid,
                                    arguments: [String: Any],
                                    result: @escaping FlutterResult) {
        let limit = arguments[ArgumentName.limit] as? Int
        if let storageLimit = limit {
            dataroid.config.eventStorageLimit = storageLimit
        }
        dataroid.debug("[Flutter] handleSetEventStorageLimit: completed with limit=\(String(describing: limit))")
        result(true)
    }

    // Add Context Trigger related methods
    
    private func registerContextTriggerListener(dataroid: Dataroid) {
        dataroid.contextTriggerListenerDelegate = self
    }
    
    private func unregisterContextTriggerListener(dataroid: Dataroid) {
        dataroid.contextTriggerListenerDelegate = nil
    }
}

extension SwiftDataroidSdkIosPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "dataroid_plugin_flutter",
            binaryMessenger: registrar.messenger()
        )
        shared = SwiftDataroidSdkIosPlugin(channel: channel)

        if let instance = shared {
            registrar.addMethodCallDelegate(instance, channel: channel)
            //registrar.addApplicationDelegate(instance)
        }
    }

    public static func initialize(config: DataroidConfig) {
        guard let instance = shared else {
            print("[ERROR] Flutter plugin is not registered properly!")
            return
        }

        config.frameworkIdentifier = "FLUTTER"
        // Flutter auto-capture (DataroidAutoCapture, DataroidNavigatorObserver,
        // DataroidHttpOverrides) owns these event sources, so disable native
        // auto-collection unconditionally to avoid double-firing. Mirrors the
        // Android plugin and applies to screen-tracking too — previously only
        // the explicit `updateScreenTrackingConfig` call switched it off, so
        // integrators who never called it received duplicate screen events.
        config.componentInteraction.autoCollectingEnabled = false
        config.screenInteraction.autoCollectingEnabled = false
        config.apm.autoCollectingEnabled = false
        config.screenTracking.autoCollectingEnabled = false

        instance.dataroid = Dataroid.initialize(config: config)

        instance.dataroid?.inApp.alertTapListenerDelegate = instance.inAppDeeplinkHandler
        instance.dataroid?.inApp.alertDeeplinkHandlerDelegate = instance.inAppDeeplinkHandler
        instance.dataroid?.inApp.inAppMessageListenerDelegate = instance.inAppSubscriber
    }

    static func parseHTTPMethod(value: Any?) -> HTTPMethod? {
        guard let methodDescription = value as? String,
              !methodDescription.isEmpty else {
            return nil
        }

        var method: HTTPMethod?
        var i = 0
        repeat {
            method = HTTPMethod(rawValue: i)
            if (method?.description.lowercased() == methodDescription.lowercased()) {
                return method
            }
            i += 1
        } while (method != nil)

        return nil
    }

    static func parseProduct(arguments: Any?, result: @escaping FlutterResult) -> Product? {
        
        guard let productData = arguments as? [String: Any] else {
            result(FlutterError.insufficientArguments)
            return nil
        }
        
        guard let id = productData[ArgumentName.id] as? String,
              let name = productData[ArgumentName.name] as? String,
              let quantity = productData[ArgumentName.quantity] as? Int,
              let price = productData[ArgumentName.price] as? Double,
              let currency = productData[ArgumentName.currency] as? String else{
            result(FlutterError.insufficientArguments)
            return nil
        }

        let description = productData[ArgumentName.description] as? String
        let brand = productData[ArgumentName.brand] as? String
        let variant = productData[ArgumentName.variant] as? String
        let category = productData[ArgumentName.category] as? String
        
        let product = Product(
            id: id,
            name: name,
            quantity: quantity,
            price: Decimal(price),
            currency: currency
        )
        
        product?.productDescription = description
        product?.brand = brand
        product?.variant = variant
        product?.category = category
        
        return product
    }

    static func parseAttributes(arguments: [String: Any],
                                key: String = ArgumentName.attributes) -> [(String, Any)] {
        if let attributes = arguments[key] as? [[String: Any]] {
            let items: [(String, Any)] = attributes.compactMap {
                if let attributeKey = $0[ArgumentName.key] as? String,
                   let attributeValue = $0[ArgumentName.value],
                   !attributeKey.isEmpty {
                    return (attributeKey, attributeValue);
                }
                return nil
            }
            return items
        }
        return []
    }
}

// MARK: - Application LifeCycle

public extension SwiftDataroidSdkIosPlugin {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        dataroid?.appListener.didFinishLaunching(with: launchOptions)
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        dataroid?.appListener.didRegisterForRemoteNotifications(with: deviceToken)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotification(response)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        channel.invokeMethod(MethodName.shouldShowPushNotificationInForegroundiOS,
                             arguments: notification.request.content.userInfo) { (result) in
            let shouldShow = (result as? Bool) ?? false
            if shouldShow {
                completionHandler([.alert, .sound])
            } else {
                completionHandler([])
            }
        }
    }

    private func handleNotification(_ response: UNNotificationResponse) {
        dataroid?.appListener.userNotificationCenterDidReceive(response)

        func invoke(pushEvent: PushEvent, info: PushEventInfo, result: @escaping FlutterResult) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150)) {
                let timingInfoIndex: Int
                switch info {
                case .receivedWhenTerminatedAndOpenedTheApp:
                    timingInfoIndex = 0
                case .receivedInBackgroundAndOpenedTheApp:
                    timingInfoIndex = 1
                case .receivedInBackground:
                    timingInfoIndex = 1
                case .receivedInForeground:
                    timingInfoIndex = 3
                @unknown default:
                    timingInfoIndex = 3
                }

                var actionTypeIndex = 0
                if let type = pushEvent.actionType {
                    switch type {
                    case .none:
                        actionTypeIndex = 0
                    case .openApp:
                        actionTypeIndex = 1
                    case .gotoUrl:
                        actionTypeIndex = 2
                    case .gotoDeeplink:
                        actionTypeIndex = 3
                    @unknown default:
                        actionTypeIndex = 0
                    }
                }

                self.channel.invokeMethod(
                    MethodName.handlePushEventiOS,
                    arguments: [ArgumentName.pushEventTiming: timingInfoIndex,
                                ArgumentName.pushActionType: actionTypeIndex,
                                ArgumentName.pushTargetURL: pushEvent.targetURL?.absoluteString ?? "",
                                ArgumentName.pushAttrs: pushEvent.attributes ?? [:]],
                    result: result)
            }
        }

        guard let latest = dataroid?.pushEventManager.latest else {
            return
        }

        // Wait for the system to register Flutter plugin, and user to assign its delegate.
        var retryCounter = 10
        func resultCallBack(_ result: Any?) {
            let isHandled = (result as? Bool) ?? false
            if (!isHandled && retryCounter >= 0) {
                invoke(pushEvent: latest.pushEvent, info: latest.info, result: resultCallBack)
            }
            retryCounter -= 1
        }

        invoke(pushEvent: latest.pushEvent, info: latest.info, result: resultCallBack)
    }
}

extension FlutterError {

    static func with(_ message: String) -> FlutterError {
        return FlutterError(code: "", message: message, details: nil)
    }

    static var insufficientArguments: FlutterError = .with("Insufficient arguments!")
}

final class InAppMessageDeeplinkHandler: InAppMessageAlertDeeplinkHandler, InAppMessageAlertTapListener {

    private let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func shouldHandleDeeplink(deeplink: String?) {
        guard let deeplink = deeplink else {
            return
        }

        channel.invokeMethod(MethodName.handleDeeplink,
                             arguments: [ArgumentName.deeplink: deeplink])
    }

    func didTapAlert(button: InAppMessageButton, content: InAppMessageContent) {
        guard let inAppContent = try? JSONEncoder().encode(content),
              let inAppButton = try? JSONEncoder().encode(button) else {
            return
        }

        channel.invokeMethod(MethodName.handleInAppButtonTap,
                             arguments: [ArgumentName.content: String(data: inAppContent, encoding: .utf8),
                                         ArgumentName.inAppButton: String(data: inAppButton, encoding: .utf8)])
    }

    func didTapCustomButton(button: InAppMessageButton, content: InAppMessageCustomContent) {
        guard let inAppContent = try? JSONEncoder().encode(content),
              let inAppButton = try? JSONEncoder().encode(button) else {
            return
        }

        channel.invokeMethod(MethodName.handleInAppButtonTap,
                             arguments: [ArgumentName.content: String(data: inAppContent, encoding: .utf8),
                                         ArgumentName.inAppButton: String(data: inAppButton, encoding: .utf8)])
    }
}

final class InAppMessageSubscriber: InAppMessageListener {

    private let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func didReceiveInAppMessage(content: InAppMessageContent) {
        guard let value = try? JSONEncoder().encode(content) else {
            return
        }
        channel.invokeMethod(MethodName.handleInApp,
                             arguments: [ArgumentName.content: String(data: value, encoding: .utf8)])
    }

    func didReceiveCustomInAppMessage(content: InAppMessageCustomContent) {
        guard let value = try? JSONEncoder().encode(content) else {
            return
        }

        channel.invokeMethod(MethodName.handleInApp,
                             arguments: [ArgumentName.content: String(data: value, encoding: .utf8)])
    }
}

// MARK: - ContextTriggerListenerDelegate Conformance
extension SwiftDataroidSdkIosPlugin: ContextTriggerListenerDelegate {
    public func contextTriggered(context: TriggeredContext) {
        DispatchQueue.main.async {
            var attributes: [String: Any]? = nil
            if let contextAttributes = context.attributes {
                attributes = contextAttributes
            }
            
            let arguments: [String: Any] = [
                ArgumentName.contextTriggerId: context.contextTriggerId,
                ArgumentName.contextTriggerAttributes: attributes as Any
            ]
            
            self.channel.invokeMethod(MethodName.contextTriggered, arguments: arguments)
        }
    }
}

// MARK: - Type-Safe Attribute Helpers

/// Protocol for types that support adding typed attributes
/// All Dataroid SDK attribute types conform to this pattern
private protocol TypedAttributeContainer {
    @discardableResult
    func addInt(_ value: Int, forKey name: String) -> Self
    @discardableResult
    func addFloat(_ value: Float, forKey name: String) -> Self
    @discardableResult
    func addDouble(_ value: Double, forKey name: String) -> Self
    @discardableResult
    func addBool(_ value: Bool, forKey name: String) -> Self
    @discardableResult
    func addString(_ value: String, forKey name: String) -> Self
}

// Extend base Dataroid SDK attribute types to conform to the protocol
// Note: Only base types are declared here. Subclasses automatically inherit conformance.
extension Attributes: TypedAttributeContainer {}
extension UserAttributes: TypedAttributeContainer {}
extension APMAttributes: TypedAttributeContainer {}
extension ViewTrackingExtras: TypedAttributeContainer {}
extension DeeplinkAttributes: TypedAttributeContainer {}

extension SwiftDataroidSdkIosPlugin {

    /// Safely determines the actual type of a value and adds it using the appropriate method
    /// This prevents incorrect type coercion (e.g., 1 -> true, 2.0 -> 2)
    private func safelyAddAttribute(_ value: Any, forKey key: String, addInt: (Int, String) -> Void, addFloat: (Float, String) -> Void, addDouble: (Double, String) -> Void, addBool: (Bool, String) -> Void, addString: (String, String) -> Void) {
        // Check if it's an NSNumber to handle numeric types properly
        if let number = value as? NSNumber {
            // Get the actual Objective-C type encoding
            let objCType = String(cString: number.objCType)
            
            // Check if it's a boolean type (char type with value 0 or 1)
            if objCType == "c" || objCType == "B" {
                // Could be bool or int8. Check if it's actually a Bool by checking CFBooleanGetTypeID
                if CFGetTypeID(number as CFTypeRef) == CFBooleanGetTypeID() {
                    addBool(number.boolValue, key)
                    return
                }
            }
            
            // Check for integer types (excluding bool)
            if objCType == "q" || objCType == "l" || objCType == "i" || objCType == "s" {
                addInt(number.intValue, key)
                return
            }
            
            // Check for floating point types
            if objCType == "f" {
                addFloat(number.floatValue, key)
                return
            }
            
            if objCType == "d" {
                addDouble(number.doubleValue, key)
                return
            }
            
            // Default fallback for other numeric types
            if number.doubleValue.truncatingRemainder(dividingBy: 1) == 0 {
                addInt(number.intValue, key)
            } else {
                addDouble(number.doubleValue, key)
            }
        } else if let stringValue = value as? String {
            addString(stringValue, key)
        }
    }
    
    /// Generic function to process attributes dictionary and add to any attribute container
    /// Works with all types conforming to TypedAttributeContainer protocol
    private func processAttributes<T: TypedAttributeContainer>(from attributesList: [String: AnyHashable], to container: T) {
        for (key, value) in attributesList {
            safelyAddAttribute(value, forKey: key,
                addInt: { container.addInt($0, forKey: $1) },
                addFloat: { container.addFloat($0, forKey: $1) },
                addDouble: { container.addDouble($0, forKey: $1) },
                addBool: { container.addBool($0, forKey: $1) },
                addString: { container.addString($0, forKey: $1) }
            )
        }
    }
}
