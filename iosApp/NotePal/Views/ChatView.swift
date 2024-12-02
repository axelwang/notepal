import SwiftUI

struct ChatView: View {
    @StateObject private var gpt = AskGPT()
    @State private var question = ""
    
    var body: some View {
        VStack {
            // Response display area
            ScrollView {
                Text(gpt.response)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Input area
            HStack {
                TextField("Ask a question...", text: $question)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    Task {
                        await gpt.askQuestion(question)
                        question = "" // Clear the input after sending
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .disabled(question.isEmpty || gpt.isLoading)
            }
            .padding()
        }
        .padding()
        .overlay {
            if gpt.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .alert("Error", isPresented: .constant(gpt.error != nil)) {
            Button("OK") {
                gpt.error = nil
            }
        } message: {
            Text(gpt.error ?? "")
        }
    }
}

#Preview {
    ChatView()
} 