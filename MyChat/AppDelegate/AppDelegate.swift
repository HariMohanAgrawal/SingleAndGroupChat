//
//  AppDelegate.swift
//  MyChat
//
//  Created by Amit on 06/07/18.
//  Copyright © 2018 Amit. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    var window: UIWindow?  


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        self.configureNotification()

        if UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEYS.IS_LOGIN) == true {
            let vc  =  UIStoryboard.ChatUserListViewController()
            let navC = UINavigationController(rootViewController: vc)
            self.window?.rootViewController = navC  
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
      
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        application.applicationIconBadgeNumber = 0  
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    func configureNotification() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            center.delegate = self
            let openAction = UNNotificationAction(identifier: "OpenNotification", title: NSLocalizedString("Abrir", comment: ""), options: UNNotificationActionOptions.foreground)
            let deafultCategory = UNNotificationCategory(identifier: "CustomSamplePush", actions: [openAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories(Set([deafultCategory]))
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
}

extension AppDelegate : MessagingDelegate {
    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
        // Change this to your preferred presentation option
        completionHandler([.badge, .alert, .sound])  
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Open Action")
        case "Snooze":
            print("Snooze")
        case "Delete":
            print("Delete")
        default:
            print("default")
        }
        
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
        completionHandler()
    }
    
    func handleNotifications(){  
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()    // to remove all delivered notifications
        center.removeAllPendingNotificationRequests()   // to remove all pending notifications
        UIApplication.shared.applicationIconBadgeNumber = 0 // to clear the icon notification badge
    }
    
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.setValue(fcmToken, forKey: USER_DEFAULTS_KEYS.FCM_Key)
        
        if UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEYS.IS_LOGIN) == true {
            self.updateFCMAPI(tokenKey: fcmToken)
        }
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
    func updateFCMAPI(tokenKey: String) {
        if Reachability.isConnectedToNetwork() {
            if (Auth.auth().currentUser?.uid) != nil {
                User.updateUserToken(tokenStr:tokenKey, completion: { (status)  in
                    if status == true {
                        
                    }
                    else {  

                    }
                })
            }
        }
        else{
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    // [END ios_10_data_message]o
}
