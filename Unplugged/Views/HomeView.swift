//
//  HomeView.swift
//  Unplugged
//
//  Created by Oscar Costa on 2/5/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var dummyData = DummyDataManager.shared
    @State private var currentTip = "Welcome! Loading your personalized tip..."
    @State private var isLoadingTip = false
    @State private var hasLoadedInitialTip = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // App Header with profile pic
                HStack {
                    Spacer()
                    
                    Text("Unplugged")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    // Profile button
                    Button(action: {
                        // Profile action
                    }) {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            )
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                
                // AI Tip Box
                HStack(alignment: .top, spacing: 15) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .frame(width: 36, height: 36)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Helpful Tip")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(currentTip)
                            .font(.body)
                    }
                    
                    Spacer()
                    
                    Button(action: refreshTip) {
                        Image(systemName: isLoadingTip ? "clock" : "arrow.clockwise")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                    .disabled(isLoadingTip)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue.opacity(0.05)))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                )
                
                MetricBox(title: "Success Score", description: "Success Score is a dynamic tracking system that measures your progress, keeps you motivated, and helps you achieve your goals.") {
                    CircleProgressView(
                        progress: dummyData.successScore,
                        color: .blue,
                        label: "\(Int(dummyData.successScore * 100))%"
                    )
                }
                
                Text("Key Information")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Total Screen Time Today Box
                MetricBox(title: "Total Screen Time Today", description: "Tracks your daily device usage, helping you stay aware and manage your screen habits effectively.") {
                    VStack {
                        CircleProgressView(
                            progress: dummyData.todayProgress,
                            color: .green,
                            label: dummyData.formatMinutes(dummyData.totalScreenTimeToday)
                        )
                        Text("Healthy Range")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // Screen Time Countdown Box
                MetricBox(title: "Screen Time Countdown", description: "Tracks the remaining time before you hit your daily screen limit, helping you stay mindful and in control of your digital habits.") {
                    CircleProgressView(
                        progress: dummyData.countdownProgress,
                        color: .orange,
                        label: dummyData.formatMinutes(dummyData.remainingTimeToday)
                    )
                }
                
                // Device & Session Insights Box
                VStack(alignment: .leading, spacing: 15) {
                    Text("Device & Session Insights")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InsightRow(icon: "iphone", text: "Unlocks Per Day: \(dummyData.unlocksPerDay)")
                        InsightRow(icon: "clock", text: "Sessions: \(dummyData.formatMinutes(dummyData.longestSession)) longest, \(dummyData.shortestSession)m shortest")
                        InsightRow(icon: "heart.text.square", text: "Screen Time: \(dummyData.activeScreenTimePercentage)% active, \(dummyData.idleScreenTimePercentage)% idle")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
            .padding()
        }
        .background(Color(.systemGray6).opacity(0.5).edgesIgnoringSafeArea(.all))
        .onAppear {
            if !hasLoadedInitialTip {
                loadInitialTip()
                hasLoadedInitialTip = true
            }
        }
    }
    
    private func loadInitialTip() {
        currentTip = dummyData.getRandomTip()
    }
    
    private func refreshTip() {
        guard !isLoadingTip else { return }
        isLoadingTip = true
        
        // Simulate loading delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            currentTip = dummyData.getRandomTip()
            isLoadingTip = false
        }
    }
}

struct InsightRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct CircleProgressView: View {
    var progress: CGFloat  // from 0 to 1
    var color: Color
    var label: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            Text(label)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
        }
        .frame(width: 100, height: 100)
    }
}

struct MetricBox<Content: View>: View {
    var title: String
    var description: String
    var content: () -> Content
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                    if !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                content()
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
