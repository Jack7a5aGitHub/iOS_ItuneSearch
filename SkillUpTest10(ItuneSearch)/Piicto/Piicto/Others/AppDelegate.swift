//
//  AppDelegate.swift
//  Piicto
//
//  Created by OkuderaYuki on 2018/01/06.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseMessaging
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    #if DEVELOPMENT
    let plistName = "GoogleService-Info"
    #elseif STAGING
    let plistName = "GoogleService-Info-Staging"
    #else
    let plistName = "GoogleService-Info"
    #endif
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 1, green: 0.5294117647, blue: 0.4705882353, alpha: 1)
        
        if
            let fileName = Bundle.main.path(forResource: plistName, ofType: "plist"),
            let options = FirebaseOptions(contentsOfFile: fileName) {
            print(fileName)
            FirebaseApp.configure(options: options)
        }

        // リモート通知 (iOS10のみ対応)
//        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(options: authOptions,
//                                                                completionHandler: { granted, error in
//                                                                    if let error = error {
//                                                                        print(error.localizedDescription)
//                                                                    }
//
//                                                                    if granted {
//                                                                        print("granted!!")
//                                                                        DispatchQueue.main.async {
//                                                                            application.registerForRemoteNotifications()
//                                                                        }
//                                                                        return
//                                                                    }
//                                                                    // PUSH通知拒否
//                                                                    print("PUSH通知拒否")
//        })

        // UNUserNotificationCenterDelegateの設定
        //UNUserNotificationCenter.current().delegate = self
        // FCMのMessagingDelegateの設定
        //Messaging.messaging().delegate = self

        // リモートプッシュの設定
        application.registerForRemoteNotifications()

        // アプリ起動時にFCMのトークンを取得し、表示する
//        let token = Messaging.messaging().fcmToken
//        print("FCM token: \(token ?? "")")
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let token = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("device token is: \(token)")
        print("didRegisterForRemote")
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    /// アプリがバックグラウンドで通知を受け、ユーザが通知をタップしてアプリをフォアグランドにした時に呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        debugPrint("You tapped the message.")

        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(String(describing: userInfo["gcm.message_id"]))")
        // Print full message.
        print("%@", userInfo)
        completionHandler()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // アプリがフォアグランドの時に通知を受け取ると呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Now Fourground. Message ID: \(String(describing: userInfo["gcm.message_id"]))")

        // Print full message.
        print("%@", userInfo)

        // サウンドとアラート
        completionHandler([.sound, .alert])
    }
}

extension AppDelegate: MessagingDelegate {
    // Receive data message on iOS 10 devices.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }
}
