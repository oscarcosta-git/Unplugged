import Foundation
import SwiftData

@Model
final class TrackedApp {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var timeUsed: Int // in minutes
    var timeLimit: Int // in minutes
    var isLocked: Bool

    init(id: UUID = UUID(), name: String, icon: String, timeUsed: Int, timeLimit: Int, isLocked: Bool) {
        self.id = id
        self.name = name
        self.icon = icon
        self.timeUsed = timeUsed
        self.timeLimit = timeLimit
        self.isLocked = isLocked
    }
} 
