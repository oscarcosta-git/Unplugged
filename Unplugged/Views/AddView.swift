//
//  AddView.swift
//  Unplugged
//
//  Created by Slim Torbey on 3/5/2025.
//

import SwiftUI
import SwiftData

struct AddView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedApp.name) private var trackedApps: [TrackedApp]
    @AppStorage("userPoints") private var points: Int = 250
    
    @State private var showAddSheet = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 8) {
                    Text("Tracked Apps")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)
                    
                    HStack {
                        Spacer()
                        Button(action: { showAddSheet = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                        .padding(.trailing)
                    }
                }
                .padding(.bottom, 10)
                .background(Color(.systemBackground))
                
                // List Section
                List {
                    ForEach(trackedApps) { app in
                        TrackedAppRow(app: app, points: $points)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .sheet(isPresented: $showAddSheet) {
                AddAppSheet(isPresented: $showAddSheet)
            }
            .onAppear {
                // Pre-populate if empty
                if trackedApps.isEmpty {
                    let instagram = TrackedApp(name: "Instagram", icon: "camera", timeUsed: 30, timeLimit: 50, isLocked: false)
                    let facebook = TrackedApp(name: "Facebook", icon: "f.square", timeUsed: 60, timeLimit: 60, isLocked: true)
                    modelContext.insert(instagram)
                    modelContext.insert(facebook)
                }
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    // Simulate real-time tracking (every 5 seconds for demo)
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            for app in trackedApps where !app.isLocked && app.timeUsed < app.timeLimit {
                app.timeUsed += 1
                if app.timeUsed >= app.timeLimit {
                    app.isLocked = true
                }
            }
        }
    }
}

struct TrackedAppRow: View {
    @Environment(\.modelContext) private var modelContext
    var app: TrackedApp
    @Binding var points: Int
    @State private var showUnlockSheet = false
    
    var progress: Double {
        min(Double(app.timeUsed) / Double(app.timeLimit), 1.0)
    }
    
    var body: some View {
        HStack {
            Image(systemName: app.icon)
                .font(.largeTitle)
                .frame(width: 40)
            VStack(alignment: .leading) {
                Text(app.name)
                    .font(.headline)
                Text("\(app.timeUsed)/\(app.timeLimit) min used")
                    .font(.subheadline)
                ProgressView(value: progress)
                    .frame(width: 120)
            }
            Spacer()
            
            // Lock/Unlock Button
            if app.isLocked {
                Button(action: {
                    showUnlockSheet = true
                }) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .sheet(isPresented: $showUnlockSheet) {
                    UnlockAppSheet(app: app, points: $points, isPresented: $showUnlockSheet)
                }
            } else {
                Image(systemName: "lock.open.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddAppSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var selectedApp = "Twitter"
    @State private var timeLimit = ""
    let availableApps = [
        ("Instagram", "camera"),
        ("Facebook", "f.square"),
        ("Twitter", "bird"),
        ("Snapchat", "bolt"),
        ("TikTok", "music.note")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Picker("App", selection: $selectedApp) {
                    ForEach(availableApps, id: \.0) { app in
                        Text(app.0).tag(app.0)
                    }
                }
                TextField("Time Limit (minutes)", text: $timeLimit)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add App")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let limit = Int(timeLimit),
                           let icon = availableApps.first(where: { $0.0 == selectedApp })?.1 {
                            let newApp = TrackedApp(name: selectedApp, icon: icon, timeUsed: 0, timeLimit: limit, isLocked: false)
                            modelContext.insert(newApp)
                            try? modelContext.save()
                            isPresented = false
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

struct UnlockAppSheet: View {
    @Environment(\.modelContext) private var modelContext
    var app: TrackedApp
    @Binding var points: Int
    @Binding var isPresented: Bool
    
    @State private var unlockTime = ""
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Spend 50 points to unlock. How long do you want to unlock it for?")
                    .padding(.top)
                TextField("Minutes", text: $unlockTime)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if showConfirmation {
                    VStack(spacing: 10) {
                        Text("App unlocked!")
                            .foregroundColor(.green)
                            .font(.headline)
                        Text("\(app.name) has been unlocked for \(unlockTime) minutes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .navigationTitle("Unlock \(app.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Unlock") {
                        if let minutes = Int(unlockTime), points >= 50 {
                            // Update the app's properties
                            app.isLocked = false
                            app.timeUsed = max(0, app.timeUsed - minutes)
                            
                            // Update points
                            points -= 50
                            
                            // Show confirmation
                            showConfirmation = true
                            
                            // Save changes
                            try? modelContext.save()
                            
                            // Close the sheet after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isPresented = false
                            }
                        }
                    }
                    .disabled(points < 50 || unlockTime.isEmpty)
                }
            }
        }
    }
}
