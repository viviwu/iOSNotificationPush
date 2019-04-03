//
//  AppDelegate.m
//  iOS_PushAPNsVoIP
//
//  Created by Qway on 2015/10/20.
//  Copyright © 2015年 viviwu. All rights reserved.
//

#import "AppDelegate+Push.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  [self registerRemotePushService];//APNS & VoiP
//  [AppDelegate registerUserNotificationAction];
    [AppDelegate requestAuthorizationRegisterNotificationActions];
  
  return YES;
}

#pragma mark - PushNotification Functions

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//  NSLog(@"%@ : %@", NSStringFromSelector(_cmd), deviceToken);
  NSString *token = [AppDelegate tokenStringWithData:deviceToken];
  NSLog(@"APNS Token:\n %@", token);
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  id tokenString = [ud objectForKey:@"deviceToken"];
  if (tokenString == nil) {
    [ud setObject:token forKey:@"deviceToken"];
    [ud synchronize];
  }
  self.apnsPushToken = token;
}
//  UIApplicationStateActive,
//  UIApplicationStateInactive,
//  UIApplicationStateBackground
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler NS_AVAILABLE_IOS(7_0){
  NSLog(@"userInfo==%@", userInfo);
  //iOS10+ 启用UNNotificationAction后 应用在前台时收到APNs也会出发通知横幅！赞
  
  //处理接受的推送消息
  if(userInfo)    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"%@ : %@", NSStringFromSelector(_cmd), [error localizedDescription]);
}


//###################################################
#pragma mark PKPushRegistryDelegate VoIP推送

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(NSString *)type
{
  NSLog(@"PushKit Token invalidated");
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type
{
  NSLog(@"PushKit credentials updated !");
  if([credentials.token length] == 0)
  {
    NSLog(@"voip token NULL");
  }else{
    //XWPrivte:
    NSString *token =[AppDelegate tokenStringWithData:credentials.token];
    if (token) {
      self.voipPushToken=token;
      [kUserDef setObject:token forKey:@"voipToken"];
      [kUserDef synchronize];
    }
    NSLog(@"VoIP Token:\n%@", token);
  }
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
  NSLog(@"PushKit received with payload : %@ ", payload.dictionaryPayload);
  UIUserNotificationType theType = [UIApplication sharedApplication].currentUserNotificationSettings.types;
  if (UIUserNotificationTypeNone == theType)
  {
//    [AppDelegate registerUserNotificationAction];
      [AppDelegate requestAuthorizationRegisterNotificationActions];
  }
  
  //    dispatch_async(dispatch_get_main_queue(), ^{   });
  [AppDelegate presentUserLocalNotification: payload.dictionaryPayload];
}



//###################################################
#pragma mark - UNUserNotifications Framework

- (void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(ios(10.0)){
  NSLog(@"notification.request.identifier: %@",notification.request.identifier);
  // 这里真实需要处理交互的地方
  
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
    } else {
        // Fallback on earlier versions
    }
}

#ifdef __IPHONE_11_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
//this block declaration is not a prototy
#else
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
#endif
API_AVAILABLE(ios(10.0)){
  //通知来了 用户需要响应（点击／下来）才会触发这个回调！
  NSLog(@"UN : response recieved");
  NSLog(@"actionIdentifier-->: %@", response.actionIdentifier);
  //msg_cat: call_cat
  if ([response.actionIdentifier isEqual:@"Seen"]) {
    log4Warn(@"%@", response.notification.request.content.userInfo);
  } else if ([response.actionIdentifier isEqual:@"Reply"]) {
    NSLog(@"userText==%@", ((UNTextInputNotificationResponse *)response).userText);
  }else if ([response.actionIdentifier isEqual:@"Answer"]) {
    log4Warn(@"%@", response.notification.request.content.userInfo);
  } else if ([response.actionIdentifier isEqual:@"Decline"]) {
    
  }else{}
  
  completionHandler();
}

//###################################################
//NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate。。。）
#pragma mark - NSUser notifications

#ifdef __IPHONE_9_0
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
   withResponseInfo:(NSDictionary *)responseInfo
  completionHandler:(void (^)())completionHandler {
  NSLog(@"responseInfo==%@", responseInfo);
  completionHandler();
}

#else
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
  NSLog(@"UILocalNotification==%@", notification);
  completionHandler();
}
#endif


- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
