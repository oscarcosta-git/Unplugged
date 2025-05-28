import Foundation
import SwiftData

class DummyDataManager: ObservableObject {
    static let shared = DummyDataManager()
    
    // MARK: - Screen Time Data
    @Published var totalScreenTimeToday: Int = 135 // minutes (2h 15m)
    @Published var remainingTimeToday: Int = 45 // minutes
    @Published var dailyGoalsAchieved: Int = 3
    @Published var weeklyReduction: Int = 15 // percentage
    @Published var dailyAverageTime: Int = 126 // minutes
    @Published var successScore: Double = 0.68 // 68%
    @Published var todayProgress: Double = 0.4 // 40% of daily limit used
    @Published var countdownProgress: Double = 0.75 // 75% through remaining time
    
    // MARK: - Device Insights
    let unlocksPerDay: Int = 47
    let longestSession: Int = 84 // minutes (1h 24m)
    let shortestSession: Int = 3 // minutes
    let activeScreenTimePercentage: Int = 65
    let idleScreenTimePercentage: Int = 35
    
    // MARK: - Notification Tracking
    @Published var warningNotificationsSent: Set<UUID> = []
    @Published var limitNotificationsSent: Set<UUID> = []
    
    // MARK: - Chat Tips
    let digitalWellnessTips = [
        "Try setting specific screen time goals for different apps rather than a general limit for all screen time.",
        "Use the 20-20-20 rule: Every 20 minutes, look at something 20 feet away for 20 seconds.",
        "Keep your phone in another room while sleeping to improve sleep quality.",
        "Set up phone-free zones in your home, like the dining room or bedroom.",
        "Use grayscale mode to make your phone less visually appealing.",
        "Schedule specific times for checking social media instead of constant scrolling.",
        "Enable app time limits and stick to them - consistency builds healthy habits.",
        "Replace mindless scrolling with intentional activities like reading or exercise."
    ]
    
    // MARK: - Chart Data
    let dailyScreenTimeData = [
        (label: "Mon", value: 120),
        (label: "Tue", value: 85),
        (label: "Wed", value: 150),
        (label: "Thu", value: 95),
        (label: "Fri", value: 110),
        (label: "Sat", value: 180),
        (label: "Sun", value: 145)
    ]
    
    let weeklyScreenTimeData = [
        (label: "W1", value: 840),
        (label: "W2", value: 720),
        (label: "W3", value: 680),
        (label: "W4", value: 590)
    ]
    
    let monthlyScreenTimeData = [
        (label: "Jan", value: 3600),
        (label: "Feb", value: 3200),
        (label: "Mar", value: 3000),
        (label: "Apr", value: 2800),
        (label: "May", value: 2400)
    ]
    
    // MARK: - Calendar Goal Achievement Data
    let achievedGoalDays: Set<String> = [
        "2025-05-17", "2025-05-18", "2025-05-19", "2025-05-21", "2025-05-22"
    ]
    
    // MARK: - Available Apps for Tracking
    let availableApps = [
        ("Instagram", "camera"),
        ("Facebook", "f.square"),
        ("Twitter", "bird"),
        ("Snapchat", "bolt"),
        ("TikTok", "music.note"),
        ("YouTube", "play.rectangle"),
        ("Reddit", "mail"),
        ("WhatsApp", "message"),
        ("Discord", "message.badge"),
        ("Netflix", "tv")
    ]
    
    // MARK: - Default Tracked Apps
    static func createDefaultApps() -> [TrackedApp] {
        return [
            TrackedApp(name: "Instagram", icon: "camera", timeUsed: 50, timeLimit: 60, isLocked: false),
            TrackedApp(name: "TikTok", icon: "music.note", timeUsed: 5, timeLimit: 45, isLocked: false),
        ]
    }
    
    // MARK: - Dynamic Insights Based on Tracked Apps
    func getInsights(from trackedApps: [TrackedApp]) -> [(title: String, value: String, detail: String, icon: String, color: String)] {
        if trackedApps.isEmpty {
            return [
                (title: "No Apps Tracked", value: "Start Tracking", detail: "Add apps to see insights", icon: "plus.circle", color: "blue"),
                (title: "Most Productive Day", value: "Tuesday", detail: "62% below average screen time", icon: "calendar", color: "green"),
                (title: "Peak Usage Time", value: "9-11 PM", detail: "Consider setting a digital curfew", icon: "moon.stars", color: "blue")
            ]
        }
        
        // Find most used app
        let mostUsedApp = trackedApps.max { $0.timeUsed < $1.timeUsed }
        let mostUsedAppName = mostUsedApp?.name ?? "Instagram"
        let mostUsedAppTime = mostUsedApp?.timeUsed ?? 45
        
        // Find most productive day based on overall usage
        let totalTimeUsed = trackedApps.reduce(0) { $0 + $1.timeUsed }
        let productiveDay = totalTimeUsed < 120 ? "Today" : "Tuesday"
        
        return [
            (title: "Most Used App", value: mostUsedAppName, detail: "\(mostUsedAppTime) min daily average", icon: "camera", color: "purple"),
            (title: "Most Productive Day", value: productiveDay, detail: "62% below average screen time", icon: "calendar", color: "green"),
            (title: "Peak Usage Time", value: "9-11 PM", detail: "Consider setting a digital curfew", icon: "moon.stars", color: "blue")
        ]
    }
    
    // MARK: - Notification Helpers
    func shouldSendWarningNotification(for app: TrackedApp) -> Bool {
        let progress = Double(app.timeUsed) / Double(app.timeLimit)
        return progress >= 0.8 && !warningNotificationsSent.contains(app.id)
    }
    
    func shouldSendLimitNotification(for app: TrackedApp) -> Bool {
        return app.timeUsed >= app.timeLimit && !limitNotificationsSent.contains(app.id)
    }
    
    func markWarningNotificationSent(for appId: UUID) {
        warningNotificationsSent.insert(appId)
    }
    
    func markLimitNotificationSent(for appId: UUID) {
        limitNotificationsSent.insert(appId)
    }
    
    func resetNotificationFlags() {
        warningNotificationsSent.removeAll()
        limitNotificationsSent.removeAll()
    }
    
    func resetNotificationFlags(for appId: UUID) {
        warningNotificationsSent.remove(appId)
        limitNotificationsSent.remove(appId)
    }
    
    // MARK: - Helper Methods
    func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    func getRandomTip() -> String {
        return digitalWellnessTips.randomElement() ?? digitalWellnessTips[0]
    }
    
    func getChartData(for timeFrame: String) -> [(label: String, value: Int)] {
        switch timeFrame.lowercased() {
        case "day":
            return dailyScreenTimeData
        case "week":
            return weeklyScreenTimeData
        case "month":
            return monthlyScreenTimeData
        default:
            return dailyScreenTimeData
        }
    }
    
    // MARK: - Simulation Methods
    func updateScreenTime() {
        // Simulate real-time updates
        if totalScreenTimeToday < 180 { // Don't exceed 3 hours
            totalScreenTimeToday += Int.random(in: 1...3)
            todayProgress = min(Double(totalScreenTimeToday) / 180.0, 1.0)
            
            if remainingTimeToday > 0 {
                remainingTimeToday = max(0, remainingTimeToday - Int.random(in: 0...2))
                countdownProgress = 1.0 - (Double(remainingTimeToday) / 45.0)
            }
        }
    }
    
    private init() {}
}