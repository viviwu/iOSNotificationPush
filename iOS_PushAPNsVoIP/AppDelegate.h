//
//  AppDelegate.h
//  iOS_PushAPNsVoIP
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


@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, PKPushRegistryDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString* apnsPushToken;
@property (nonatomic, copy) NSString* voipPushToken;

@end


#define log4Warn  NSLog
