//
//  AppDelegate.m
//  iOS Remote Notification Push of APNs &. VoIP  
//
//  Created by Qway on 2015/10/20.
//  Copyright © 2015年 viviwu. All rights reserved.
//

#import "AppDelegate+Push.h"

NSString *const kUpdatePushTokenToServerNotification = @"kUpdatePushTokenToServerNotification";

NSString *const kIncomingMsg = @"incoming_msg";
NSString *const kReplay = @"reply_now";
NSString *const kMark = @"ignore_or_mark_as_read"; //see

NSString *const kIncomingCall = @"incoming_call";
NSString *const kAnswer = @"Answer";
NSString *const kDecline = @"Decline";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  [self registerRemotePushService];//APNS & VoiP
  
  return YES;
}
//###################################################
#pragma mark ---- PKPushRegistryDelegate VoIP PushKit

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(NSString *)type
{
    NSLog(@"PushKit Token invalidated");
//    [self registerRemotePushService];
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
            UIPasteboard   * psb = [UIPasteboard generalPasteboard];
            psb.string = token;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatePushTokenToServerNotification object:token];
        }
        NSLog(@"VoIP Token:\n%@", token);
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type
{
    NSLog(@"PushKit received with payload : %@ \n forType:%@", payload.dictionaryPayload, type);
    //    dispatch_async(dispatch_get_main_queue(), ^{   });
    [AppDelegate presentUserLocalNotification: payload.dictionaryPayload];
}

#pragma mark ---- APNs PushNotification Functions
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError: (NSError *)error
{
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), [error localizedDescription]);
//    [self registerRemotePushService];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken: (NSData *)deviceToken
{
  NSString *token = [AppDelegate tokenStringWithData:deviceToken];
  NSLog(@"APNS Token:\n %@", token);
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  id tokenString = [ud objectForKey:@"deviceToken"];
  if (tokenString == nil) {
    [ud setObject:token forKey:@"deviceToken"];
    [ud synchronize];
  }
  self.apnsPushToken = token;
  [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatePushTokenToServerNotification object:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler NS_AVAILABLE_IOS(7_0)
{
    NSLog(@"APNS RemoteNotification:%@", userInfo);
  if(userInfo)    completionHandler(UIBackgroundFetchResultNewData);
  if(application.applicationState > 0 ){
    //UIApplicationStateInactive  | UIApplicationStateBackground
    //Process RemoteNotification
  }else{
    // UIApplicationStateActive
       [AppDelegate presentUserLocalNotification: userInfo];
  }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%s \n %@", __func__, notification.userInfo);
}

//########################iOS9~iOS10###########################
//This method will be invoked even if the application was launched or resumed
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"responseInfo==%@", responseInfo);
    if ([identifier isEqual:kMark]) {
        
    } else if ([identifier isEqual:kReplay]) {
        
    }else if ([identifier isEqual:kAnswer]) {
        
    } else if ([identifier isEqual:kDecline]) {
        
    }else{
        
    }
    completionHandler();
}
//########################iOS9~iOS10###########################

//###################################################
#pragma mark - UNUserNotifications Framework

- (void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
API_AVAILABLE(ios(10.0)){
  NSLog(@"notification.request.identifier: %@",notification.request.identifier);
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
    } else {
        // Fallback on earlier versions
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
API_AVAILABLE(ios(10.0)){
  //be called when user responded to the notification！
  NSLog(@"response.actionIdentifier : %@", response.actionIdentifier);
    //kReplay \kMark \kReplay \kReplay  ...
    if ([response.actionIdentifier isEqual:kReplay])
        NSLog(@"userText==%@", ((UNTextInputNotificationResponse *)response).userText);
 
  completionHandler();
}

//###################################################



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
