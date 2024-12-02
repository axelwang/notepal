/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI

@main
struct NotePalApp: App {
    @StateObject private var store = ScrumStore()
    @StateObject private var historyStore = HistoryStore()

    @State private var errorWrapper: ErrorWrapper?

    var body: some Scene {
        WindowGroup {
            ScrumsView(scrums: $store.scrums) {
                Task {
                    do {
                        try await store.save(scrums: store.scrums)
                    } catch {
                        errorWrapper = ErrorWrapper(error: error,
                                                    guidance: "Try again later.")
                    }
                }
            }
            .environmentObject(historyStore)
            .task {
                do {
                    try await store.load()
                } catch {
                    errorWrapper = ErrorWrapper(error: error,
                                                guidance: "NotePal will load sample data and continue.")
                }
            }
            .sheet(item: $errorWrapper) {
                store.scrums = DailyScrum.sampleData
            } content: { wrapper in
                ErrorView(errorWrapper: wrapper)
            }
        }
    }
}
