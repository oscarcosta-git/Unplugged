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
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
        }
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
