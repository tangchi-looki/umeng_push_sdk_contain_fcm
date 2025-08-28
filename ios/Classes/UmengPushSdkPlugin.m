#import "UmengPushSdkPlugin.h"

#import <UMPush/UMessage.h>
#import <UMCommon/UMConfigure.h>
#import <UMCommonLog/UMCommonLogManager.h>
#include <arpa/inet.h>

FlutterMethodChannel* methodChannel;
NSDictionary *userInfoTemp = nil;

@interface UMengflutterpluginForPush : NSObject


@end

static BOOL clearBagde = NO;


@implementation UMengflutterpluginForPush : NSObject

+ (BOOL)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result{
    BOOL resultCode = YES;
    if ([@"register" isEqualToString:call.method]){
        
        NSDictionary* arguments = (NSDictionary *)call.arguments;
        NSString* appkey = [arguments valueForKey:@"iOSAppkey"];
        NSString* channel = [arguments valueForKey:@"iOSChannel"];
        
        [UMCommonLogManager setUpUMCommonLogManager];
        
        [UMConfigure initWithAppkey:appkey channel:channel];
        
        ////设置注册的参数，如果不需要自定义的特殊功能可以直接在registerForRemoteNotificationsWithLaunchOptions的Entity传入一个nil.
        UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
        //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
        entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert|UMessageAuthorizationOptionSound;
        //友盟推送的注册方法
        [UMessage registerForRemoteNotificationsWithLaunchOptions:nil Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                //result(@(YES));
            } else {
                //点击不允许
                //result(@(NO));
            }
        }];
        if(userInfoTemp){
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoTemp options:0 error:nil];
            NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [methodChannel invokeMethod:@"onNotificationOpen" arguments:string];
            userInfoTemp = nil;
        }
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notifyAppEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
    }
    else if([@"getDeviceToken" isEqualToString:call.method]){
        NSData* deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUMessageUserDefaultKeyForDeviceToken"];
        NSString* resultStr = NULL;
        if ([deviceToken isKindOfClass:[NSData class]]){
            const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
            NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                                  ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                                  ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                                  ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
            resultStr = hexToken;
        }
        else{
            resultStr = @"";
        }
        result(resultStr);
        
    }
    else if([@"addAlias" isEqualToString:call.method]){
        NSDictionary* arguments = (NSDictionary *)call.arguments;
        NSString* name = [arguments valueForKey:@"alias"];
        NSString* type = [arguments valueForKey:@"type"];
        [UMessage addAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
            //NSMutableDictionary* resultDic = [[NSMutableDictionary alloc] init];
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                //[resultDic setValue:error.description forKey:@"error"];
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                //                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                //                    [resultDic addEntriesFromDictionary:responseObject];
                //                }
                resultNum = [NSNumber numberWithBool:YES];
            }
            //NSString* resultStr =  jsonStringForPlugin(resultDic);
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
        
    }
    else if([@"setAlias" isEqualToString:call.method]){
        NSDictionary* arguments = (NSDictionary *)call.arguments;
        NSString* name = [arguments valueForKey:@"alias"];
        NSString* type = [arguments valueForKey:@"type"];
        [UMessage setAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                resultNum = [NSNumber numberWithBool:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
        
    }
    else if([@"removeAlias" isEqualToString:call.method]){
        NSDictionary* arguments = (NSDictionary *)call.arguments;
        NSString* name = [arguments valueForKey:@"alias"];
        NSString* type = [arguments valueForKey:@"type"];
        [UMessage removeAlias:name type:type response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                resultNum = [NSNumber numberWithBool:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
    }
    else if([@"addTag" isEqualToString:call.method]){
        NSArray* arguments = (NSArray *)call.arguments;
        [UMessage addTags:arguments response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                resultNum = [NSNumber numberWithBool:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
    }
    else if([@"removeTag" isEqualToString:call.method]){
        NSArray* arguments = (NSArray *)call.arguments;
        [UMessage deleteTags:arguments response:^(id  _Nonnull responseObject, NSInteger remain, NSError * _Nonnull error) {
            NSNumber* resultNum = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultNum = [NSNumber numberWithBool:NO];
            }
            else{
                NSLog(@"responseObject:%@",responseObject);
                resultNum = [NSNumber numberWithBool:YES];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultNum);
            });
        }];
    }
    else if([@"getTags" isEqualToString:call.method]){
        NSArray* arguments = (NSArray *)call.arguments;
        [UMessage getTags:^(NSSet * _Nonnull responseTags, NSInteger remain, NSError * _Nonnull error) {
            NSArray<NSString*>* resultArr = NULL;
            if (error) {
                NSLog(@"error:%@",error);
                resultArr = [NSArray array];
            }
            else{
                NSLog(@"responseTags:%@",responseTags);
                NSArray* tempResultArr = [responseTags allObjects];
                resultArr = [[NSArray alloc] initWithArray:tempResultArr];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                result(resultArr);
            });
        }];
    }
    else if([@"setLogEnable" isEqualToString:call.method]){
        bool logEnable = [call.arguments boolValue];
        [UMConfigure setLogEnabled:logEnable];
    }
    else if([@"enable" isEqualToString:call.method]){
//        NSLog(@"push enable is a empty function");
    }
    else if([@"setBadge" isEqualToString:call.method]){
        NSNumber* arguments = (NSNumber *)call.arguments;
        if([arguments intValue] !=0 ){
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[arguments intValue]];
        }else {
            //删除角标但不清空通知中心
            clearBagde = YES;
        }
    }
    else{
        resultCode = NO;
    }
    
    return resultCode;
}

+(void)notifyAppEnterBackground{
    NSLog(@"----------notifyAppEnterBackground");
    if(clearBagde == YES){
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.badge = @(-1);
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"clearBadge" content:content trigger:nil];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
         }];
    }
    clearBagde = NO;
}

@end


@implementation UmengPushSdkPlugin

+ (void)didReceiveUMessage:(NSDictionary *)userInfo{
    if (userInfo && userInfo.count)
    {
        if(methodChannel){
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:nil];
            NSString * string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [methodChannel invokeMethod:@"onNotificationReceive" arguments:string];
        }else{
            userInfoTemp = userInfo;
        }
    }
}

+ (void)didOpenUMessage:(NSDictionary *)userInfo{
    if (userInfo && userInfo.count)
    {
        if(methodChannel){
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:nil];
            NSString * string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [methodChannel invokeMethod:@"onNotificationOpen" arguments:string];
        }else{
            userInfoTemp = userInfo;
        }
    }
}




+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    methodChannel = [FlutterMethodChannel methodChannelWithName:@"u-push" binaryMessenger:[registrar messenger]];
    
    UmengPushSdkPlugin* instance = [[UmengPushSdkPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:methodChannel];
    
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
        
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        //result(FlutterMethodNotImplemented);
    }
    
    
    BOOL resultCode = [UMengflutterpluginForPush handleMethodCall:call result:result];
    if (resultCode) return;
    
    result(FlutterMethodNotImplemented);
}

@end
