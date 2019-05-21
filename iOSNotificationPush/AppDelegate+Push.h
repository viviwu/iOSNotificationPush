//
//  AppDelegate+Push.h
//  iOS Remote Notification Push of APNs &. VoIP  
//
//  Created by Qway on 2015/10/20.
//  Copyright © 2015年 viviwu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Push)

+ (NSString*)tokenStringWithData:(NSData*)tokenData;

- (void)registerRemotePushService;

+ (void)presentUserLocalNotification:(NSDictionary *)userInfo;

+ (void)removePendingNotificationWith:(NSString *)uuid;

@end
