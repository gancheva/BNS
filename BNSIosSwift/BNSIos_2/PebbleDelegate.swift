//
//  PebbleDelegate.swift
//  BNSIos_2
//
//  Created by Kristina Gancheva on 28/11/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import Foundation

class PebbleDelegate: NSObject, PBPebbleCentralDelegate {
    
    private var targetWatch: PBWatch!
    var notification: String!
    var notifNumber:Int!  // A help variable for counting the notifications sent by the iphone.
    private var notificationsLocked: Bool! // A help variable for controlling when notifications can be sent to Pebble.
    
    class var sharedInstance : PebbleDelegate {
        struct Singleton {
            static let instance : PebbleDelegate = PebbleDelegate()
        }
        return Singleton.instance
    }
    
    override private init() {
        super.init()
        
        PBPebbleCentral.defaultCentral().delegate = self
        setTargetWatch(PBPebbleCentral.defaultCentral().lastConnectedWatch())
        notifNumber = 0;
    }

    
    //MARK: - Pebble functions
    private func setTargetWatch(watch: PBWatch!) {
        targetWatch = watch
        
        if targetWatch == nil {
            NSLog("Target watch is nil!")
            return
        }
        
        // Check whether the BNS watchapp supports the AppMessage API, if so set the ReceiveUpdateHandler and launch the BNS watchapp. (All Pebble watches with firmware hiegher than 1.10 support AppMessage!)
        targetWatch.appMessagesGetIsSupported {(watch: PBWatch!, isAppMessageSupported: Bool) -> Void in
            if (isAppMessageSupported) {
                NSLog("Target watch supports AppMessage.")
                // Configure the communications channel to target the BNS watchapp.
                let appUuid: NSUUID = NSUUID(UUIDString: "40dc4cc8-8809-44df-bfbd-2af1d2b73c2b")!
                var appUuidBytes: UInt8 = 0
                appUuid.getUUIDBytes(&appUuidBytes)
                (PBPebbleCentral.defaultCentral()).appUUID = NSData(bytes: &appUuidBytes, length: 16)
                
                watch.appMessagesAddReceiveUpdateHandler({ (watch: PBWatch!, update: [NSObject : AnyObject]!) -> Bool in
                    if (update != nil) {
                        let dict = update as Dictionary<Int, String>
                        self.notification = "iPhone: Received \(dict[1]!) from Pebble."
                    } else {
                        NSLog("iPhone: Received nil update from Pebble.")
                    }
                    return true
                })
            } else {
                NSLog("Does not support AppMessage.")
            }
        }
    }
    
    func startWatchapp() {
        if !isTargetWatchConnected() {
            NSLog("Target watch is nil or not connected.")
            return;
        }
        
        // Try and launch BNS watchapp after a short delay. The delay is needed for a correct communication flow.
        var delayInSeconds = 0.5
        var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.targetWatch.appMessagesLaunch({ (watch: PBWatch!, error: NSError!) -> Void in
                if error == nil {
                    NSLog("Watchapp has been successfully launched on target watch: \(watch.name)")
                    self.notificationsLocked = false
                } else {
                    NSLog("Error by launching watchapp on target watch: \(error.description)")
                }
            })
        }
    }

    
    func stopWatchapp() {
        notificationsLocked = true
        // stop BNS watchapp
        if isTargetWatchConnected() {
            targetWatch.appMessagesKill({ (watch: PBWatch!, error: NSError!) -> Void in
                if ((error) == nil) {
                    NSLog("Watchapp has been successfully stopped on target watch.")
                } else {
                    NSLog("Error by stopping watchapp on target watch: \(error.description)")
                }
            })
        }
    }
    
    //MARK: - UIButton
    func updateWatch() {
        // The type and content of the update will be determined according the GPS location. For test purposes dummy data is used.
        if (isTargetWatchConnected() && notificationsLocked == false) {
            //NB: - The maximum buffer size for AppMessage is currently 124 bytes which means that the 'update' can not be bigger than that.
            var message = "Notification \(notifNumber) from iPhone"
            var dict = Dictionary<Int, String>()
            dict = [1:message]
            
            targetWatch.appMessagesPushUpdate(dict, onSent: { (watch: PBWatch!, update: [NSObject : AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    //self.mainViewController.updatePhone("Pebble: Received notification \(self.notifNumber) from iPhone.")
                    self.notification = "Pebble: Received notification \(self.notifNumber) from iPhone."
                    self.notifNumber = self.notifNumber + 1
                } else {
                    NSLog("Pebble: Could not receive notification \(self.notifNumber) from iPhone. \(error.description)")
                }
            })
        } else {
            NSLog("There is no connected watch or the notifications are still locked!")
        }
    }
    
    private func isTargetWatchConnected() -> Bool {
        if (targetWatch == nil || targetWatch.connected == false) {
            return false
        } else {
            return true
        }
    }
    
    func pebbleCentral(central: PBPebbleCentral!, watchDidConnect watch: PBWatch!, isNew: Bool) {
        NSLog("Connected: \(watch.name)")
        setTargetWatch(watch)
    }
    
    func pebbleCentral(central: PBPebbleCentral!, watchDidDisconnect watch: PBWatch!) {
        NSLog("Disconnected: \(watch.name)")
        if targetWatch == watch || watch.isEqual(targetWatch) {
            setTargetWatch(nil)
        }
    }
    
}


