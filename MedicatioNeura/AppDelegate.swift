//
//  AppDelegate.swift
//  MedicatioNeura
//
//  Created by Youval Vaknin on 21/11/2016.
//  Copyright © 2016 neura. All rights reserved.
//

/**
 The app delegate handles both remote notifications and local notifications. The remote notifications is sent through a server to apn, the "remind me later" action creates a local notification with the same notification category (see NeuraSDKManager.swift)
 */

import UIKit
import NeuraSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NeuraSDKManager.manager.setup()
        application.applicationIconBadgeNumber = 0
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NeuraSDKManager.manager.userRegisteredForRemoteNotifications(tokenData: deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard
            let info = userInfo as? [NSString: NSObject],
            let eventIdentifier = info["event_type"] as? String
            else {
                return
        }
        
        self.handleAction(identifier: kTookActionIdentifier, eventIdentifier: eventIdentifier)
        completionHandler(.noData)
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
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
        guard
            let info = userInfo as? [NSString: NSObject],
            let eventIdentifier = info["event_type"] as? String
            else {
                return
        }
        
        self.handleAction(identifier: identifier, eventIdentifier: eventIdentifier)
        completionHandler()
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
        guard
            let info = notification.userInfo as? [NSString: NSObject],
            let eventIdentifier = info["identifier"] as? String
            else {
                return
        }
        
        self.handleAction(identifier: identifier, eventIdentifier: eventIdentifier)
        completionHandler()
    }
    
    private func handleAction(identifier: String?, eventIdentifier: String) {
        guard
            let actionIndentifier = identifier
            else {
                return
        }
        
        if actionIndentifier == kTookActionIdentifier {
            NeuraSDKManager.manager.addTookCount(identifier: eventIdentifier)
            
        } else if actionIndentifier == kLaterActionIdentifier {
            let fireDate = Date() + TimeInterval (15 * 60)
            NeuraSDKManager.manager.showReminder(identifier: eventIdentifier, fireDate:fireDate, repeatInterval: NSCalendar.Unit(rawValue: 0))
        }
    }
}

