import SwiftUI

struct AIAdviceMessageView: View {
    let message: String
    var isFromAI: Bool = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if isFromAI {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if isFromAI {
                    Text("AI Assistant")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(message)
                    .padding(12)
                    .background(isFromAI ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .foregroundColor(isFromAI ? .primary : .primary)
                    .cornerRadius(16)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct AdviceView: View {
    @State private var userQuestion: String = ""
    @State private var messages: [AdviceMessage] = [
        AdviceMessage(content: "Welcome! I can provide tips for digital wellbeing. How can I help you today?", isFromAI: true)
    ]
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Text("AI Advice")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        AIAdviceMessageView(
                            message: message.content,
                            isFromAI: message.isFromAI
                        )
                    }
                }
                .padding(.top)
            }
            
            HStack {
                TextField("Ask for advice...", text: $userQuestion)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                }
                .disabled(isLoading || userQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
    }
    
    func sendMessage() {
        guard !userQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = AdviceMessage(content: userQuestion, isFromAI: false)
        messages.append(userMessage)
        
        let question = userQuestion
        userQuestion = ""
        
        isLoading = true
        
        Task {
            let aiResponse = await generateAIResponse(for: question)
            
            await MainActor.run {
                let aiMessage = AdviceMessage(content: aiResponse, isFromAI: true)
                messages.append(aiMessage)
                isLoading = false
            }
        }
    }
    
    func generateAIResponse(for question: String) async -> String {
        let apiKey = "AIzaSyCQry4YMN4sIONcklSyHqGSKZBU_HCnl3s"
        let ai = GoogleGenAI(apiKey: apiKey)
        return await ai.generateContent(prompt: question)
    }
}

// Models
struct AdviceMessage: Identifiable {
    var id = UUID()
    var content: String
    var isFromAI: Bool
    var timestamp = Date()
}

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
