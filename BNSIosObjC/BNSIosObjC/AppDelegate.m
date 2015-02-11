//
//  AppDelegate.m
//  TestObjCPebbleConnectivity
//
//  Created by Kristina Gancheva on 11/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "PebbleDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate {
    ViewController *_mainController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _mainController = (ViewController *)self.window.rootViewController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[PebbleDelegate sharedInstance] stopWatchapp];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[PebbleDelegate sharedInstance] resetNotifNumber];
    [_mainController clearCommTracker];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[PebbleDelegate sharedInstance] startWatchapp];
}

- (void)applicationWillTerminate:(UIApplication *)application {}

@end
