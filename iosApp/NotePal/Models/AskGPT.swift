import Foundation
import Combine

class AskGPT: ObservableObject {
    @Published var response: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let apiKey = "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"
    private let apiUrl = "https://api.openai.com/v1/chat/completions" // Example endpoint

    func askQuestion(_ question: String) async {
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": question]
        ]
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo", // Specify the model here
            "messages": messages,
            "max_tokens": 150
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            self.error = "Failed to encode request body"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debug print to see the raw response data
        if let rawResponse = String(data: data, encoding: .utf8) {
            print("Raw Response: \(rawResponse)")
        }
        
        if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let choices = jsonResponse["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            DispatchQueue.main.async {
                self.response = content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else {
            self.error = "Invalid response from server"
        }
    } catch {
            self.error = "Network error: \(error.localizedDescription)"
        }
    }
}
