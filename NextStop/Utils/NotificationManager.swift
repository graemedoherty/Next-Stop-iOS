import UserNotifications
import Foundation
import UIKit

class NotificationManager {
    
    static let alarmNotificationID = "com.nextstop.alarm"
    
    // MARK: - Request Permission
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission GRANTED")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("❌ Notification permission DENIED")
            }
        }
    }
    
    // MARK: - Send Initial Notification
    static func sendAlarmNotification(
        stationName: String,
        distanceMeters: Double
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm Active"
        content.body = "\(stationName) - \(String(format: "%.0f", distanceMeters))m away"
        content.badge = NSNumber(value: 1)
        content.sound = .default
        content.categoryIdentifier = "ALARM_ACTIONS"
        content.userInfo = [
            "stationName": stationName,
            "distance": distanceMeters
        ]
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: alarmNotificationID,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending notification: \(error.localizedDescription)")
            } else {
                print("✅ Alarm notification sent: \(stationName)")
            }
        }
    }
    
    // MARK: - Update Notification SILENTLY (no new alerts)
    static func updateAlarmNotificationSilently(
        stationName: String,
        distanceMeters: Double
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm Active"
        content.body = "\(stationName) - \(String(format: "%.0f", distanceMeters))m away"
        content.badge = NSNumber(value: 1)
        // ✅ NO SOUND - this keeps it silent
        content.categoryIdentifier = "ALARM_ACTIONS"
        content.userInfo = [
            "stationName": stationName,
            "distance": distanceMeters
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: alarmNotificationID,
            content: content,
            trigger: trigger
        )
        
        // Remove old notification first
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [alarmNotificationID]
        )
        
        // Add updated one
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error updating notification: \(error.localizedDescription)")
            }
            // Silent update - no print needed to avoid spam
        }
    }
    
    // MARK: - Remove Notification
    static func cancelAlarmNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [alarmNotificationID]
        )
        UNUserNotificationCenter.current().removeDeliveredNotifications(
            withIdentifiers: [alarmNotificationID]
        )
        print("🗑️ Alarm notification cancelled")
    }
    
    // MARK: - Setup Notification Actions
    static func setupNotificationActions() {
        let cancelAction = UNNotificationAction(
            identifier: "CANCEL_ALARM",
            title: "Cancel Alarm",
            options: .destructive
        )
        
        let alarmCategory = UNNotificationCategory(
            identifier: "ALARM_ACTIONS",
            actions: [cancelAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
        print("✅ Notification actions configured")
    }
}
