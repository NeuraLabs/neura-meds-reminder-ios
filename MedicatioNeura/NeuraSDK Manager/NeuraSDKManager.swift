//
//  NeuraSDKManager.swift
//  MedicatioNeura
//
//  Created by Gal Mirkin on 23/11/2016.
//  Copyright © 2016 neura. All rights reserved.
//

/**
 NeuraSDKManager class is a wrapper for NeuraSDK. It enables a central location that handles all med adherence needs in a single location
 */
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
        let permissions = [ "sleepingHabits"]
        
        /*
         This logs the user in. In this case, we're saving a bool to userDefaults to indicate that the user is logged in.
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
                                
                                NeuraSDKManager.manager.subscribeToEvents(events: events)
                                callback(true, nil)
        })
    }
    
    func enablePushNotification() {
        
        NeuraSDKPushNotification.enableAutomaticPushNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveRemoteNotification), name: NSNotification.Name(rawValue: kNeuraSDKDidReceiveRemoteNotification), object: nil)
        print(NeuraSDKPushNotification.getDeviceToken())
        
        self.setupLocalNotificationsFallback()
    }
    
    /**
     Neura push to SDK feature receives the silent push from Neura's server and post a notification "NeuraSDKDidReceiveRemoteNotification".
     This function is the selector that handles the content of the silent push and displays relevant notifications
     */
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
    
    func daysFromLogin() -> Int {
        
        let loginDate = UserDefaults.standard.object(forKey: kLoginDate) as! Date
        let components = Calendar.current.dateComponents([Calendar.Component.day], from: loginDate, to: NSDate() as Date)
        return components.day!
    }
    
    func addTookCount(identifier: String) {
        
        var tookKey = ""
        switch identifier {
        case kTakePillboxEventIdentifier:
            tookKey = kPillboxTookCount
            break
        case kMorningEventIdentifier:
            tookKey = kMorningTookCount
            break
        case kEveningEventIdentifier:
            tookKey = kEveningTookCount
            break
        default:
            break
        }
        
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: tookKey) + 1, forKey: tookKey)
        self.updateMissedCount(identifier: identifier, number: -1)
        UserDefaults.standard.synchronize()
    }
    
    func showReminder(identifier: String, fireDate: Date, repeatInterval: NSCalendar.Unit) {

        let alertText: (title: String?, body: String?) = self.alertText(identifier: identifier)
        
        if (alertText.0 != nil) {
            self.setupNotificationsSettings(alertTitle: alertText.title!,
                                            alertBody: alertText.body!,
                                            identifier: identifier,
                                            fireDate: fireDate,
                                            repeatInterval: repeatInterval)
        }
    }

