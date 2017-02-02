//
//  AppDelegate.swift
//  MedicatioNeura
//
//  Created by Gal Mirkin on 21/11/2016.
//  Copyright © 2016 neura. All rights reserved.
//

import UIKit
import NeuraSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NeuraSDKManager.manager.setup()
        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        guard
            let info = notification.userInfo as? [NSString: NSObject],
            let identifier = info["identifier"] as? String
            else {
                return
            }
        
        if identifier == kMorningEventIdentifier || identifier == kTakePillboxEventIdentifier || identifier == kEveningEventIdentifier {
            if application.applicationState == UIApplicationState.active {
                let fireDate = Date() + TimeInterval (15 * 60)
                NeuraSDKManager.manager.showReminder(identifier: identifier, fireDate:fireDate, repeatInterval: NSCalendar.Unit(rawValue: 0))
            } else {
                NeuraSDKManager.manager.addTookCount(identifier: identifier)
            }
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
        guard
            let actionIndentifier = identifier,
            let info = notification.userInfo as? [NSString: NSObject],
            let identifier = info["identifier"] as? String
            else {
                return
        }
        
        if actionIndentifier == kTookActionIdentifier {
            NeuraSDKManager.manager.addTookCount(identifier: identifier)
            
        } else if actionIndentifier == kLaterActionIdentifier {
            let fireDate = Date() + TimeInterval (15 * 60)
            NeuraSDKManager.manager.showReminder(identifier: identifier, fireDate:fireDate, repeatInterval: NSCalendar.Unit(rawValue: 0))
        }
     completionHandler()
    }
}

