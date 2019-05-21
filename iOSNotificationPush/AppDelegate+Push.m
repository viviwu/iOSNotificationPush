//
//  AppDelegate+Push.m
//  iOS Remote Notification Push of APNs &. VoIP  
//
//  Created by Qway on 2015/10/20.
//  Copyright © 2015年 viviwu. All rights reserved.
//

#import "AppDelegate+Push.h"

@implementation AppDelegate (Push)


//###################################################
+ (NSString*)tokenStringWithData:(NSData*)tokenData{
  NSString *token = [[tokenData description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
  return token;
}

#pragma deploymate push "ignored-api-availability"

#pragma mark--RemotePushService
- (void)registerRemotePushService{
  
  if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0) {
    //    PushKit
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = (id)self; //(id)([UIApplication sharedApplication].delegate);
    pushRegistry.desiredPushTypes=[NSSet setWithObject:PKPushTypeVoIP]; // Initiate registration.
      
    //    APNS push
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    if (@available(iOS 10.0, *)) {
      [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions: (UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)  completionHandler:^(BOOL granted, NSError *_Nullable error) {
        // Enable or disable features based on authorization.
        if (error) {
          NSLog(@"%@", error.description);
        }
      }];
        // Call category
        UNNotificationAction *act_ans = [UNNotificationAction actionWithIdentifier:kAnswer  title:NSLocalizedString(kAnswer, nil)  options:UNNotificationActionOptionForeground];
        UNNotificationAction *act_dec = [UNNotificationAction actionWithIdentifier:kDecline title:NSLocalizedString(kDecline, nil) options:UNNotificationActionOptionNone];
        
        UNNotificationCategory *cat_call = [UNNotificationCategory categoryWithIdentifier: kIncomingCall actions: @[act_ans, act_dec]   intentIdentifiers: @[kAnswer, kDecline]     options: UNNotificationCategoryOptionCustomDismissAction];
        
        // Msg category
        UNTextInputNotificationAction *act_reply = [UNTextInputNotificationAction actionWithIdentifier: kReplay  title: NSLocalizedString(kReplay, nil)  options: UNNotificationActionOptionNone];
        UNNotificationAction *act_seen = [UNNotificationAction actionWithIdentifier:kMark title:NSLocalizedString(kMark, nil) options: UNNotificationActionOptionNone];
        
        UNNotificationCategory *cat_msg = [UNNotificationCategory categoryWithIdentifier: kIncomingMsg  actions: @[act_reply, act_seen]  intentIdentifiers: @[kReplay, kMark]  options: UNNotificationCategoryOptionCustomDismissAction];
        
        [UNUserNotificationCenter currentNotificationCenter].delegate = (id)([UIApplication sharedApplication].delegate);
        
        //needen't Msg category
        NSSet* categories = [NSSet setWithObjects:cat_call, cat_msg, nil];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
        
    } else {
        // Fallback on earlier versions iOS8~iOS10:
#ifdef __IPHONE_8_0    //iOS8~iOS10
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        //For Call:
        UIUserNotificationCategory *categoryRA=[AppDelegate getUserNotificationCategoryCall];
        //For Message:
        UIUserNotificationCategory *categoryInput=[AppDelegate getUserNotificationCategoryMessage];
        
        NSSet * categorySet=[NSSet setWithObjects:categoryRA, categoryInput, nil];
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type   categories:categorySet];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
        //      if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max)
    }
  }else{  //    APNS push iOS7-:
    UIRemoteNotificationType type = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:type]; //iOS7-:
  }
}

+ (UIUserNotificationCategory *)getUserNotificationCategoryMessage {
  //if ([[UIDevice.currentDevice systemVersion] floatValue] < 9 )
  UIMutableUserNotificationAction *act_read = [[UIMutableUserNotificationAction alloc] init];
  act_read.identifier = kMark;
  act_read.title = NSLocalizedString(kMark, nil);
  act_read.activationMode = UIUserNotificationActivationModeBackground;
  act_read.destructive = NO;
  act_read.authenticationRequired = NO;
  
  UIMutableUserNotificationAction *act_reply = [[UIMutableUserNotificationAction alloc] init];
  act_reply.identifier = kReplay;
  act_reply.title = NSLocalizedString(kReplay, nil);
  act_reply.activationMode = UIUserNotificationActivationModeBackground;
  act_reply.destructive = NO;
  act_reply.authenticationRequired = NO;
  if (@available(iOS 9.0, *)) {
    act_reply.behavior = UIUserNotificationActionBehaviorTextInput;
  } else {
    // iOS 9 allows for inline reply. We don't propose act_read in this case
  }
  
  UIMutableUserNotificationCategory *userNotifAction = [[UIMutableUserNotificationCategory alloc] init];
  userNotifAction.identifier = kIncomingMsg;
  [userNotifAction setActions:@[act_read, act_reply] forContext: UIUserNotificationActionContextDefault];
  //UIUserNotificationActionContextMinimal
  return userNotifAction;
}

