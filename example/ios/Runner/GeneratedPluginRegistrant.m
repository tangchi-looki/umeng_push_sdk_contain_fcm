//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<umeng_common_sdk/UmengCommonSdkPlugin.h>)
#import <umeng_common_sdk/UmengCommonSdkPlugin.h>
#else
@import umeng_common_sdk;
#endif

#if __has_include(<umeng_push_sdk_contain_fcm/UmengPushSdkPlugin.h>)
#import <umeng_push_sdk_contain_fcm/UmengPushSdkPlugin.h>
#else
@import umeng_push_sdk_contain_fcm;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [UmengCommonSdkPlugin registerWithRegistrar:[registry registrarForPlugin:@"UmengCommonSdkPlugin"]];
  [UmengPushSdkPlugin registerWithRegistrar:[registry registrarForPlugin:@"UmengPushSdkPlugin"]];
}

@end
