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
    
    var body: some View {
        NavigationView {
            List {
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

#Preview {
    SettingsView()
}