+ (UIUserNotificationCategory *)getUserNotificationCategoryCall
{
  UIMutableUserNotificationAction *answer = [[UIMutableUserNotificationAction alloc] init];
  answer.identifier = kAnswer;
  answer.title = NSLocalizedString(kAnswer, nil);
  answer.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
  answer.destructive = NO;
  answer.authenticationRequired = NO;//YES 需要解锁才能处理
  
  UIMutableUserNotificationAction *decline = [[UIMutableUserNotificationAction alloc] init];
  decline.identifier = kDecline;
  decline.title = NSLocalizedString(kDecline, nil);
  decline.activationMode = UIUserNotificationActivationModeBackground;
  decline.destructive = YES;
  decline.authenticationRequired = NO;
  
  UIMutableUserNotificationCategory *notiCat = [[UIMutableUserNotificationCategory alloc] init];
  notiCat.identifier = kIncomingCall;
  [notiCat setActions:@[decline, answer] forContext: UIUserNotificationActionContextDefault];
//  UIUserNotificationActionContextMinimal
  return notiCat;
}

/*
aps =     {
  alert =         {
    body = "Your message Here";
    title = "The only thing ";
  };
  badge = 7;
  "content-available" = 1;
  sound = default;
};
*/
#pragma mark -- presentUserLocalNotification

+ (void)presentNotification:(NSString*)title
                       body:(NSString*)body
         categoryIdentifier:(NSString*)categoryIdentifier
                      sound:(NSString*)sound
{
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = title;
        content.body = body;
        content.categoryIdentifier = categoryIdentifier;    // kIncomingMsg\kIncomingCall;
        content.sound = [UNNotificationSound defaultSound];
        if (sound && ![sound isEqualToString:@"default"]) {
            content.sound = [UNNotificationSound soundNamed:sound];
        }
        UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1.0 repeats:NO];
        UNNotificationRequest *req = [UNNotificationRequest requestWithIdentifier:@"UNNotificationRequestID" content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req withCompletionHandler:^(NSError * _Nullable error) {
            // Enable or disable features based on authorization.
            if (error)  NSLog(@"NotificationRequest:error.description==%@", error.description);
        }];
    } else {
        // Fallback on earlier versions
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.repeatInterval = 0;
        if (@available(iOS 8.2, *)) {
            notification.alertTitle = title;    //iOS 8.2
        } else {/* Fallback on earlier versions */ }
        notification.alertBody = body;
        notification.soundName = UILocalNotificationDefaultSoundName;
        if (sound && ![sound isEqualToString:@"default"]) {
            notification.soundName = sound; //@"notification_ring.mp3";
        }
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

+ (void)presentUserLocalNotification:(NSDictionary *)userInfo{
  NSDictionary * aps = userInfo[@"aps"];
  NSDictionary * alert = nil;
  NSString * title = @"Default title";
  NSString * body = @"Default body";
  if (aps[@"alert"] && [aps[@"alert"] isKindOfClass:[NSDictionary class]]) {
    alert = aps[@"alert"];
    title = alert[@"title"];
    body = alert[@"body"];
  }
  NSString * sound = aps[@"sound"];
  [AppDelegate presentNotification:title body:body categoryIdentifier:kIncomingMsg sound:sound];
    
  long badge = [userInfo[@"badge"] integerValue]?: 0;
  NSInteger num = [[UIApplication sharedApplication] applicationIconBadgeNumber];
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:num+badge];
//  if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {  } else {  }
}

+ (void)removePendingNotificationWith:(NSString *)uuid
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center= [UNUserNotificationCenter currentNotificationCenter];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> *requests)
         {
             for (UNNotificationRequest * request in requests) {
                 NSLog(@"+++++request.identifier==%@", request.identifier);
                 if ([request.identifier isEqualToString:uuid])
                 {
                     NSLog(@"removePendingNotification(UUID):\n %@",uuid);
                     [center removePendingNotificationRequestsWithIdentifiers:@[uuid]];
                 }
             }
         }];
    } else {
        // Fallback on earlier versions
        UIApplication *application=[UIApplication sharedApplication];
        NSArray *notifications = [application scheduledLocalNotifications];
        for (UILocalNotification * localNoti in notifications)
        {
            NSLog(@"+++++localNoti.userInfo: %@", localNoti.userInfo);
            if ([localNoti.userInfo[@"uuid"] isEqualToString: uuid])
            {
                NSLog(@"!!!cancelLocalNotification(UUID):\n %@", uuid);
                [application cancelLocalNotification:localNoti];
            }
        }
    }
    
//  if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) { }else{ }
}

#pragma mark -- instance method
+ (UIUserNotificationAction *)userNotificationActionWithId:(NSString*)identifier
                                                     title:(NSString*)title
                                            activationMode:(UIUserNotificationActivationMode)activationMode
                                               destructive:(BOOL)destructive
                                    authenticationRequired:(BOOL)authenticationRequired
                                                  behavior:(NSUInteger)behavior //API_AVAILABLE(ios(9.0))
{
  UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
  action.identifier = identifier ;
  action.title = title;
  action.activationMode = activationMode;
  action.destructive = destructive;
  action.authenticationRequired = authenticationRequired;
  if (@available(iOS 9.0, *)) {
    action.behavior = behavior;
  } else {
    // Fallback on earlier versions
  }
  return action;
}

@end
