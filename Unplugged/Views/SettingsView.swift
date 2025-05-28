//
//  SettingsView.swift
//  Unplugged
//
//  Created by Oscar Costa on 2/5/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @StateObject private var dummyData = DummyDataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.modelContext) private var modelContext
    @AppStorage("userPoints") private var points: Int = 250
    @AppStorage("reminderFrequency") private var reminderFrequency = "Daily"
    @AppStorage("reminderType") private var reminderType = "Notification"
    @AppStorage("appTrackingEnabled") private var appTrackingEnabled = true
    @State private var showResetAlert = false
    @State private var showNotificationAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Summary section at the top
                Section {
                    VStack(spacing: 16) {
                        HStack(spacing: 30) {
                            // Screen Time
                            SummaryItem(
                                icon: "iphone.circle.fill",
                                title: "Screen Time",
                                value: dummyData.formatMinutes(dummyData.totalScreenTimeToday),
                                color: .blue
                            )
                            
                            // Goals Achieved
                            SummaryItem(
                                icon: "trophy.fill",
                                title: "Goals",
                                value: "\(dummyData.dailyGoalsAchieved)",
                                color: .green
                            )
                            
                            // Remaining Time
                            SummaryItem(
                                icon: "clock.fill",
                                title: "Remaining",
                                value: dummyData.formatMinutes(dummyData.remainingTimeToday),
                                color: .orange
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section(header: Text("Notifications")) {
                    // Notification permission status
                    HStack {
                        Image(systemName: notificationManager.permissionGranted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(notificationManager.permissionGranted ? .green : .orange)
                        
                        VStack(alignment: .leading) {
                            Text("Notification Permission")
                                .font(.headline)
                            Text(notificationManager.permissionGranted ? "Enabled" : "Not Enabled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if !notificationManager.permissionGranted {
                            Button("Enable") {
                                notificationManager.requestPermission()
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    
                    // App limit notifications info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "app.badge")
                                .foregroundColor(.blue)
                            Text("App Limit Notifications")
                                .font(.headline)
                        }
                        Text("Warning at 80% usage and limit reached notifications are sent immediately")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    NavigationLink(destination: ReminderFrequencyView(selectedFrequency: $reminderFrequency)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("General Reminder Frequency")
                                Spacer()
                                Text(reminderFrequency)
                                    .foregroundColor(.gray)
                            }
                            Text("For general wellbeing reminders")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .disabled(!notificationManager.permissionGranted)
                    
                    NavigationLink(destination: ReminderTypeView(selectedType: $reminderType)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Notification Type")
                                Spacer()
                                Text(reminderType)
                                    .foregroundColor(.gray)
                            }
                            Text("Applies to all notifications")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .disabled(!notificationManager.permissionGranted)
                }
                
                Section(header: Text("Privacy")) {
                    Toggle("App Tracking", isOn: $appTrackingEnabled)
                        .tint(.blue)
                }
                
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset App")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
            .onAppear {
                notificationManager.checkPermission()
                // Schedule general reminders based on current settings
                if notificationManager.permissionGranted {
                    notificationManager.scheduleGeneralReminder(frequency: reminderFrequency, reminderType: reminderType)
                }
            }
            .onChange(of: reminderFrequency) { _, newValue in
                if notificationManager.permissionGranted {
                    notificationManager.scheduleGeneralReminder(frequency: newValue, reminderType: reminderType)
                }
            }
            .onChange(of: reminderType) { _, newValue in
                if notificationManager.permissionGranted {
                    notificationManager.scheduleGeneralReminder(frequency: reminderFrequency, reminderType: newValue)
                }
            }
            .alert("Reset App", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetApp()
                }
            } message: {
                Text("This will delete all tracked apps and reset your points. This action cannot be undone.")
            }
        }
    }
    
    private func resetApp() {
        // Delete all tracked apps
        do {
            try modelContext.delete(model: TrackedApp.self)
        } catch {
            print("Error resetting apps: \(error)")
        }
        
        // Reset points
        points = 250
        
        // Reset notification flags
        dummyData.resetNotificationFlags()
        
        // Cancel all notifications
        notificationManager.cancelAllNotifications()
    }
}

// Summary item component
struct SummaryItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Updated views for navigation destinations
struct ReminderFrequencyView: View {
    @Binding var selectedFrequency: String
    let frequencies = ["Hourly", "Daily", "Weekly"]
    
    var body: some View {
        List {
            Section(header: Text("General Reminder Frequency")) {
                Text("This setting only applies to general wellbeing reminders. App limit notifications are always sent immediately.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }
            
            Section {
                ForEach(frequencies, id: \.self) { frequency in
                    Button(action: {
                        selectedFrequency = frequency
                    }) {
                        HStack {
                            Text(frequency)
                            Spacer()
                            if selectedFrequency == frequency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Reminder Frequency")
    }
}

struct ReminderTypeView: View {
    @Binding var selectedType: String
    let types = ["Notification", "Badge", "Sound", "All"]
    
    var body: some View {
        List {
            Section(header: Text("Notification Type")) {
                Text("This setting applies to all notifications including app limit warnings and general reminders.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }
            
            Section {
                ForEach(types, id: \.self) { type in
                    Button(action: {
                        selectedType = type
                    }) {
                        HStack {
                            Text(type)
                            Spacer()
                            if selectedType == type {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Notification Type")
    }
}
