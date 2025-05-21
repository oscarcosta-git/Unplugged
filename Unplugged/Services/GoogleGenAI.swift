import Foundation

class GoogleGenAI {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // Updated model structures to match the API
    struct GenerationConfig: Codable {
        let temperature: Float
        let topP: Float
        let topK: Int
        let maxOutputTokens: Int
        let responseMimeType: String
    }
    
    struct SystemInstruction: Codable {
        let role: String
        let parts: [Part]
    }
    
    struct GenerationData: Codable {
        let generationConfig: GenerationConfig
        let contents: [Content]
        let systemInstruction: SystemInstruction
    }
    
    func generateContent(prompt: String) async -> String {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)") else { 
            print("Invalid URL")
            return "I'm sorry, I couldn't generate a response right now."
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = "You are a digital wellbeing assistant. Provide helpful, concise advice about healthy technology use and digital habits. If I ask anything irrelevant reply, with Sorry, I don't understand"
        
        let generationData = GenerationData(
            generationConfig: GenerationConfig(
                temperature: 1.0,
                topP: 0.95,
                topK: 64,
                maxOutputTokens: 4096,
                responseMimeType: "text/plain"
            ),
            contents: [
                Content(
                    role: "user",
                    parts: [
                        Part(text: prompt)
                    ]
                )
            ],
            systemInstruction: SystemInstruction(
                role: "system",
                parts: [
                    Part(text: systemPrompt)
                ]
            )
        )
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(generationData)
            
            let result = await withCheckedContinuation { continuation in
                let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                    if let error = error {
                        print("Network error: \(error.localizedDescription)")
                        continuation.resume(returning: "I'm sorry, I couldn't generate a response right now. (Network Error)")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data received")
                        continuation.resume(returning: "I'm sorry, I couldn't generate a response right now.")
                        return
                    }
                    
                    do {
                        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                        if let text = geminiResponse.candidates.first?.content.parts.first?.text {
                            continuation.resume(returning: text)
                        } else {
                            print("No response text found in the API response")
                            continuation.resume(returning: "I'm sorry, I couldn't generate a response right now.")
                        }
                    } catch {
                        print("Error decoding data: \(error.localizedDescription)")
                        continuation.resume(returning: "I'm sorry, I couldn't generate a response right now.")
                    }
                }
                task.resume()
            }
            
            return result
        } catch {
            print("Error encoding request: \(error.localizedDescription)")
            return "I'm sorry, I couldn't generate a response right now."
        }
    }
}
