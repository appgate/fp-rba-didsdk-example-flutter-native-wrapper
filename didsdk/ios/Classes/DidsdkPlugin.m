#import "DidsdkPlugin.h"
#if __has_include(<didsdk/didsdk-Swift.h>)
#import <didsdk/didsdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "didsdk-Swift.h"
#endif

@implementation DidsdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDidsdkPlugin registerWithRegistrar:registrar];
  [SwiftAccountsModule registerWithRegistrar:registrar];
  [SwiftQRModule registerWithRegistrar:registrar];
  [SwiftOTPModule registerWithRegistrar:registrar];
  [SwiftPushPlugin registerWithRegistrar:registrar];
}
@end
