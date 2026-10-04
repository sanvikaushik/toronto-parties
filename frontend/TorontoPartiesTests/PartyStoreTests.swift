import XCTest
@testable import TorontoParties

@MainActor final class PartyStoreTests: XCTestCase {
    private func catalog() async throws -> Catalog { try await BundledEventRepository().loadCatalog() }

    func testFixtureRelationshipsAndDates() async throws {
        let data = try await catalog()
        XCTAssertEqual(Set(data.events.map(\.id)).count, data.events.count)
        XCTAssertFalse(data.events.isEmpty)
        for event in data.events {
            XCTAssertFalse(event.title.isEmpty)
            XCTAssertTrue(event.artistIDs.allSatisfy { id in data.artists.contains { $0.id == id } })
            XCTAssertEqual(event.ticketURL?.host, "www.eventbrite.ca", "Each listing should link to its Eventbrite source")
        }
        XCTAssertTrue(data.friendPlans.allSatisfy { plan in data.events.contains { $0.id == plan.eventID } })
    }

    func testSavedAndAttendancePersistAndReset() async throws {
        let suite = "tests.\(UUID())"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = PartyStore(repository: BundledEventRepository(), defaults: defaults)
        await store.load()
        let event = try XCTUnwrap(store.events.first)
        store.toggleSaved(event)
        store.setAttendance(.going, for: event)
        let restored = PartyStore(repository: BundledEventRepository(), defaults: defaults)
        XCTAssertTrue(restored.savedIDs.contains(event.id))
        XCTAssertEqual(restored.attendance[event.id], .going)
        restored.toggleSaved(event)
        restored.setAttendance(nil, for: event)
        XCTAssertFalse(restored.savedIDs.contains(event.id))
        XCTAssertNil(restored.attendance[event.id])
        restored.resetPersonalData()
        XCTAssertNil(defaults.object(forKey: "party.saved.v1"))
    }

    func testSearchCombinesGenreAndArtist() async throws {
        let store = PartyStore(repository: BundledEventRepository())
        await store.load()
        XCTAssertEqual(store.matchingEvents(query: "  SPIN SINGH  ", filter: .bollywood).count, 1)
        XCTAssertTrue(store.matchingEvents(query: "no such night", filter: .all).isEmpty)
        XCTAssertEqual(store.matchingEvents(query: "King West", filter: .bollywood).first?.id, "lets-nacho-oria-2026-10-17")
    }

    func testRepositoryErrorAndRetry() async {
        let store = PartyStore(repository: FailingRepository())
        await store.load()
        XCTAssertNotNil(store.errorMessage)
        XCTAssertFalse(store.isLoading)
        XCTAssertTrue(store.events.isEmpty)
        await store.load()
        XCTAssertNotNil(store.errorMessage)
    }

    func testBackendPathPreservesBasePath() {
        let repository = APIEventRepository(baseURL: URL(string: "https://example.com/api")!)
        XCTAssertEqual(repository.catalogURL.absoluteString, "https://example.com/api/v1/catalog")
    }
}

private struct FailingRepository: EventRepository {
    func loadCatalog() async throws -> Catalog { throw URLError(.notConnectedToInternet) }
}
