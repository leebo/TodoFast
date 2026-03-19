import SwiftUI
import UserNotifications

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    
    private override init() {
        super.init()
        checkAuthorization()
    }
    
    // MARK: - Authorization
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        
        await MainActor.run {
            isAuthorized = granted
        }
        
        return granted
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleTaskReminder(title: String, taskId: String, at date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = "任务提醒"
        content.body = title
        content.sound = .default
        content.badge = 1
        content.userInfo = ["taskId": taskId]
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
    
    func cancelTaskReminder(taskId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Badge
    
    func updateBadge(count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
            if let error = error {
                print("Failed to update badge: \(error)")
            }
        }
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - AppDelegate Setup

extension NotificationService {
    func configureAppDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let taskId = userInfo["taskId"] as? String {
            // Navigate to task
            NotificationCenter.default.post(
                name: .openTask,
                object: nil,
                userInfo: ["taskId": taskId]
            )
        }
        
        completionHandler()
    }
}

extension Notification.Name {
    static let openTask = Notification.Name("openTask")
}