// MARK: - private functions
    
    private func subscribeToEvents(events: NSMutableArray)   {
        weak var weakSelf = self
        NeuraSDKManager.manager.subscribeToEvent(events.firstObject as! String,identifier: events.firstObject as! String, callback:
                                                    { (success, error) in
                                                        events.removeObject(at: 0)
                                                        if events.count > 0 {
                                                            weakSelf?.subscribeToEvents(events: events)
                                                        }
                                                    }
                                                )
    }
    
    private func subscribeToEvent(_ eventName: String, identifier: String, callback: @escaping (_ success: Bool, _ error: String?) -> ()) {
        
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
    
    private func showReminderIfRequired(_ eventInfo: [String: NSObject]) {
        
        guard
            let nameString = eventInfo["name"] as? String,
            let eventName = EventName(rawValue: nameString)
            else {
                return
        }
        
        guard eventName == .eventUserGotUp || eventName == .eventUserWokeUp || eventName == .eventUserIsAboutToGoToSleep else {
            return
        }
        
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        
        let day = components.day
        
        switch eventName {
        case .eventUserGotUp: // handles both morning pills and 30 minutes later handles pillbox reminder
            self.setupLocalNotificationsFallback()
            let takePillboxEventDate = UserDefaults.standard.integer(forKey: kTakePillboxEventDate)
            if takePillboxEventDate != day {
                self.handlePushEvent(eventDay: (day: day!, eventDateUserDefaultsKey: kTakePillboxEventDate), eventIdentifier: kTakePillboxEventIdentifier, fireDate: now + TimeInterval (30 * 60))
            }
            
            let morningEventDate = UserDefaults.standard.integer(forKey: kMorningEventDate)
            if morningEventDate != day {
                self.handlePushEvent(eventDay: (day: day!, eventDateUserDefaultsKey: kMorningEventDate), eventIdentifier: kMorningEventIdentifier, fireDate: now)
            }
        case .eventUserWokeUp: // handles morning pills
            self.setupLocalNotificationsFallback()
            let morningEventDate = UserDefaults.standard.integer(forKey: kMorningEventDate)
            
            if morningEventDate != day {
                self.handlePushEvent(eventDay: (day: day!, eventDateUserDefaultsKey: kMorningEventDate), eventIdentifier: kMorningEventIdentifier, fireDate: now)
            }
        case .eventUserIsAboutToGoToSleep: // handles evening pills
            let eveningEventDate = UserDefaults.standard.integer(forKey: kEveningEventDate)
            
            if eveningEventDate != day {
                self.handlePushEvent(eventDay: (day: day!, eventDateUserDefaultsKey: kEveningEventDate), eventIdentifier: kEveningEventIdentifier, fireDate: now)
            }
        }
        UserDefaults.standard.synchronize()
    }
    
    private func handlePushEvent(eventDay: (day:Int, eventDateUserDefaultsKey: String), eventIdentifier: String, fireDate: Date) {
        UserDefaults.standard.set(eventDay.day, forKey: eventDay.eventDateUserDefaultsKey)
        self.showReminder(identifier: eventIdentifier, fireDate: fireDate, repeatInterval: NSCalendar.Unit(rawValue: 0))
        self.updateMissedCount(identifier: eventIdentifier, number: 1)
    }
    
    private func setupLocalNotificationsFallback() {
        // to avoid sync issues
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIApplication.shared.cancelAllLocalNotifications()
            
            let now = Date()
            let tomorrow = NSCalendar.current.date(byAdding: Calendar.Component.day, value: 1, to: now)
            let fireDate = NSCalendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: tomorrow!)
            
            self.showReminder(identifier: kMorningEventIdentifier, fireDate: fireDate!, repeatInterval: NSCalendar.Unit.day)
        }
    }
    
    private func setupNotificationsSettings(alertTitle: String, alertBody: String, identifier: String, fireDate: Date, repeatInterval: NSCalendar.Unit) {
        
        let sharedApp = UIApplication.shared
        
        let tookAction = UIMutableUserNotificationAction()
        tookAction.activationMode = .foreground
        tookAction.title = NSLocalizedString("Took", comment: "Took")
        tookAction.isDestructive = false
        tookAction.isAuthenticationRequired = false
        tookAction.identifier = kTookActionIdentifier
        tookAction.behavior = .default
        
        let laterAction = UIMutableUserNotificationAction()
        laterAction.activationMode = .foreground
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
        notification.repeatInterval = repeatInterval
        notification.timeZone = TimeZone.current
        sharedApp.scheduleLocalNotification(notification)
    }
    
    private func updateMissedCount(identifier: String, number: Int) {
        
        var missedKey = ""
        switch identifier {
        case kTakePillboxEventIdentifier:
            missedKey = kPillboxMissedCount
            break
        case kMorningEventIdentifier:
            missedKey = kMorningMissedCount
            break
        case kEveningEventIdentifier:
            missedKey = kEveningMissedCount
            break
        default:
            break
        }
        
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: missedKey) + number, forKey: missedKey)
        UserDefaults.standard.synchronize()
    }
    
    private func alertText(identifier: String) -> (title: String?, body: String?) {
        switch identifier {
        case kTakePillboxEventIdentifier:
            return(title: NSLocalizedString("Hi", comment: "Hi"), body: NSLocalizedString("Don't forget to take your pillbox!", comment: "Don't forget to take your pillbox!"))
        case kMorningEventIdentifier:
            return(title: NSLocalizedString("Good morning", comment: "Good morning"), body: NSLocalizedString("Time for your morning pills :)", comment: "Time for your morning pills :)"))
        case kEveningEventIdentifier:
            return(title: NSLocalizedString("Good evening", comment: "Good evening"), body: NSLocalizedString("Time for your evening pills", comment: "Time for your evening pills"))
        default:
            return(title: nil, body: nil); //only show remiders for specific identifiers
        }
    }
}
