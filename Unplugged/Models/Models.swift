import Foundation
import SwiftData

// Chat models
struct AdviceMessage: Identifiable {
    var id = UUID()
    var content: String
    var isFromAI: Bool
    var timestamp = Date()
}

// Gemini API models
struct GeminiRequest: Codable {
    let contents: [Content]
}

struct Content: Codable {
    let role: String
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}

struct GeminiResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
}
