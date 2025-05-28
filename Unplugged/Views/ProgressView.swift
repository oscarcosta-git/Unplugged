import SwiftUI
import SwiftData

struct ProgressView: View {
    @StateObject private var dummyData = DummyDataManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \TrackedApp.name) private var trackedApps: [TrackedApp]
    @State private var selectedTimeFrame: TimeFrame = .week
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    
    enum TimeFrame: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        var id: Self { self }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly summary card
                    WeeklySummaryCard(
                        weeklyReduction: dummyData.weeklyReduction,
                        dailyAverageTime: dummyData.dailyAverageTime
                    )
                    
                    // Calendar tracker
                    VStack(alignment: .leading) {
                        Text("Goal Achievement Calendar")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        CalendarGoalTrackerView(
                            currentDate: $currentDate,
                            selectedDate: $selectedDate
                        )
                    }
                    .padding(.vertical)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                    .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Progress charts
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Screen Time Trends")
                                .font(.headline)
                            
                            Spacer()
                            
                            Picker("Time Frame", selection: $selectedTimeFrame) {
                                ForEach(TimeFrame.allCases) { timeFrame in
                                    Text(timeFrame.rawValue).tag(timeFrame)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 180)
                        }
                        .padding(.horizontal)
                        
                        ScreenTimeChartView(timeFrame: selectedTimeFrame)
                            .frame(height: 220)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                    .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Insights section with real app data
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Screen Time Insights")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(dummyData.getInsights(from: trackedApps).indices, id: \.self) { index in
                            let insight = dummyData.getInsights(from: trackedApps)[index]
                            InsightCard(
                                title: insight.title,
                                value: insight.value,
                                detail: insight.detail,
                                icon: insight.icon,
                                color: colorForInsight(insight.color)
                            )
                        }
                    }
                    .padding(.vertical)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                    .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
                .padding()
            }
            .background(Color(.systemGray6).opacity(0.5).edgesIgnoringSafeArea(.all))
            .navigationTitle("Progress & Insights")
        }
    }
    
    private func colorForInsight(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "purple": return .purple
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "red": return .red
        default: return .blue
        }
    }
}

struct WeeklySummaryCard: View {
    @StateObject private var dummyData = DummyDataManager.shared
    let weeklyReduction: Int
    let dailyAverageTime: Int
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Summary")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("May 17 - May 23")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chart.line.downtrend.xyaxis")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                    .padding(12)
                    .background(Circle().fill(Color.green.opacity(0.1)))
            }
            
            Divider()
            
            HStack(alignment: .top, spacing: 30) {
                // Reduction stat
                VStack(alignment: .center, spacing: 8) {
                    Text("\(weeklyReduction)%")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Reduction")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                // Daily average
                VStack(alignment: .center, spacing: 8) {
                    Text(dummyData.formatMinutes(dailyAverageTime))
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("Daily Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                // Goal status
                VStack(alignment: .center, spacing: 8) {
                    Text("5/7")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Goals Met")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct CalendarGoalTrackerView: View {
    @StateObject private var dummyData = DummyDataManager.shared
    @Binding var currentDate: Date
    @Binding var selectedDate: Date?
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    private let calendar = Calendar.current
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentDate),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return []
        }
        
        return range.map { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
        }
    }
    
    private var firstWeekdayOfMonth: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(monthTitle)
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Day headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<firstWeekdayOfMonth, id: \.self) { _ in
                    Text("")
                }
                
                ForEach(daysInMonth, id: \.self) { date in
                    let dateString = formatDate(date)
                    let isToday = calendar.isDateInToday(date)
                    let isSelected = selectedDate == date
                    let achieved = dummyData.achievedGoalDays.contains(dateString)
                    let isFutureDate = date > Date()
                    
                    Button(action: { selectedDate = date }) {
                        Text("\(calendar.component(.day, from: date))")
                            .padding(8)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(backgroundColor(achieved: achieved, isToday: isToday, isSelected: isSelected, isFutureDate: isFutureDate))
                            )
                            .foregroundColor(foregroundColor(achieved: achieved, isToday: isToday, isSelected: isSelected, isFutureDate: isFutureDate))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1)
                            )
                    }
                    .disabled(isFutureDate)
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                legendItem(color: .green.opacity(0.2), label: "Goal Achieved")
                legendItem(color: .red.opacity(0.2), label: "Goal Missed")
                legendItem(color: Color(.systemGray5), label: "Future Date")
            }
            .padding(.top, 8)
        }
        .padding()
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func backgroundColor(achieved: Bool, isToday: Bool, isSelected: Bool, isFutureDate: Bool) -> Color {
        if isFutureDate {
            return Color(.systemGray5)
        } else if isSelected {
            return .blue.opacity(0.2)
        } else if achieved {
            return .green.opacity(0.2)
        } else {
            return .red.opacity(0.2)
        }
    }
    
    private func foregroundColor(achieved: Bool, isToday: Bool, isSelected: Bool, isFutureDate: Bool) -> Color {
        if isFutureDate {
            return .gray
        } else {
            return .primary
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ScreenTimeChartView: View {
    @StateObject private var dummyData = DummyDataManager.shared
    let timeFrame: ProgressView.TimeFrame
    
    private var data: [(label: String, value: Int)] {
        return dummyData.getChartData(for: timeFrame.rawValue)
    }
    
    private var maxValue: Int {
        data.map { $0.value }.max() ?? 100
    }
    
    private func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        return timeFrame == .day ? "\(minutes)m" : "\(hours)h"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Y-axis labels
            HStack(alignment: .top) {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach([1.0, 0.75, 0.5, 0.25, 0.0], id: \.self) { fraction in
                        Text(formatTime(Int(Double(maxValue) * fraction)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 40, alignment: .center)
                    }
                }
                .frame(width: 40)
                
                // Chart
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(data.indices, id: \.self) { index in
                        VStack(spacing: 4) {
                            // Bar with animated height
                            RoundedRectangle(cornerRadius: 4)
                                .fill(barColor(for: data[index].value))
                                .frame(height: barHeight(for: data[index].value))
                                .animation(.spring(), value: timeFrame)
                            
                            // X-axis label
                            Text(data[index].label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.leading, 4)
            }
            
            // Target line
            HStack {
                Text("Target")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(height: 1)
                    .padding(.vertical, 8)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
    }
    
    private func barHeight(for value: Int) -> CGFloat {
        let normalized = CGFloat(value) / CGFloat(maxValue)
        return normalized * 200
    }
    
    private func barColor(for value: Int) -> Color {
        // Color based on how far above/below target
        let target = maxValue / 2
        if value <= Int(Double(target) * 0.8) {
            return .green
        } else if value <= target {
            return .blue
        } else if value <= Int(Double(target) * 1.5) {
            return .orange
        } else {
            return .red
        }
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let detail: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Add this to ContentView.swift:
// In ContentView's TabView, replace LeaderboardView with ProgressView
// And update the ContentView.swift file to import the new view