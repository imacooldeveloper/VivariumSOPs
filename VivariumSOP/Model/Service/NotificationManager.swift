//
//  NotificationManager.swift
//  VivariumSOP
//
//  Created by Martin Gallardo on 1/31/25.
//

import Foundation
import UIKit
// Create a new NotificationManager class
//class NotificationManager: ObservableObject {
//    static let shared = NotificationManager()
//    
//    let notificationCenter = UNUserNotificationCenter.current()
//    
//    // Array of positive messages
//    let positiveMessages = [
//        "Ready to make today great! Keep up the excellent work! 🌟",
//        "Another day to excel in animal care! You're making a difference! 🐾",
//        "Your dedication to the vivarium makes all the difference! 💪",
//        "Time to shine! Your work matters more than you know! ✨",
//        "Keep up the amazing work with our animal friends! 🏆",
//        // Add more messages as needed
//    ]
//    
//    func requestAuthorization() {
//        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                print("Notification permission granted")
//                self.scheduleNotifications()
//            } else {
//                print("Notification permission denied")
//            }
//        }
//    }
//    
//    func scheduleNotifications() {
//        // Remove any existing notifications
//        notificationCenter.removeAllPendingNotificationRequests()
//        
//        // Create date components for the time range
//        var startComponents = DateComponents()
//        startComponents.hour = 8 // 8:00 AM
//        startComponents.minute = 0
//        
//        var endComponents = DateComponents()
//        endComponents.hour = 14 // 2:30 PM
//        endComponents.minute = 30
//        
//        // Schedule notifications for the next 30 days
//        for day in 0..<30 {
//            let randomHour = Int.random(in: 8...14)
//            let randomMinute = Int.random(in: 0...59)
//            
//            // Skip if we're past 2:30 PM
//            if randomHour == 14 && randomMinute > 30 {
//                continue
//            }
//            
//            var components = DateComponents()
//            components.hour = randomHour
//            components.minute = randomMinute
//            
//            // Create the notification
//            let content = UNMutableNotificationContent()
//            content.title = "Vivarium SOP Daily Motivation"
//            content.body = positiveMessages.randomElement() ?? "Have a great day!"
//            content.sound = .default
//            
//            // Create trigger for this specific time
//            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
//            
//            // Create request
//            let request = UNNotificationRequest(
//                identifier: "dailyMotivation-\(day)",
//                content: content,
//                trigger: trigger
//            )
//            
//            // Schedule the notification
//            notificationCenter.add(request) { error in
//                if let error = error {
//                    print("Error scheduling notification: \(error)")
//                }
//            }
//        }
//    }
//}


//class NotificationManager: ObservableObject {
//    static let shared = NotificationManager()
//    let notificationCenter = UNUserNotificationCenter.current()
//    
//    func requestAuthorization() {
//        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if granted {
//                print("Notification permission granted")
//                self.scheduleTestNotification()
//            } else {
//                print("Notification permission denied")
//            }
//        }
//    }
//    
//    func scheduleTestNotification() {
//        // Remove any existing notifications
//        notificationCenter.removeAllPendingNotificationRequests()
//        
//        // Create the notification content
//        let content = UNMutableNotificationContent()
//        content.title = "Vivarium SOP Daily Motivation"
//        content.body = "Keep up the amazing work with our animal friends! 🐾"
//        content.sound = .default
//        
//        // Set up the time components for 9:13
//        var components = DateComponents()
//        components.hour = 9
//        components.minute = 13
//        
//        // Create trigger for this specific time
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
//        
//        // Create the request
//        let request = UNNotificationRequest(
//            identifier: "testNotification",
//            content: content,
//            trigger: trigger
//        )
//        
//        // Schedule the notification
//        notificationCenter.add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error)")
//            } else {
//                print("Notification scheduled for 9:13")
//            }
//        }
//    }
//}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    @Published var isAuthorized = false
    
    func checkNotificationSettings() {
        notificationCenter.getNotificationSettings { settings in
            print("Notification settings:")
            print("Authorization status: \(settings.authorizationStatus.rawValue)")
            print("Sound enabled: \(settings.soundSetting.rawValue)")
            print("Badge enabled: \(settings.badgeSetting.rawValue)")
            print("Alert enabled: \(settings.alertSetting.rawValue)")
        }
    }
    
    func requestAuthorization() {
        checkNotificationSettings()  // Add this line
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestInitialAuthorization()
            case .authorized:
                DispatchQueue.main.async {
                    self.isAuthorized = true
                    self.scheduleTestNotification()
                }
            case .denied:
                print("Notifications are denied")
            default:
                break
            }
        }
    }
    
    private func requestInitialAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                    self.isAuthorized = true
                    self.scheduleTestNotification()
                } else {
                    print("Notification permission denied")
                    if let error = error {
                        print("Authorization error: \(error)")
                    }
                }
            }
        }
    }
    
    // Add variety to motivational messages
      let motivationalMessages = [
          "Ready for another great day in the vivarium! 🌟",
          "Your dedication to animal care makes all the difference! 🐾",
          "Making a positive impact, one day at a time! 💪",
          "Thank you for your commitment to excellence! ✨",
          "Your attention to detail helps ensure the best care! 🏆",
          "Every day is an opportunity to make a difference! 🌈",
          "Your work matters more than you know! 💡",
          "Making the vivarium a better place, every day! 🌟"
      ]
      
      func scheduleTestNotification() {
          notificationCenter.removeAllPendingNotificationRequests()
          
          let content = UNMutableNotificationContent()
          content.title = "Vivarium SOP Daily Motivation"
          content.body = motivationalMessages.randomElement() ?? "Keep up the amazing work! 🐾"
          content.sound = .default
          
          // Set up for 8:00 AM daily
          var dateComponents = DateComponents()
          dateComponents.hour = 8
          dateComponents.minute = 0
          dateComponents.timeZone = TimeZone.current
          
          let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
          
          let request = UNNotificationRequest(
              identifier: "dailyMotivation",
              content: content,
              trigger: trigger
          )
          
          notificationCenter.add(request) { error in
              if let error = error {
                  print("Error scheduling notification: \(error)")
              } else {
                  print("Daily motivation notification scheduled successfully")
              }
          }
      }
}
