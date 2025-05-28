import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var permissionGranted = false
    
    private init() {
        checkPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.permissionGranted = granted
            }
        }
    }
    
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleAppWarningNotification(for app: TrackedApp, reminderType: String) {
        guard permissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Screen Time Warning ⚠️"
        content.body = "\(app.name) is at 80% of your daily limit. Consider taking a break!"
        content.sound = reminderType.contains("Sound") || reminderType == "All" ? .default : nil
        content.badge = reminderType.contains("Badge") || reminderType == "All" ? 1 : nil
        content.categoryIdentifier = "APP_WARNING"
        
        let request = UNNotificationRequest(
            identifier: "warning_\(app.id.uuidString)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { _ in }
    }
    
    func scheduleAppLimitReachedNotification(for app: TrackedApp, reminderType: String) {
        guard permissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time Limit Reached 🔒"
        content.body = "\(app.name) has reached its daily limit and is now locked. Take a well-deserved break!"
        content.sound = reminderType.contains("Sound") || reminderType == "All" ? .default : nil
        content.badge = reminderType.contains("Badge") || reminderType == "All" ? 1 : nil
        content.categoryIdentifier = "APP_LIMIT"
        
        let request = UNNotificationRequest(
            identifier: "limit_\(app.id.uuidString)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { _ in }
    }
    
    func scheduleGeneralReminder(frequency: String, reminderType: String) {
        guard permissionGranted else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Digital Wellbeing Reminder 🧘"
        content.body = "Time to check your screen time progress and take a mindful break!"
        content.sound = reminderType.contains("Sound") || reminderType == "All" ? .default : nil
        content.badge = reminderType.contains("Badge") || reminderType == "All" ? 1 : nil
        
        var timeInterval: TimeInterval
        var identifier: String
        
        switch frequency {
        case "Hourly":
            timeInterval = 3600
            identifier = "hourly_reminder"
        case "Daily":
            timeInterval = 86400
            identifier = "daily_reminder"
        case "Weekly":
            timeInterval = 604800
            identifier = "weekly_reminder"
        default:
            return
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { _ in }
    }
    
    func scheduleReminder(frequency: String, reminderType: String) {
        scheduleGeneralReminder(frequency: frequency, reminderType: reminderType)
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelAllAppNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let appNotificationIds = requests.compactMap { request in
                request.identifier.hasPrefix("warning_") || request.identifier.hasPrefix("limit_") ? request.identifier : nil
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: appNotificationIds)
        }
    }
}