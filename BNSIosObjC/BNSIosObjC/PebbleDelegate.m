//
//  PebbleDelegate.m
//  TestObjCPebbleConnectivity
//
//  Created by Kristina Gancheva on 12/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//
#import "PebbleDelegate.h"

@implementation PebbleDelegate {
    PBWatch *targetWatch;
    BOOL notificationsLocked; // A help variable for controlling when notifications can be sent to Pebble.
    int notifNumber; // A help variable for cou nting 
}

/*
 * MARK: PebbleDelegate has been implemented as a singleton since there can be just one bluetooth connection with Pebble.
 */
+ (PebbleDelegate *)sharedInstance {
    static PebbleDelegate *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if(self != nil) {
        [[PBPebbleCentral defaultCentral] setDelegate:self];
        [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
        notificationsLocked = YES;
        notifNumber = 0;
    }
    return self;
}

/*
 * MARK: Method for initializing a connection with the companion watchapp on Pebble.
 */
- (void)setTargetWatch:(PBWatch*)watch {
    targetWatch = watch;
    
    if (targetWatch == nil) {
        NSLog(@"Target watch is nil.");
        return;
    }
    
    // Test if the Pebble's firmware supports AppMessage. If yes, pass the UUID of the watchapp to the PBPebbleCentral and set ReceiveUpdateHandler.
    [targetWatch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            NSLog(@"Target watch supports AppMessage.");
            
            // Configure the communications channel to target the companion watchapp on Pebble.
            uuid_t myAppUUIDbytes;
            NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"40dc4cc8-8809-44df-bfbd-2af1d2b73c2b"];
            [myAppUUID getUUIDBytes:myAppUUIDbytes];
            [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
            
            [watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
                if (update != nil) {
                    self.notification = [NSString stringWithFormat:@"iPhone: Received %@ from Pebble.",[[update allValues] objectAtIndex:0]];
                } else {
                    NSLog(@"iPhone: Received nil update from Pebble.");
                }
                return YES;
            }];
        } else {
            NSLog(@"Does not support AppMessage.");
        }
    }];
    
}

/*
 * MARK: PebbleDelegate instance methods for controlling the companion watchapp and its content.
 */
- (void)startWatchapp {
    if (![self isTargetWatchConnected]) {
        NSLog(@"Target watch is nil or not connected.");
        return;
    }
    // Try and launch watchapp after a short delay. The delay is needed for assuring a correct communication flow with Pebble.
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [targetWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
            if (error) {
                NSLog(@"%@", [@"Error by launching watchapp on target watch: " stringByAppendingString: error.debugDescription]);
            }
            else {
                NSLog(@"Watchapp has been successfully launched on target watch.");
                notificationsLocked = NO;
            }
        }];
    });
}

- (void)stopWatchapp {
    // stop watchapp
    notificationsLocked = YES;
    if ([self isTargetWatchConnected]) {
        [targetWatch appMessagesKill:^(PBWatch *watch, NSError *error) {
            if (error) {
                NSLog(@"%@", [@"Error by stopping watchapp on target watch: " stringByAppendingString: error.debugDescription]);
            }
            else {
                NSLog(@"Watchapp has been successfully stopped on target watch.");
            }
        }];
    }
}

- (void)updateWatch {
    if ([self isTargetWatchConnected] && !notificationsLocked) {
        //NB: - The maximum buffer size for AppMessage is currently 124 bytes which means that the 'update' (in our case dict) can't be bigger than that.
        NSString *message = [NSString stringWithFormat:@"Notification %d from iPhone", notifNumber];
        NSDictionary *dict = @{ @(0):[NSNumber numberWithUint8:0], @(1):message};
        
        [targetWatch appMessagesPushUpdate:dict onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            if (error) {
                NSLog(@"%@", [@"Target watch couldn't be updated: " stringByAppendingString: error.debugDescription] );
            } else {
                self.notification = [NSString stringWithFormat:@"Pebble: Received notification %d from iPhone.", notifNumber];
                notifNumber++;
            }
        }];
    } else {
        NSLog(@"There is no connected watch or the notifications are still locked!");
    }
}

/*
 * MARK: Help method(s).
 */
- (BOOL)isTargetWatchConnected {
    if (targetWatch == nil || targetWatch.connected == false) {
        return NO;
    } else {
        return YES;
    }
}

- (void)resetNotifNumber {
    notifNumber = 0;
}

/*
 *  MARK: PBPebbleCentral delegate methods
 */
- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Target watch has just connected.");
    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Target watch has just disconnected.");
    if (targetWatch == watch || [watch isEqual:targetWatch]) {
        [self setTargetWatch:nil];
    }
}

@end


