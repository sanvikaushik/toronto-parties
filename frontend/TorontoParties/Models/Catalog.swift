import Foundation

struct PartyEvent: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let startsAt: Date
    let venue: String
    let neighborhood: String
    let genres: [String]
    let description: String
    let minimumAge: Int
    let priceLabel: String
    let artistIDs: [String]
    let artworkName: String?
    let artworkURL: URL?
    let ticketURL: URL?
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

struct Catalog: Codable {
    let events: [PartyEvent]
    let artists: [Artist]
    let friendPlans: [FriendPlan]
}

enum Attendance: String, Codable, CaseIterable {
    case interested = "Interested"
    case going = "Going"
}

enum NightFilter: String, CaseIterable {
    case all = "All nights", bollywood = "Bollywood", throwbacks = "Throwbacks"
}
