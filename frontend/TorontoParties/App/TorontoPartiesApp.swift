import SwiftUI

@main struct TorontoPartiesApp: App {
    @State private var store: PartyStore
    init() {
        let configuration = AppConfiguration.current
        _store = State(initialValue: PartyStore(repository: configuration.repository(), isDemo: configuration.isDemo))
    }
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(.primary)
                .preferredColorScheme(.light)
                .task { await store.load() }
        }
    }
}
