//
//  AppDelegate+Push.m
//  iOS_PushAPNsVoIP
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
    // Initiate registration.
    pushRegistry.desiredPushTypes=[NSSet setWithObject:PKPushTypeVoIP];
    //    APNS push
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  }
}

#pragma mark--registerUserNotification
+(void)registerUserNotificationAction
{
  if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0){
    //ios7及之前注册通知 上古方法：
    UIRemoteNotificationType type = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:type];
    
  }else{
    
#ifdef __IPHONE_8_0    //iOS8~iOS10
    //For Call:
    UIUserNotificationCategory *categoryRA=[AppDelegate getCallNotificationCategory];
    //For Message:
    UIUserNotificationCategory *categoryInput=[AppDelegate getMessageNotificationCategory];
    
    NSMutableSet * categorySet=[NSMutableSet setWithObjects:categoryRA, categoryInput, nil];
    
    UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type   categories:categorySet];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    //iOS10+ ：
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
        //[AppDelegate requestAuthorizationUserNotificationActions]; 
    }
  }
}

#pragma mark--UNUserNotification
+ (void)requestAuthorizationRegisterNotificationActions
//+ (void)requestAuthorizationUserNotificationActions
{
    if (@available(iOS 10.0, *)) {
        // Call category
        UNNotificationAction *act_ans =
        [UNNotificationAction actionWithIdentifier:@"Answer"
                                             title:NSLocalizedString(@"Answer", nil)
                                           options:UNNotificationActionOptionForeground];
        UNNotificationAction *act_dec = [UNNotificationAction actionWithIdentifier:@"Decline"  title:NSLocalizedString(@"Decline", nil)  options:UNNotificationActionOptionNone];
        
        UNNotificationCategory *cat_call = [UNNotificationCategory categoryWithIdentifier:@"call_cat" actions:[NSArray arrayWithObjects:act_ans, act_dec, nil] intentIdentifiers:[[NSMutableArray alloc] init] options:UNNotificationCategoryOptionCustomDismissAction];
        
        // Msg category
        UNTextInputNotificationAction *act_reply =
        [UNTextInputNotificationAction actionWithIdentifier:@"Reply"
                                                      title:NSLocalizedString(@"Reply", nil)
                                                    options:UNNotificationActionOptionNone];
        UNNotificationAction *act_seen =
        [UNNotificationAction actionWithIdentifier:@"Seen"
                                             title:NSLocalizedString(@"Mark as seen", nil)
                                           options:UNNotificationActionOptionNone];
        UNNotificationCategory *cat_msg =
        [UNNotificationCategory categoryWithIdentifier:@"msg_cat"
                                               actions:[NSArray arrayWithObjects:act_reply, act_seen, nil]
                                     intentIdentifiers:[[NSMutableArray alloc] init]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
        
        [UNUserNotificationCenter currentNotificationCenter].delegate = (id)([UIApplication sharedApplication].delegate);
        
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)  completionHandler:^(BOOL granted, NSError *_Nullable error) {
            // Enable or disable features based on authorization.
            if (error) {
                NSLog(@"%@", error.description);
            }
        }];
        //needen't Msg category
        NSSet* categories = [NSSet setWithObjects:cat_call, cat_msg, nil];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:categories];
    }else{
        // Fallback on earlier versions iOS8~iOS10:
        [AppDelegate registerUserNotificationAction];
    }
}


