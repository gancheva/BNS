//
//  ViewController.swift
//  BNSIos_2
//
//  Created by Kristina Gancheva on 27/10/14.
//  Copyright (c) 2014 Peperzaken. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var commTracker: UITextView!
    @IBOutlet weak var notifyButton: UIButton!
    
    //MARK: - ViewController-Lifecycle
    override func viewDidLoad() {
        commTracker.layer.borderColor = UIColor(rgba: "#33b5e5").CGColor
        commTracker.layer.borderWidth = 3.0
        commTracker.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        
        notifyButton.backgroundColor = UIColor(rgba: "#99cc00")
        notifyButton.drawRect(CGRectMake(0, 0, 200, 80))
        notifyButton.layer.cornerRadius = 10.0
        notifyButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        notifyButton.setTitle("Notify Watch", forState: UIControlState.Normal)
        
        // Using key value observing for detecting changes in receivedMessage from Pebble and changes in currentLocation.
        PebbleDelegate.sharedInstance.addObserver(self, forKeyPath: "notification", options: NSKeyValueObservingOptions.New, context: nil)
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if(keyPath == "notification") {
            updatePhone(PebbleDelegate.sharedInstance.notification)
        }
    }
    
    @IBAction func updateWatch(sender: AnyObject) {
        PebbleDelegate.sharedInstance.updateWatch()
    }
    
    //MARK: - UITextView
    func updatePhone(update: String) {
        commTracker.text = commTracker.text + update
        commTracker.text = commTracker.text + "\n"
    }
    
    func clearCommTracker() {
        commTracker.text = ""
    }
    
}

