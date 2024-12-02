/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI



struct HistoryView: View {
    let history: History
    @State private var showingChat = false
    
    var body: some View {
        ScrollView {
             // Chat Section
            VStack(alignment: .leading, spacing: 10) {
                Button(action: {
                    showingChat.toggle()
                }) {
                    HStack {
                        Image(systemName: "message.circle.fill")
                        Text("Ask AI about this meeting")
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical)
                }
            }
            .padding(.top)
            
            if showingChat {
                ChatSection(transcript: history.transcript ?? "")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            VStack(alignment: .leading) {
                Divider()
                    .padding(.bottom)
                Text("Attendees")
                    .font(.headline)
                Text(history.attendeeString)
                
                if let transcript = history.transcript {
                    Text("Transcript")
                        .font(.headline)
                        .padding(.top)
                    Text(transcript)
                }
                
               
            }
        }
        .navigationTitle(Text(history.date, style: .date))
        .padding()      
        .animation(.spring(), value: showingChat)
    }
}

// New ChatSection view specifically for history context
struct ChatSection: View {
    @StateObject private var gpt = AskGPT()
    @State private var question = ""
    @State private var lastQuestion = ""
    let transcript: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Assistant")
                .font(.headline)
            
            // Response display area
            ScrollView {
                Spacer()
                    .frame(height: 8)
                    
                if !lastQuestion.isEmpty {
                    Text("Question: \(lastQuestion)")
                        .fontWeight(.medium)
                        .padding(.bottom, 4)
                }
                Text(gpt.response)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Input area
            HStack {
                TextField("Ask about this meeting...", text: $question)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    Task {
                        lastQuestion = question
                        let contextualQuestion = """
                        Meeting Transcript: \(transcript)
                        
                        User Question: \(question)
                        
                        Please answer the question based on the meeting transcript above.
                        """
                        await gpt.askQuestion(contextualQuestion)
                        question = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .disabled(question.isEmpty || gpt.isLoading)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
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

extension History {
    var attendeeString: String {
        ListFormatter.localizedString(byJoining: attendees.map { $0.name })
    }
}
