import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
            
            AddView()
                .tabItem {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Apps")
                    }
                }
            
            ProgressView()
                .tabItem {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                        Text("Progress")
                    }
                }
            
            AdviceView()
                .tabItem {
                    VStack {
                        Image(systemName: "lightbulb.fill")
                        Text("Advice")
                    }
                }
            
            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
        }
        .accentColor(.blue)
    }
}

/*#Preview {
    ContentView()
}*/
