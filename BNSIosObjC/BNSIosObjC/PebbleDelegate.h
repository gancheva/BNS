//
//  PebbleDelegate.h
//  TestObjCPebbleConnectivity
//
//  Created by Kristina Gancheva on 12/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//
#import <PebbleKit/PebbleKit.h>

@interface PebbleDelegate : NSObject <PBPebbleCentralDelegate>

@property (strong, nonatomic) NSString *notification;

+ (PebbleDelegate *)sharedInstance;

- (void)updateWatch;
- (void)startWatchapp;
- (void)stopWatchapp;
- (void)resetNotifNumber;

@end
