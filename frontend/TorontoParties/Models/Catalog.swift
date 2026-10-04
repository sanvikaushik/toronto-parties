import Foundation

struct PartyEvent: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let startsAt: Date
    let venue: String
    let neighborhood: String
    let genres: [String]
    let description: String
    let minimumAge: Int?
    let priceLabel: String
    let artistIDs: [String]
    let artworkName: String?
    let artworkURL: URL?
    let ticketURL: URL?
    let organizerName: String?
    let featured: Bool
}

struct Artist: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let bio: String
}

struct FriendPlan: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let initials: String
    let eventID: String
    let status: String
}

struct OrganizerProfile: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let note: String
    let eventbriteURL: URL
    let recentListing: String?
}

struct Catalog: Codable {
    let events: [PartyEvent]
    let artists: [Artist]
    let friendPlans: [FriendPlan]
    let organizers: [OrganizerProfile]

    private enum CodingKeys: String, CodingKey { case events, artists, friendPlans, organizers }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        events = try values.decode([PartyEvent].self, forKey: .events)
        artists = try values.decode([Artist].self, forKey: .artists)
        friendPlans = try values.decode([FriendPlan].self, forKey: .friendPlans)
        organizers = try values.decodeIfPresent([OrganizerProfile].self, forKey: .organizers) ?? []
    }
}

enum Attendance: String, Codable, CaseIterable {
    case interested = "Interested"
    case going = "Going"
}

enum NightFilter: String, CaseIterable {
    case all = "All nights", bollywood = "Bollywood", throwbacks = "Throwbacks"
}
