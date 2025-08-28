# 这里是友盟推送+flutter+fcm(谷歌推送)的使用步骤，其他厂商参考官方文档

## 1.在Firebase控制台创建项目（直接创建android项目就行，不用管他的android步骤。我当时卡在这里好久），

## 2.然后把秘钥上传到友盟fcm配置中（这一步可参考友盟厂商配置不在累诉）

## 3.集成
在工程 pubspec.yaml 中加入 dependencies

```
dependencies: 
    umeng_push_sdk_contain_fcm: ^1.0.0
```

## 4.在android/build.gradle 中加入
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // 加入下面这行
        classpath 'com.google.gms:google-services:4.3.15'
    }
}

## 5.在android/app中加入firebase services文件
google-services.json

## 6.在android/app/build.gradle 中加入
// 加入下面这行
apply plugin: 'com.google.gms.google-services'

## 7.在android/app/proguard-rules.pro 中加入
// 加入下面这行
-keep class org.android.agoo.fcm.* {*;}

## 8.恭喜你，完成了
有问题可交流沟通
https://github.com/YangJianFei/umeng_push_sdk_contain_fcm

## 注意事项，
1.调试时可通过调试控制台查看fcm是否正常启动，正常启动后会打印fcm xxx token(可通过过滤查看)
不通过也会有报错信息，方便查看失败原因


2.手机必须开启谷歌服务，科学上网，




# 下面这些是友盟推送sdk官方使用搬过来的（可直接去看官方使用文档）
## 集成
在工程 pubspec.yaml 中加入 dependencies

```
dependencies: 
    umeng_push_sdk: ^2.3.0
```

## 配置

创建应用请参考：https://developer.umeng.com/docs/67966/detail/99884

### Android

在 `/android/app/build.gradle` 中添加下列代码：

```groovy
android {
  defaultConfig {
    applicationId "您的应用包名"

    ndk {
        abiFilters 'armeabi', 'armeabi-v7a', 'arm64-v8a'
    }

    manifestPlaceholders = [
            UMENG_APPKEY: '您申请的appkey',
            UMENG_MESSAGE_SECRET: '您申请的message secret',
            UMENG_CHANNEL: '您的应用发布渠道',

            HUAWEI_APP_ID: '您申请的华为通道appid',

            HONOR_APP_ID: '您申请的荣耀通道appid',

            XIAOMI_APP_ID: '您申请的小米通道appid',
            XIAOMI_APP_KEY: '您申请的小米通道appkey',

            OPPO_APP_KEY: '您申请的OPPO通道appkey',
            OPPO_APP_SECRET: '您申请的OPPO通道app secret',

            VIVO_APP_ID: '您申请的VIVO通道appid',
            VIVO_APP_KEY: '您申请的VIVO通道appkey',

            MEIZU_APP_ID: '您申请的魅族通道appid',
            MEIZU_APP_KEY: '您申请的魅族通道appkey',
    ]
  }

}
```

厂商消息下发时，Activity路径传入：com.umeng.message.UmengOfflineMessageActivity

### iOS

证书配置请参考文档：https://developer.umeng.com/docs/67966/detail/66748

AppDelegate.m中需要进行的配置：

1. didFinishLaunchingWithOptions方法中设置消息代理

```oc
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [UNUserNotificationCenter currentNotificationCenter].delegate=self;
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

2. 处理willPresentNotification方法回调

```oc
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

    NSDictionary * userInfo = notification.request.content.userInfo;

    [UmengPushSdkPlugin didReceiveUMessage:userInfo];
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        //应用处于前台时的远程推送接收
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    } else {
        //应用处于前台时的本地推送接收
    }

    // 控制推送消息是否直接在前台显示
   completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}
```

3. 处理didReceiveNotificationResponse方法回调

```oc
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
		//应用后台或者关闭时收到消息，回调flutter层onNotificationOpen方法
    [UmengPushSdkPlugin didOpenUMessage:userInfo];

    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接收
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    } else {
        //应用处于后台时的本地推送接收
    }
}
```

## 使用
```dart
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:umeng_push_sdk/umeng_push_sdk.dart';
```

具体使用请下载[sdk](https://pub.dev/packages/umeng_push_sdk/versions)，参考sdk中的example工程。