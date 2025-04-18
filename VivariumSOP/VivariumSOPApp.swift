//
//  VivariumSOPApp.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 9/2/24.
//

import SwiftUI
import Firebase


import UIKit
import UserNotifications
//import FirebaseMessaging

//class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
//
//  
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        FirebaseApp.configure()
//        
//        // Register for remote notifications
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if let error = error {
//                print("Error requesting notification authorization: \(error)")
//            } else {
//                DispatchQueue.main.async {
//                    application.registerForRemoteNotifications()
//                }
//            }
//        }
//
//        Messaging.messaging().delegate = self
//
//        return true
//    }
//
//    // Handle the receipt of a notification token
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//    }
//
//    // Handle notification errors
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register for remote notifications: \(error)")
//    }
//
//    // Handle incoming notifications while app is in the foreground
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        // Display the notification as a banner and play sound
//        completionHandler([.list, .sound, .badge])
//    }
//
//    // Handle notification taps
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        // Handle notification tap
//        completionHandler()
//    }
//
//    // FCM delegate method to retrieve the registration token
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        //print("Firebase registration token: \(fcmToken ?? "")")
//    }
//}

@main
struct VivariumSOPApp: App {
    
    //@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
      @AppStorage("log_status") var logStatus: Bool = false
      @AppStorage("account_Type") var userAccountType: String = ""
      @StateObject var service = SOPService()
      @StateObject var navigationHandler = NavigationHandler()
    @StateObject var sharedViewModel = PDFCategoryViewModel()
      init() {
          FirebaseApp.configure()
      }
    
    var body: some Scene {
          WindowGroup {
              if logStatus {
                  MainTabBarView()
                      .environmentObject(navigationHandler)
                      .environmentObject(service)
                      .environmentObject(sharedViewModel)
                      .onAppear {
                          Task {
                             // await NotificationsManager.shared.requestPermission()
                              //try await service.checkAndScheduleNotifications()
                          }
                      }
              } else {
                  LoginView()
              }
          }
      }
}
