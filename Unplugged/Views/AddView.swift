//
//  AddView.swift
//  Unplugged
//
//  Created by Slim Torbey on 3/5/2025.
//

import SwiftUI
import SwiftData

struct AddView: View {
    @StateObject private var dummyData = DummyDataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedApp.name) private var trackedApps: [TrackedApp]
    @AppStorage("userPoints") private var points: Int = 250
    @AppStorage("reminderType") private var reminderType = "All"
    @AppStorage("appTrackingEnabled") private var appTrackingEnabled = true
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
                // Pre-populate if empty using centralized data
                if trackedApps.isEmpty {
                    let defaultApps = DummyDataManager.createDefaultApps()
                    for app in defaultApps {
                        modelContext.insert(app)
                    }
                }
                startTimer()
                notificationManager.checkPermission()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    // Simulate real-time tracking with immediate notifications
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            guard appTrackingEnabled else { return }
            
            for app in trackedApps where !app.isLocked {
                // Increase time usage
                if app.timeUsed < app.timeLimit {
                    app.timeUsed += 1
                    
                    // Check for warning notification (80% of limit)
                    if dummyData.shouldSendWarningNotification(for: app) {
                        notificationManager.scheduleAppWarningNotification(for: app, reminderType: reminderType)
                        dummyData.markWarningNotificationSent(for: app.id)
                    }
                    
                    // Check if limit is reached
                    if app.timeUsed >= app.timeLimit {
                        app.isLocked = true
                        
                        if dummyData.shouldSendLimitNotification(for: app) {
                            notificationManager.scheduleAppLimitReachedNotification(for: app, reminderType: reminderType)
                            dummyData.markLimitNotificationSent(for: app.id)
                        }
                    }
                }
            }
            
            // Save changes
            try? modelContext.save()
        }
    }
}

struct ImprovedTrackedAppRow: View {
    @Environment(\.modelContext) private var modelContext
    var app: TrackedApp
    @Binding var points: Int
    @State private var showUnlockSheet = false
    @State private var showDeleteAlert = false
    @State private var showOptionsSheet = false
    
    var progress: Double {
        min(Double(app.timeUsed) / Double(app.timeLimit), 1.0)
    }
    
    var progressColor: Color {
        if progress < 0.5 { return .green }
        else if progress < 0.8 { return .orange }
        else { return .red }
    }
    
    var isNearLimit: Bool {
        progress >= 0.8
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // App icon with warning indicator
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: app.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    // Warning indicator for apps near limit
                    if isNearLimit && !app.isLocked {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Image(systemName: "exclamationmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 18, y: -18)
                    }
                }
                
                // App details
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(app.name)
                            .font(.headline)
                        
                        // Warning text for apps near limit
                        if isNearLimit && !app.isLocked {
                            Text("Near Limit")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        // Options Button (three dots)
                        Button(action: {
                            showOptionsSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                                .font(.headline)
                                .padding(8)
                                .background(Circle().fill(Color.gray.opacity(0.1)))
                        }
                        
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
        .overlay(
            // Border for apps near limit
            RoundedRectangle(cornerRadius: 16)
                .stroke(isNearLimit && !app.isLocked ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .sheet(isPresented: $showUnlockSheet) {
            ImprovedUnlockAppSheet(app: app, points: $points, isPresented: $showUnlockSheet)
        }
        .confirmationDialog("App Options", isPresented: $showOptionsSheet, titleVisibility: .visible) {
            Button("Remove App", role: .destructive) {
                showDeleteAlert = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose an option for \(app.name)")
        }
        .alert("Remove App", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                deleteApp()
            }
        } message: {
            Text("Are you sure you want to remove \(app.name) from tracking? This action cannot be undone.")
        }
    }
    
    private func deleteApp() {
        modelContext.delete(app)
        try? modelContext.save()
    }
}

struct ImprovedAddAppSheet: View {
    @StateObject private var dummyData = DummyDataManager.shared
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedApp.name) private var trackedApps: [TrackedApp]
    @Binding var isPresented: Bool
    
    @State private var selectedApp = "Twitter"
    @State private var timeLimit = ""
    
    // Filter out already tracked apps
    private var availableApps: [(String, String)] {
        let trackedAppNames = Set(trackedApps.map { $0.name })
        return dummyData.availableApps.filter { !trackedAppNames.contains($0.0) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // App selection section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Select an app to track")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    if availableApps.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("All available apps are being tracked!")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text("Remove an app from tracking to add a new one.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
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
                        .onAppear {
                            if !availableApps.isEmpty && !availableApps.contains(where: { $0.0 == selectedApp }) {
                                selectedApp = availableApps.first?.0 ?? ""
                            }
                        }
                    }
                }
                .padding(.vertical)
                
                if !availableApps.isEmpty {
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
                }
                
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
                    .disabled(timeLimit.isEmpty || availableApps.isEmpty)
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
    @State private var limitChanged = false
    @State private var newLimit = 0
    @State private var unlockAction = ""
    
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
                    
                    // Show remaining time
                    let remainingTime = app.timeLimit - app.timeUsed
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.green)
                        
                        Text("\(remainingTime) minutes remaining")
                            .font(.caption)
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
                    Text("How much time to unlock?")
                        .font(.headline)
                    
                    TextField("Minutes", text: $unlockTime)
                        .keyboardType(.numberPad)
                        .font(.system(.title, design: .rounded))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onChange(of: unlockTime) { _, newValue in
                            checkUnlockAction()
                        }
                    
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
                    
                    // Action explanation
                    if !unlockTime.isEmpty, let minutes = Int(unlockTime) {
                        let remainingTime = app.timeLimit - app.timeUsed
                        
                        HStack {
                            Image(systemName: minutes > remainingTime ? "arrow.up.circle.fill" : "minus.circle.fill")
                                .foregroundColor(minutes > remainingTime ? .blue : .green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                if minutes > remainingTime {
                                    Text("New limit will be set")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Daily limit will become \(minutes) minutes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Time will be subtracted")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Usage will decrease by \(minutes) minutes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .background((minutes > remainingTime ? Color.blue : Color.green).opacity(0.1))
                        .cornerRadius(8)
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
                        
                        VStack(spacing: 4) {
                            Text(unlockAction)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
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
                            let remainingTime = app.timeLimit - app.timeUsed
                            
                            if minutes > remainingTime {
                                // Set new limit to unlock time amount
                                app.timeLimit = minutes
                                app.timeUsed = 0
                                limitChanged = true
                                newLimit = minutes
                                unlockAction = "\(app.name) limit set to \(minutes) minutes"
                            } else {
                                // Subtract unlock time from current usage
                                app.timeUsed = max(0, app.timeUsed - minutes)
                                unlockAction = "\(app.name) usage reduced by \(minutes) minutes"
                            }
                            
                            // Unlock the app and update points
                            app.isLocked = false
                            points -= 50
                            
                            // Show confirmation
                            showConfirmation = true
                            
                            // Save changes
                            try? modelContext.save()
                            
                            // Close the sheet after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isPresented = false
                            }
                        }
                    }
                    .disabled(points < 50 || unlockTime.isEmpty)
                }
            }
        }
    }
    
    private func checkUnlockAction() {
        if let minutes = Int(unlockTime) {
            let remainingTime = app.timeLimit - app.timeUsed
            limitChanged = minutes > remainingTime
            if limitChanged {
                newLimit = minutes
            }
        } else {
            limitChanged = false
        }
    }
}
