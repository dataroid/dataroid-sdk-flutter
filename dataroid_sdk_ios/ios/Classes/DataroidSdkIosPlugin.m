#import "DataroidSdkIosPlugin.h"
#if __has_include(<dataroid_sdk_ios/dataroid_sdk_ios-Swift.h>)
#import <dataroid_sdk_ios/dataroid_sdk_ios-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dataroid_sdk_ios-Swift.h"
#endif

@implementation DataroidSdkIosPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDataroidSdkIosPlugin registerWithRegistrar:registrar];
}
@end
