/*
 See LICENSE folder for this sample’s licensing information.
 */

import Foundation

struct History: Identifiable, Codable {
    let id: UUID
    let date: Date
    var attendees: [DailyScrum.Attendee]
    var transcript: String?
    let scrum: UUID

    init(id: UUID = UUID(), date: Date = Date(), attendees: [DailyScrum.Attendee], transcript: String? = nil, scrum: UUID) {
        self.id = id
        self.date = date
        self.attendees = attendees
        self.transcript = transcript
        self.scrum = scrum
    }
}


extension History {
    static let sampleData: [History] =
    [
        History(
            id: UUID(),
            date: Date.now.addingTimeInterval(-86400 * 14), // 2 weeks ago
            attendees: [
                DailyScrum.Attendee(name: "Design"),
                DailyScrum.Attendee(name: "App Dev")
            ],
            transcript: "Initial brainstorming session for NotePal. Discussed core features: markdown support, cloud sync, and collaborative editing. Design team to prepare wireframes for next meeting.",
            scrum: UUID()
        ),
        History(
            id: UUID(),
            date: Date.now.addingTimeInterval(-86400 * 7), // 1 week ago
            attendees: [
                DailyScrum.Attendee(name: "Design"),
                DailyScrum.Attendee(name: "App Dev"),
                DailyScrum.Attendee(name: "Web Dev")
            ],
            transcript: "Design presented initial mockups. Team loved the minimalist interface. Decided on SwiftUI for iOS app and React for web version. Discussion about offline-first architecture and sync strategy.",
            scrum: UUID()
        ),
        History(
            id: UUID(),
            date: Date.now.addingTimeInterval(-86400 * 2), // 2 days ago
            attendees: [
                DailyScrum.Attendee(name: "Design"),
                DailyScrum.Attendee(name: "App Dev"),
                DailyScrum.Attendee(name: "Web Dev")
            ],
            transcript: "MVP feature list finalized: rich text editor, folders, tags, and basic sharing. First sprint planned for editor implementation. Team discussed monetization: freemium model with premium features like advanced collaboration.",
            scrum: UUID()
        )
    ]
}
