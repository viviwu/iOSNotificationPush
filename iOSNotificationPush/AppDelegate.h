//
//  AppDelegate.h
//  iOS Remote Notification Push of APNs &. VoIP  
//
//  Created by Qway on 2015/10/20.
//  Copyright © 2015年 viviwu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

#define kUserDef [NSUserDefaults standardUserDefaults]
#define kUserDef_OBJ(s) [[NSUserDefaults standardUserDefaults] objectForKey:s]

#define kAppDel ((AppDelegate *)[UIApplication sharedApplication].delegate)

extern NSString *const  kUpdatePushTokenToServerNotification;

extern NSString *const kIncomingMsg;
extern NSString *const kReplay;
extern NSString *const kMark;

extern NSString *const kIncomingCall;
extern NSString *const kAnswer;
extern NSString *const kDecline;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString* apnsPushToken;
@property (nonatomic, copy) NSString* voipPushToken;

@end


#define log4Warn  NSLog
