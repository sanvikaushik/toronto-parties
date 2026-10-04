import SwiftUI
import Observation

@MainActor @Observable final class PartyStore {
    private(set) var events: [PartyEvent] = []
    private(set) var artists: [Artist] = []
    private(set) var friendPlans: [FriendPlan] = []
    private(set) var organizers: [OrganizerProfile] = []
    private(set) var savedIDs: Set<String>
    private(set) var attendance: [String: Attendance]
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    let isDemo: Bool
    private let repository: any EventRepository
    private let defaults: UserDefaults
    private let savedKey = "party.saved.v1"
    private let attendanceKey = "party.attendance.v1"

    init(repository: any EventRepository, isDemo: Bool = true, defaults: UserDefaults = .standard) {
        self.repository = repository
        self.isDemo = isDemo
        self.defaults = defaults
        savedIDs = Set(defaults.stringArray(forKey: savedKey) ?? [])
        attendance = (defaults.dictionary(forKey: attendanceKey) as? [String: String] ?? [:])
            .compactMapValues(Attendance.init(rawValue:))
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let catalog = try await repository.loadCatalog()
            events = catalog.events.sorted { $0.startsAt < $1.startsAt }
            artists = catalog.artists
            friendPlans = catalog.friendPlans
            organizers = catalog.organizers
        } catch {
            errorMessage = "We couldn't load the nights. Check your connection and try again."
        }
    }

    func toggleSaved(_ event: PartyEvent) {
        if savedIDs.contains(event.id) { savedIDs.remove(event.id) }
        else { savedIDs.insert(event.id) }
        defaults.set(Array(savedIDs), forKey: savedKey)
    }

    func setAttendance(_ value: Attendance?, for event: PartyEvent) {
        attendance[event.id] = value
        defaults.set(attendance.mapValues(\.rawValue), forKey: attendanceKey)
    }

    func resetPersonalData() {
        savedIDs.removeAll()
        attendance.removeAll()
        defaults.removeObject(forKey: savedKey)
        defaults.removeObject(forKey: attendanceKey)
    }

    func matchingEvents(query: String, filter: NightFilter) -> [PartyEvent] {
        events.filter { event in
            let matchesGenre = filter == .all || event.genres.contains(filter.rawValue)
            let searchable = ([event.title, event.venue, event.neighborhood] + event.genres
                + artists.filter { event.artistIDs.contains($0.id) }.map(\.name)).joined(separator: " ")
            return matchesGenre && (query.trimmingCharacters(in: .whitespaces).isEmpty
                || searchable.localizedCaseInsensitiveContains(query.trimmingCharacters(in: .whitespaces)))
        }
    }

    func friends(for event: PartyEvent) -> [FriendPlan] { friendPlans.filter { $0.eventID == event.id } }
}
