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
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showAddSheet = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Header
                VStack(spacing: 12) {
                    HStack {
                        Text("Tracked Apps")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        
                        Spacer()
                        
                        Text("\(points) points")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.orange.opacity(0.15)))
                    }
                    
                    HStack {
                        Text("\(trackedApps.count) apps tracked")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: { showAddSheet = true }) {
                            Label("Add App", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Improved List Section
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(trackedApps) { app in
                            ImprovedTrackedAppRow(app: app, points: $points)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6).opacity(0.5))
            }
            .sheet(isPresented: $showAddSheet) {
                ImprovedAddAppSheet(isPresented: $showAddSheet)
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

struct ImprovedTrackedAppRow: View {
    @Environment(\.modelContext) private var modelContext
    var app: TrackedApp
    @Binding var points: Int
    @State private var showUnlockSheet = false
    
    var progress: Double {
        min(Double(app.timeUsed) / Double(app.timeLimit), 1.0)
    }
    
    var progressColor: Color {
        if progress < 0.5 { return .green }
        else if progress < 0.8 { return .orange }
        else { return .red }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // App icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: app.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                
                // App details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(app.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        // Lock/Unlock Button
                        Button(action: {
                            if app.isLocked {
                                showUnlockSheet = true
                            }
                        }) {
                            Image(systemName: app.isLocked ? "lock.fill" : "lock.open.fill")
                                .foregroundColor(app.isLocked ? .red : .green)
                                .font(.headline)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(app.isLocked ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                                )
                        }
                        .sheet(isPresented: $showUnlockSheet) {
                            ImprovedUnlockAppSheet(app: app, points: $points, isPresented: $showUnlockSheet)
                        }
                    }
                    
                    // Usage stats and progress
                    HStack(alignment: .center) {
                        Text("\(app.timeUsed) min used")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("/")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(app.timeLimit) min limit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Percentage
                        Text("\(Int(progress * 100))%")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(progressColor)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                                .frame(height: 8)
                            
                            // Progress fill
                            Rectangle()
                                .fill(progressColor)
                                .cornerRadius(4)
                                .frame(width: geometry.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

struct ImprovedAddAppSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var selectedApp = "Twitter"
    @State private var timeLimit = ""
    let availableApps = [
        ("Instagram", "camera"),
        ("Facebook", "f.square"),
        ("Twitter", "bird"),
        ("Snapchat", "bolt"),
        ("TikTok", "music.note"),
        ("YouTube", "play.rectangle"),
        ("Reddit", "mail")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // App selection section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Select an app to track")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(availableApps, id: \.0) { app in
                                AppSelectionItem(
                                    name: app.0,
                                    icon: app.1,
                                    isSelected: selectedApp == app.0
                                )
                                .onTapGesture {
                                    selectedApp = app.0
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                // Time limit section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Set daily time limit")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    HStack {
                        TextField("Minutes", text: $timeLimit)
                            .keyboardType(.numberPad)
                            .font(.system(.title2, design: .rounded))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        Text("minutes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Preset buttons
                    HStack(spacing: 10) {
                        ForEach([15, 30, 45, 60], id: \.self) { mins in
                            Button(action: {
                                timeLimit = "\(mins)"
                            }) {
                                Text("\(mins)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(timeLimit == "\(mins)" ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(timeLimit == "\(mins)" ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                Spacer()
            }
            .navigationTitle("Add New App")
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
                    .disabled(timeLimit.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

struct AppSelectionItem: View {
    let name: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : .blue)
            }
            
            Text(name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
        }
    }
}

struct ImprovedUnlockAppSheet: View {
    @Environment(\.modelContext) private var modelContext
    var app: TrackedApp
    @Binding var points: Int
    @Binding var isPresented: Bool
    
    @State private var unlockTime = ""
    @State private var showConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // App Info Header
                VStack(spacing: 12) {
                    Image(systemName: app.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .frame(width: 80, height: 80)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text(app.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "hourglass")
                            .foregroundColor(.orange)
                        
                        Text("\(app.timeUsed) of \(app.timeLimit) minutes used")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                Divider()
                
                // Cost info
                HStack {
                    VStack(alignment: .leading) {
                        Text("Cost to unlock")
                            .font(.headline)
                        Text("50 points")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(points) points available")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.orange.opacity(0.15)))
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                
                // Time input
                VStack(alignment: .leading, spacing: 12) {
                    Text("How long to unlock?")
                        .font(.headline)
                    
                    TextField("Minutes", text: $unlockTime)
                        .keyboardType(.numberPad)
                        .font(.system(.title, design: .rounded))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    // Quick time selections
                    HStack(spacing: 10) {
                        ForEach([15, 30, 60, 120], id: \.self) { mins in
                            Button(action: {
                                unlockTime = "\(mins)"
                            }) {
                                Text("\(mins)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(unlockTime == "\(mins)" ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(unlockTime == "\(mins)" ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Confirmation message
                if showConfirmation {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        
                        Text("App unlocked!")
                            .foregroundColor(.green)
                            .font(.headline)
                        
                        Text("\(app.name) unlocked for \(unlockTime) minutes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
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
