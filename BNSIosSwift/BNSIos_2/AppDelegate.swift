//
//  AppDelegate.swift
//  BNSIos_2
//
//  Created by Kristina Gancheva on 27/10/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let mainViewController = (UIStoryboard(name: "Main", bundle: nil)).instantiateViewControllerWithIdentifier("MainStoryboard") as ViewController
    
    //MARK: - App-Lifecycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        PebbleDelegate.sharedInstance.stopWatchapp()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        PebbleDelegate.sharedInstance.notifNumber = 0
        mainViewController.clearCommTracker()
    }

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {
        PebbleDelegate.sharedInstance.startWatchapp()
    }

    func applicationWillTerminate(application: UIApplication) {}
    
}

