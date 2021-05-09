//
//  AppDelegate.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 9/18/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
import TwilioVideo

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    // Notification repository
    let notificationRepository = NotificationRepository()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
            
        // Configure the Firebase App
        FirebaseApp.configure()
        
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        
        // Register app for Firebase Cloud Messaging
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        if #available(iOS 10, *)
        { // iOS 10 support
            //create the notificationCenter
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            // set the type as sound or badge
            center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
                if granted {
                    print("Notification Enable Successfully")
                }else{
                    print("Some Error Occur")
                }
            }
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    // [START receive_message (data notification) ]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
      // Print message ID.
        
        var arrayOfKeys: [Any] = []
        
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
        }
                  
        for key in userInfo.keys {
            arrayOfKeys.append(key)
        }
        
      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message (data notification) ]

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MyHBT_API")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    let messageTitle = notification.request.content.title
    let messageContent = notification.request.content.body
    
    let windowScene = UIApplication.shared
                    .connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .first
    if let windowScene = windowScene as? UIWindowScene {
        window = UIWindow(windowScene: windowScene)
    }
    
    if (messageTitle == "incoming-video-call") {
        //self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let incomingCallViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "IncomingVideoCallViewController") as! IncomingVideoCallViewController
        self.window?.frame = UIScreen.main.bounds
        self.window?.backgroundColor = .clear
        //self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Get the chat room name in which 2 users will be in
        let chatRoomName = messageContent.components(separatedBy: "-")[0]
        
        // Get user id of the caller
        let callerUserId = messageContent.components(separatedBy: "-")[1]
                
        // Pass chat room name and user id caller into next view controller
        incomingCallViewController.callerUserId = callerUserId
        incomingCallViewController.chatRoomName = chatRoomName
        
        self.window?.rootViewController = incomingCallViewController
        self.window?.makeKeyAndVisible()
    }
    
    print("\(messageTitle) \(messageContent)")
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    // [START_EXCLUDE]
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }
    
    // [END_EXCLUDE]
    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // [START_EXCLUDE]
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }
    // [END_EXCLUDE]
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    // Print full message.
    print(userInfo)

    completionHandler()
  }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        // The object to get device model name
        let modelName = UIDevice.modelName
        
        // Model name may have space in it and cause error when saved in and fetched from database
        // so, we will need to change those space into "-"
        let modifiedModelName = modelName.replacingOccurrences(of: " ", with: "-")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        // Call the function to send registration token to the database
        notificationRepository.createOrUpdateNotificationSocket(socketId: fcmToken, deviceModel: modifiedModelName) { }
    }
    // [END refresh_token]
}
