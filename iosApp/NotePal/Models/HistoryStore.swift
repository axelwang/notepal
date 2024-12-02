import SwiftUI

@MainActor
class HistoryStore: ObservableObject {
    @Published var histories: [History] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("histories.data")
    }
    
    func load() async throws {
        let task = Task<[History], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let histories = try JSONDecoder().decode([History].self, from: data)
            return histories
        }
        let histories = try await task.value
        self.histories = histories
    }
    
    func save(histories: [History]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(histories)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}