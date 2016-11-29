//
//  NeuraSDKManager.swift
//  MedicatioNeura
//
//  Created by Gal Mirkin on 23/11/2016.
//  Copyright © 2016 neura. All rights reserved.
//

import Foundation
import NeuraSDK
import UserNotifications



enum EventName : String {
    case eventUserGotUp = "userGotUp"
    case eventUserWokeUp = "userWokeUp"
    case eventUserIsAboutToGoToSleep = "userIsAboutToGoToSleep"
}


class NeuraSDKManager {
    
    
    /// Singleton
    static let manager = NeuraSDKManager()
    
    // MARK: - Private vars
    weak private(set) var neuraSDK: NeuraSDK? = nil
    
    
    static var appUID = "9f2797dd7ccff57076d41478d734f18728d7d83a6d772aa6462e2a2bdaa7c9dc"
    static  var appSecret = "7019b20dbe40eeb42a0d27263d4de99c379fcf6b3f7c04e161f7740aa7fca86b"
    
    func setup() {
        // Sets up the Neura SDK
        neuraSDK = NeuraSDK.sharedInstance()
        neuraSDK?.appUID = NeuraSDKManager.appUID
        neuraSDK?.appSecret = NeuraSDKManager.appSecret
        
        //if the user is login set pushNotification
        if NeuraSDKManager.manager.IsUserLogin() {
            NeuraSDKManager.manager.enablePushNotification()
        }
        
    }
    
    
    func IsUserLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: kIsUserLogin)
    }
    
    
    func login(viewController: UIViewController?,
               callback: @escaping (_ success: Bool, _ error: String?) -> ()) {
        /*
         Specify your permissions array in an NSArray. These can be found in the the developer
         console under "Permissions."
         */
        
        let permissions = [ "userGotUp",
                            "userWokeUp",
                            "userIsAboutToGoToSleep" ]
        
        
        /*This logs the user in. In this case, we're saving a bool to userDefaults to indicate that the user is logged in.
         Your implementation may be different
         */
        neuraSDK?.authenticate(withPermissions: permissions,
                               userInfo: ["type" : "1"],
                               on: viewController,
                               withHandler: { (token, error) in
                                
                                
                                // Handle authentication error
                                guard error == nil else {
                                    callback(false, error)
                                    return
                                }
                                
                                //save user login key
                                UserDefaults.standard.set(true, forKey: kIsUserLogin)
                                UserDefaults.standard.set(NSDate(), forKey: kLoginDate)
                                UserDefaults.standard.synchronize()
                                
                                //if the user is login set pushNotification
                                NeuraSDKManager.manager.enablePushNotification()
                                
                                
                                
                                let events = [ "userGotUp",
                                               "userWokeUp",
                                               "userIsAboutToGoToSleep" ] as NSMutableArray
                                
                                self.subscribeToEvents(events: events )
                                callback(true, nil)
        })
    }
    
    
    func enablePushNotification() {
        
        NeuraSDKPushNotification.enableAutomaticPushNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRemoteNotification), name: NSNotification.Name(rawValue: kNeuraSDKDidReceiveRemoteNotification), object: nil)
        print(NeuraSDKPushNotification.getDeviceToken())
    }
    
    
    
    @objc func didReceiveRemoteNotification(_ notification: Notification) {
        // Ensure a push for neura event received.
        guard
            let data = notification.userInfo?["data"] as? [String: NSObject],
            let pushType = data["pushType"] as? String,
            pushType == "neura_event",
            let pushDataString = data["pushData"] as? String
            else { return }
        
        // Parse push data string
        let json = try? JSONSerialization.jsonObject(with: pushDataString.data(using: .utf8)!)
        guard let pushData = json as? [String: NSObject] else { return }
        
        // Event info
        guard let eventInfo = pushData["event"] as? [String: NSObject] else { return }
        
        self.showReminderIfRequired(eventInfo)
        
    }
    
    
    private func showReminderIfRequired(_ eventInfo: [String: NSObject]) {
        
        guard
            let nameString = eventInfo["name"] as? String,
            let eventName = EventName(rawValue: nameString)
            else {
                return
        }
        
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        
        let day = components.day //Int(arc4random_uniform(9999))
        
        
        // take Pillbox
        if eventName == .eventUserGotUp || eventName == .eventUserWokeUp {
            
            let takePillboxEventDate = UserDefaults.standard.integer(forKey: kTakePillboxEventDate)
            
            if !(takePillboxEventDate == day) {
                UserDefaults.standard.set(day, forKey: kTakePillboxEventDate)
                let fireDate = now + TimeInterval (30 * 60)
                self.showReminder(identifier: kTakePillboxEventIdentifier, fireDate: fireDate)
                self.updateMissedCount(identifier: kTakePillboxEventIdentifier, number: 1)
            }
            
            // morning event
            let morningEventDate = UserDefaults.standard.integer(forKey: kMorningEventDate)
            
            if !(morningEventDate == day) {
                UserDefaults.standard.set(day, forKey: kMorningEventDate)
                self.showReminder(identifier: kMorningEventIdentifier, fireDate: now)
                self.updateMissedCount(identifier: kMorningEventIdentifier, number: 1)
            }
        }
        
        // evening event
        if eventName == .eventUserIsAboutToGoToSleep {
            let eveningEventDate = UserDefaults.standard.integer(forKey: kEveningEventDate)
            
            if !(eveningEventDate == day) {
                UserDefaults.standard.set(day, forKey: kEveningEventDate)
                self.showReminder(identifier: kEveningEventIdentifier, fireDate: now)
                self.updateMissedCount(identifier: kEveningEventIdentifier, number: 1)
            }
        }
        UserDefaults.standard.synchronize()
    }
    
    
    
    private func setupNotificationsSettings(alertTitle: String, alertBody: String, identifier: String, fireDate: Date) {
        
        let sharedApp = UIApplication.shared
        
        let tookAction = UIMutableUserNotificationAction()
        tookAction.activationMode = .background
        tookAction.title = NSLocalizedString("Took", comment: "Took")
        tookAction.isDestructive = false
        tookAction.isAuthenticationRequired = false
        tookAction.identifier = kTookActionIdentifier
        tookAction.behavior = .default
        
        let laterAction = UIMutableUserNotificationAction()
        laterAction.activationMode = .background
        laterAction.title = NSLocalizedString("Remind me later", comment: "Remind me later")
        laterAction.isDestructive = false
        laterAction.isAuthenticationRequired = false
        laterAction.identifier = kLaterActionIdentifier
        laterAction.behavior = .default
        
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = identifier
        actionCategory.setActions([tookAction, laterAction], for: .default)
        
        let notificationSettings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: [actionCategory])
        sharedApp.registerUserNotificationSettings(notificationSettings)
        
        
        let notification = UILocalNotification()
        notification.alertTitle = alertTitle
        notification.alertBody = alertBody
        notification.fireDate = fireDate
        notification.category = identifier
        notification.userInfo = ["identifier" : identifier]
        sharedApp.scheduleLocalNotification(notification)
    }
    
    
    func subscribeToEvents(events: NSMutableArray)   {
        weak var weakSelf = self
        NeuraSDKManager.manager.subscribeToEvent(events.firstObject as! String,identifier: events.firstObject as! String, callback:{ (success, error) in
            events.removeObject(at: 0)
            
            if events.count > 0 {
                weakSelf?.subscribeToEvents(events: events)
            }
        })
    }
    
    
    func removeSubscriptions(events: NSMutableArray)   {
        weak var weakSelf = self
        NeuraSDKManager.manager.removeSubscription(events.firstObject as! String)  {
            success, error in
            
            events.removeObject(at: 0)
            
            if events.count > 0 {
                weakSelf?.removeSubscriptions(events: events)
            }
        }
    }
    
    
    func subscribeToEvent(_ eventName: String, identifier: String, callback: @escaping (_ success: Bool, _ error: String?) -> ()) {
        
        neuraSDK?.subscribe(toEvent: eventName,
                            identifier: identifier,
                            webHookID: nil) { (responseData, error) in
                                
                                print("Subscribe to event:\(eventName) responseData = \(responseData) error = \(error) ")
                                
                                guard error == nil else {
                                    callback(false, error)
                                    return
                                }
                                callback(true, nil)
        }
    }
    
    
    func removeSubscription(_ identifier: String, callback: @escaping (_ success: Bool, _ error: String?) -> ()) {
        
        neuraSDK?.removeSubscription(withIdentifier: identifier) { responseData, error in
            
            print("Remove subscription identifier:\(identifier) = \(responseData) error = \(error) ")
            guard error == nil else {
                callback(false, error)
                return
            }
            callback(true, nil)
        }
    }
    
    
    func eveningPillsProgress() -> Int {
        
        let loginDate = UserDefaults.standard.object(forKey: kLoginDate) as! Date
        let today = NSDate() as Date
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: loginDate, to: today)
        return components.day!
    }
    
    
    func greetingMessage() -> String {
        
        let cal = NSCalendar.current
        let comps = cal.component(.hour, from: Date())
        let hour = comps.hashValue
        
        var currentTimeOfDay = ""
        switch hour {
        case 6 ... 12:
            currentTimeOfDay = NSLocalizedString("Good morning", comment: "Good morning")
        case 12 ... 18:
            currentTimeOfDay = NSLocalizedString("Good afternoon", comment: "Good afternoon")
        case 18 ... 24:
            currentTimeOfDay = NSLocalizedString("Good evening", comment: "Good evening")
        case 00 ... 06:
            currentTimeOfDay = NSLocalizedString("Good night", comment: "Good night")
        default:
            currentTimeOfDay = NSLocalizedString("Welcome", comment: "Welcome")
        }
        return currentTimeOfDay
    }
    
    
    func addTookCount(identifier: String) {
        
        if identifier == kTakePillboxEventIdentifier {
            var num = UserDefaults.standard.integer(forKey: kPillboxTookCount)
            num += 1
            UserDefaults.standard.set(num, forKey: kPillboxTookCount)
            self.updateMissedCount(identifier: kTakePillboxEventIdentifier, number: -1)
            
        } else if identifier == kMorningEventIdentifier {
            var num = UserDefaults.standard.integer(forKey: kMorningTookCount)
            num += 1
            UserDefaults.standard.set(num, forKey: kMorningTookCount)
            self.updateMissedCount(identifier: kMorningEventIdentifier, number: -1)
            
        } else if identifier == kEveningEventIdentifier {
            var num = UserDefaults.standard.integer(forKey: kEveningTookCount)
            num += 1
            UserDefaults.standard.set(num, forKey: kEveningTookCount)
            self.updateMissedCount(identifier: kEveningEventIdentifier, number: -1)
        }
        UserDefaults.standard.synchronize()
    }
    
    
    func updateMissedCount(identifier: String, number: Int) {
        
        if identifier == kTakePillboxEventIdentifier {
            var num = UserDefaults.standard.integer(forKey: kPillboxMissedCount)
            num += number
            UserDefaults.standard.set(num, forKey: kPillboxMissedCount)
            
        } else if identifier == kMorningEventIdentifier {
            var num = UserDefaults.standard.integer(forKey: kMorningMissedCount)
            num += number
            UserDefaults.standard.set(num, forKey: kMorningMissedCount)
            
        } else if identifier == kEveningEventIdentifier {
            var num = UserDefaults.standard.integer(forKey: kEveningMissedCount)
            num += number
            UserDefaults.standard.set(num, forKey: kEveningMissedCount)
        }
        UserDefaults.standard.synchronize()
    }
    
    
    func showReminder(identifier: String, fireDate: Date ) {
        
        
        if identifier == kTakePillboxEventIdentifier {
            
            let alertBody = NSLocalizedString("Don't forget to take your pillbox!", comment: "Don't forget to take your pillbox!")
            let alertTitle = NSLocalizedString("Hi", comment: "Hi")
            
            self.setupNotificationsSettings(alertTitle: alertTitle,
                                            alertBody: alertBody,
                                            identifier: kTakePillboxEventIdentifier,
                                            fireDate: fireDate)
        }
        
        
        if identifier == kMorningEventIdentifier {
            let alertBody = NSLocalizedString("Time for your morning pills :)", comment: "Time for your morning pills :)")
            let alertTitle = NSLocalizedString("Good morning", comment: "Good morning")
            
            self.setupNotificationsSettings(alertTitle: alertTitle,
                                            alertBody: alertBody,
                                            identifier:kMorningEventIdentifier,
                                            fireDate:fireDate)
        }
        
        if identifier == kEveningEventIdentifier {
            let alertBody = NSLocalizedString("Time for your evening pills", comment: "Time for your evening pills")
            let alertTitle = NSLocalizedString("Good evening", comment: "Good evening")
            self.setupNotificationsSettings(alertTitle: alertTitle,
                                            alertBody: alertBody,
                                            identifier:kEveningEventIdentifier,
                                            fireDate:fireDate)
        }
    }
    
}



