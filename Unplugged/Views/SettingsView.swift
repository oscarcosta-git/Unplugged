//
//  SettingsView.swift
//  Unplugged
//
//  Created by Oscar Costa on 2/5/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("userPoints") private var points: Int = 250
    @State private var reminderFrequency = "Daily"
    @State private var reminderType = "Notification"
    @State private var appTrackingEnabled = true
    @State private var showResetAlert = false
    
    // Mock data - would be replaced with actual data in a real app
    private let totalScreenTime = "2h 15m"
    private let goalsAchieved = 3
    private let remainingTime = "45m"
    
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
                                value: totalScreenTime,
                                color: .blue
                            )
                            
                            // Goals Achieved
                            SummaryItem(
                                icon: "trophy.fill",
                                title: "Goals",
                                value: "\(goalsAchieved)",
                                color: .green
                            )
                            
                            // Remaining Time
                            SummaryItem(
                                icon: "clock.fill",
                                title: "Remaining",
                                value: remainingTime,
                                color: .orange
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section(header: Text("Notifications")) {
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
