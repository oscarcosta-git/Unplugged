//
//  UnpluggedApp.swift
//  Unplugged
//
//  Created by Oscar Costa on 2/5/2025.
//

import SwiftUI
import SwiftData

@main
struct UnpluggedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: TrackedApp.self)
        }
    }
}
