//
//  SettingsView.swift
//  Unplugged
//
//  Created by Oscar Costa on 2/5/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var reminderFrequency = "Daily"
    @State private var reminderType = "Notification"
    @State private var appTrackingEnabled = true
    @State private var activitySuggestionsEnabled = false
    @State private var dataSyncingEnabled = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Personalise")) {
                    NavigationLink(destination: ReminderFrequencyView(selectedFrequency: $reminderFrequency)) {
                        HStack {
                            Text("Reminder Frequency")
                            Spacer()
                            Text(reminderFrequency)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: ReminderTypeView(selectedType: $reminderType)) {
                        HStack {
                            Text("Reminder Type")
                            Spacer()
                            Text(reminderType)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: AppTrackingView(appTrackingEnabled: $appTrackingEnabled)) {
                        HStack {
                            Text("App Tracking")
                            Spacer()
                            Text(appTrackingEnabled ? "On" : "Off")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Settings")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Activity Suggestions")
                            Text("Enable alternative activity suggestions when screen time is exceeded")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Toggle("", isOn: $activitySuggestionsEnabled)
                            .tint(.blue)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Data Syncing")
                            Text("Sync with iOS screen time and other health apps")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Toggle("", isOn: $dataSyncingEnabled)
                            .tint(.blue)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

// App tracking time limits view
struct AppTrackingView: View {
    @Binding var appTrackingEnabled: Bool
    @State private var apps = [
        AppTimeLimit(name: "Instagram", icon: "camera.fill", timeLimit: 60, enabled: true),
        AppTimeLimit(name: "Twitter", icon: "bubble.left.fill", timeLimit: 45, enabled: true),
        AppTimeLimit(name: "TikTok", icon: "video.fill", timeLimit: 30, enabled: true),
        AppTimeLimit(name: "YouTube", icon: "play.rectangle.fill", timeLimit: 90, enabled: true),
        AppTimeLimit(name: "Facebook", icon: "person.2.fill", timeLimit: 45, enabled: false)
    ]
    
    var body: some View {
        List {
            Section {
                Toggle("Enable App Tracking", isOn: $appTrackingEnabled)
                    .tint(.blue)
            }
            
            if appTrackingEnabled {
                Section(header: Text("Daily App Time Limits")) {
                    ForEach(0..<apps.count, id: \.self) { index in
                        NavigationLink(destination: AppTimeLimitDetailView(app: $apps[index])) {
                            HStack {
                                Image(systemName: apps[index].icon)
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                Text(apps[index].name)
                                
                                Spacer()
                                
                                if apps[index].enabled {
                                    Text("\(apps[index].timeLimit) min")
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Off")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("App Tracking")
    }
}

struct AppTimeLimitDetailView: View {
    @Binding var app: AppTimeLimit
    @State private var tempTimeLimit: Double
    
    init(app: Binding<AppTimeLimit>) {
        self._app = app
        self._tempTimeLimit = State(initialValue: Double(app.wrappedValue.timeLimit))
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Tracking", isOn: $app.enabled)
                    .tint(.blue)
            }
            
            if app.enabled {
                Section(header: Text("Daily Time Limit")) {
                    VStack {
                        Slider(value: $tempTimeLimit, in: 5...180, step: 5)
                            .onChange(of: tempTimeLimit) { oldValue, newValue in
                                app.timeLimit = Int(newValue)
                            }
                            .tint(.blue)
                        
                        HStack {
                            Text("5 min")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(app.timeLimit) min")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("3 hrs")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Options")) {
                    Toggle("Block after limit reached", isOn: .constant(true))
                    Toggle("Allow snooze", isOn: .constant(false))
                }
            }
        }
        .navigationTitle(app.name)
    }
}

// Data model for app time limits
struct AppTimeLimit {
    var name: String
    var icon: String
    var timeLimit: Int // in minutes
    var enabled: Bool
}

// Placeholder views for navigation destinations
struct ReminderFrequencyView: View {
    @Binding var selectedFrequency: String
    let frequencies = ["Hourly", "Daily", "Weekly"]
    
    var body: some View {
        List {
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
            }
        }
        .navigationTitle("Reminder Type")
    }
}