+ (UIUserNotificationCategory *)getMessageNotificationCategory {
  NSArray *actions;
  
  if ([[UIDevice.currentDevice systemVersion] floatValue] < 9 ) {
    
    UIMutableUserNotificationAction *reply = [[UIMutableUserNotificationAction alloc] init];
    reply.identifier = @"reply";
    reply.title = NSLocalizedString(@"Reply", nil);
    reply.activationMode = UIUserNotificationActivationModeForeground;
    reply.destructive = NO;
    reply.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *mark_read = [[UIMutableUserNotificationAction alloc] init];
    mark_read.identifier = @"mark_read";
    mark_read.title = NSLocalizedString(@"Mark Read", nil);
    mark_read.activationMode = UIUserNotificationActivationModeBackground;
    mark_read.destructive = NO;
    mark_read.authenticationRequired = NO;
    
    actions = @[ mark_read, reply ];
  } else {
    // iOS 9 allows for inline reply. We don't propose mark_read in this case
#ifdef __IPHONE_9_0
    UIMutableUserNotificationAction *reply_inline = [[UIMutableUserNotificationAction alloc] init];
    
    reply_inline.identifier = @"reply_inline";
    reply_inline.title = NSLocalizedString(@"Reply", nil);
    reply_inline.activationMode = UIUserNotificationActivationModeBackground;
    reply_inline.destructive = NO;
    reply_inline.authenticationRequired = NO;
      if (@available(iOS 9.0, *)) {
          reply_inline.behavior = UIUserNotificationActionBehaviorTextInput;
          actions = @[ reply_inline ];
      } else {
          // Fallback on earlier versions
      }
#endif
  }
  
  UIMutableUserNotificationCategory *localRingNotifAction = [[UIMutableUserNotificationCategory alloc] init];
  localRingNotifAction.identifier = @"incoming_msg";
  [localRingNotifAction setActions:actions forContext:UIUserNotificationActionContextDefault];
  [localRingNotifAction setActions:actions forContext:UIUserNotificationActionContextMinimal];
  
  return localRingNotifAction;
}

+ (UIUserNotificationCategory *)getCallNotificationCategory {
  //        ①、注册接受行为
  UIMutableUserNotificationAction *answer = [[UIMutableUserNotificationAction alloc] init];
  answer.identifier = @"answer";
  answer.title = NSLocalizedString(@"Answer", nil);
  answer.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
  answer.destructive = NO;
  answer.authenticationRequired = NO;//YES;//需要解锁才能处理
  //        ②、注册拒绝行为
  UIMutableUserNotificationAction *decline = [[UIMutableUserNotificationAction alloc] init];
  decline.identifier = @"decline";
  decline.title = NSLocalizedString(@"Decline", nil);
  decline.activationMode = UIUserNotificationActivationModeBackground;
  decline.destructive = YES;
  decline.authenticationRequired = NO;
  
  NSArray *localRingActions = @[ decline, answer ];
  //        ③、创建一个可变通知策略  动作类别集合
  UIMutableUserNotificationCategory *localRingNotifAction = [[UIMutableUserNotificationCategory alloc] init];
  localRingNotifAction.identifier = @"incoming_call";
  [localRingNotifAction setActions:localRingActions forContext:UIUserNotificationActionContextDefault];
  [localRingNotifAction setActions:localRingActions forContext:UIUserNotificationActionContextMinimal];
  
  return localRingNotifAction;
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
  long badge = [userInfo[@"badge"] integerValue]?: 0;
  NSInteger num = [[UIApplication sharedApplication] applicationIconBadgeNumber];
  NSLog(@"badge=%ld applicationIconBadgeNumber == %ld", badge, num);
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:num+badge];
  
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = title;
        content.body = body;
        content.categoryIdentifier = @"msg_cat";
        content.sound = [UNNotificationSound defaultSound];
        if (sound && ![sound isEqualToString:@"default"]) {
            content.sound = [UNNotificationSound soundNamed:sound];
        }
        //        UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5.0 repeats:NO];
        UNNotificationRequest *req = [UNNotificationRequest requestWithIdentifier:@"call_request" content:content trigger:nil];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:req withCompletionHandler:^(NSError * _Nullable error) {
            // Enable or disable features based on authorization.
            if (error) {
                NSLog(@"Error while adding notification request :");
                NSLog(@"error.description==%@", error.description);
            }
        }];
        //        [NSNotificationCenter.defaultCenter postNotificationName:title object:self userInfo:userInfo];
        
    } else {
        
        // Fallback on earlier versions
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.repeatInterval = 0;
        notification.alertTitle = title; //iOS 8.2
        notification.alertBody = body;
        notification.soundName = UILocalNotificationDefaultSoundName;
        if (sound && ![sound isEqualToString:@"default"]) {
            notification.soundName = sound;
        }//@"notification_ring.mp3";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    
  if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {  } else {  }
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

@end
