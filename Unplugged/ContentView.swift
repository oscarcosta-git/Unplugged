import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
            AddView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
            
            LeaderboardView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                }
        }
        .accentColor(.blue)
    }
}

struct AddView: View {
    var body: some View {
        Text("Add View")
            .font(.largeTitle)
    }
}

struct LeaderboardView: View {
    var body: some View {
        Text("Leaderboard View")
            .font(.largeTitle)
    }
}

#Preview {
    ContentView()
}
