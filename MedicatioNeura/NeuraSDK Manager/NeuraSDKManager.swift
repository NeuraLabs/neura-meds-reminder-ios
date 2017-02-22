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

let kPushTokenUserDefaultsKey = "PushTokenUserDefaultsKey"
let kNeuraIDUserDefaultsKey = "NeuraIDUserDefaultsKey"
let kRetryAddUserDefaultsKey = "RetryAddUserDefaultsKey"

enum EventName : String {
    case eventUserGotUp = "userGotUp"
    case eventUserWokeUp = "userWokeUp"
    case eventUserIsAboutToGoToSleep = "userIsAboutToGoToSleep"
}

class NeuraSDKManager {
    
    /// Singleton
    static let manager = NeuraSDKManager()
    
    static var appUID = "9f2797dd7ccff57076d41478d734f18728d7d83a6d772aa6462e2a2bdaa7c9dc"
    static  var appSecret = "7019b20dbe40eeb42a0d27263d4de99c379fcf6b3f7c04e161f7740aa7fca86b"
    
    func setup() {
        // Sets up the Neura SDK
        NeuraSDK.shared.appUID = NeuraSDKManager.appUID
        NeuraSDK.shared.appSecret = NeuraSDKManager.appSecret
        
        self.registerForRemoteNotifications()
        
        let retryAddUserToServer = UserDefaults.standard.bool(forKey: kRetryAddUserDefaultsKey)
        if retryAddUserToServer {
            let pushToken = UserDefaults.standard.value(forKey: kPushTokenUserDefaultsKey) as! String
            let neuraID = UserDefaults.standard.value(forKey: kNeuraIDUserDefaultsKey) as! String
            self.addUserToServer(neuraID: neuraID, pushToken: pushToken){_,_ in }
        }
    }
    
    func IsUserLogin() -> Bool {
        return UserDefaults.standard.bool(forKey: kIsUserLogin)
    }

// MARK: - login and subscribe
    func login(viewController: UIViewController,
               callback: @escaping (Bool, String?) -> ()) {
        
        /*
         This logs the user in. In this case, we're saving a bool to userDefaults to indicate that the user is logged in.
         Your implementation may be different
         */
        // Authentication request
        let authRequest = NeuraAuthenticationRequest(controller: viewController)
        
        // Authenticate.
        NeuraSDK.shared.authenticate(with: authRequest) { result in
            if result.success {
                // Success. result.token available
                //save user login key
                UserDefaults.standard.set(true, forKey: kIsUserLogin)
                UserDefaults.standard.set(NSDate(), forKey: kLoginDate)
                UserDefaults.standard.setValue(result.token, forKey: kNeuraIDUserDefaultsKey)
                UserDefaults.standard.synchronize()
                
                let pushToken = UserDefaults.standard.value(forKey: kPushTokenUserDefaultsKey) as! String
                self.addUserToServer(neuraID: result.token!, pushToken: pushToken){_,_ in }
                callback(true, nil)
            } else {
                // Failed. An error description available on result.error
                callback(false, result.errorString)
            }
        }
    }

    private func subscribeToEvent(eventName: EventName, identifier: String, callback: @escaping (_ success: Bool, _ error: String?) -> ()) {
        // Adding a new subscription.
        #if DEBUG
            let webhookId = "dokkuWebhook"
        #else
            let webhookId = "herokuWebhook"
        #endif
        
        let newSubscription = NSubscription(eventName: eventName.rawValue,
                                            identifier: eventName.rawValue + "_" + identifier,
                                            webhookId: webhookId)
        
        NeuraSDK.shared.add(newSubscription) { result in
            if (result.error != nil) {
                callback(false, result.errorString)
            } else {
                callback(true, nil)
            }
        }
    }

    private func addUserToServer(neuraID: String, pushToken: String, completion: @escaping (Bool, String) -> ()) {
        serverManager.manager.addUser(neuraToken: neuraID, pushToken: pushToken) { (success, resultValue) in
            if success {
                let events = [ EventName.eventUserGotUp,
                               EventName.eventUserWokeUp,
                               EventName.eventUserIsAboutToGoToSleep ] as NSMutableArray
                
                var errorMessage = ""
                var subscribeSuccess = true
                
                for event in events {
                    self.subscribeToEvent(eventName: event as! EventName, identifier: resultValue, callback: { (success: Bool, error: String?) in
                        subscribeSuccess = subscribeSuccess && success
                        if (error != nil) {
                            errorMessage = errorMessage + error!
                        }
                    })
                }
                UserDefaults.standard.set(!subscribeSuccess, forKey: kRetryAddUserDefaultsKey)
                completion(subscribeSuccess, errorMessage)
            } else {
                UserDefaults.standard.set(true, forKey: kRetryAddUserDefaultsKey)
                completion(success, resultValue)
            }
        }
    }
    
// MARK: - remote notifications registration
    private func registerForRemoteNotifications () {
        let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let userNotificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: userNotificationTypes,
                                                                                              categories: [self.getCategoryByIdentifier(identifier: kMorningEventIdentifier),
                                                                                                           self.getCategoryByIdentifier(identifier: kEveningEventIdentifier),
                                                                                                           self.getCategoryByIdentifier(identifier: kTakePillboxEventIdentifier)])
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.registerUserNotificationSettings(userNotificationSettings)
    }

    func userRegisteredForRemoteNotifications(tokenData: Data) {
        
        let tokenString = tokenData.reduce("", {$0 + String(format: "%02X", $1)})
        let tokenStringReplaced = tokenString.replacingOccurrences(of: "<", with:"" ).replacingOccurrences(of: ">", with:"" ).replacingOccurrences(of: " ", with:"" )
        
        UserDefaults.standard.setValue(tokenStringReplaced, forKey: kPushTokenUserDefaultsKey)
        UserDefaults.standard.synchronize()
    }
    
// MARK: - utilities
    func daysFromLogin() -> Int {
        
        guard let loginDate = UserDefaults.standard.object(forKey: kLoginDate) as? Date else {
            return 0
        }
        
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
    
    private func getCategoryByIdentifier(identifier: String) -> UIUserNotificationCategory {
        
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
        
        return actionCategory
    }
    
    private func setupNotificationsSettings(alertTitle: String, alertBody: String, identifier: String, fireDate: Date, repeatInterval: NSCalendar.Unit) {
        
        let sharedApp = UIApplication.shared
        
        let notificationSettings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: [self.getCategoryByIdentifier(identifier: identifier)])
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
    
    private func alertText(identifier: String) -> (title: String?, body: String?) {
        switch identifier {
        case kTakePillboxEventIdentifier:
            return(title: NSLocalizedString("Hi", comment: "Hi"), body: NSLocalizedString("Don't forget to take your pillbox!", comment: "Don't forget to take your pillbox!"))
        case kMorningEventIdentifier:
            return(title: NSLocalizedString("Good morning", comment: "Good morning"), body: NSLocalizedString("Time for your morning pills :)", comment: "Time for your morning pills :)"))
        case kEveningEventIdentifier:
            return(title: NSLocalizedString("Good evening", comment: "Good evening"), body: NSLocalizedString("Time for your evening pills", comment: "Time for your evening pills :)"))
        default:
            return(title: nil, body: nil); //only show remiders for specific identifiers
        }
    }
}
