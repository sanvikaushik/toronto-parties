import SwiftUI

enum Layout {
    static let inset: CGFloat = 24
    static let radius: CGFloat = 18
}

extension PartyEvent {
    private func torontoDate(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_CA")
        formatter.timeZone = TimeZone(identifier: "America/Toronto")
        formatter.dateFormat = format
        return formatter.string(from: startsAt)
    }
    var dateLabel: String { torontoDate("EEE, MMM d") }
    var timeLabel: String { torontoDate("h:mm a") }
}

struct PageHeading: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(eyebrow.uppercased()).font(.system(size: 10, weight: .semibold, design: .monospaced)).tracking(2).foregroundStyle(.secondary)
            Text(title).font(.system(size: 38, weight: .bold)).tracking(-1.7).fixedSize(horizontal: false, vertical: true)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EventArtwork: View {
    let event: PartyEvent
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let url = event.artworkURL {
                    AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                        placeholder: { posterPlaceholder }
                } else if let name = event.artworkName {
                    Image(name).resizable().scaledToFill()
                } else { fallback }
            }.frame(width: geometry.size.width, height: geometry.size.height).clipped()
        }.accessibilityHidden(true)
    }
    private var fallback: some View {
        ZStack { Color.black; Image(systemName: "opticaldisc").font(.system(size: 74, weight: .ultraLight)).foregroundStyle(.white) }
    }
    private var posterPlaceholder: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [.black, Color(white: 0.16)], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack(alignment: .leading, spacing: 6) {
                Text("TORONTO AFTER DARK")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.68))
                Text(event.title)
                    .font(.system(size: 18, weight: .bold))
                    .tracking(-0.5)
                    .foregroundStyle(.white)
                    .lineLimit(3)
            }
            .padding(18)
        }
    }
}

struct SaveButton: View {
    @Environment(PartyStore.self) private var store
    let event: PartyEvent
    var body: some View {
        Button { store.toggleSaved(event) } label: {
            Image(systemName: store.savedIDs.contains(event.id) ? "bookmark.fill" : "bookmark")
                .font(.system(size: 19)).frame(width: 44, height: 44)
        }.buttonStyle(.plain)
            .accessibilityLabel(store.savedIDs.contains(event.id) ? "Unsave \(event.title)" : "Save \(event.title)")
            .accessibilityIdentifier("save-\(event.id)")
    }
}

struct InitialsView: View {
    let text: String
    var size: CGFloat = 32
    var body: some View {
        Text(text).font(.system(size: size * 0.3, weight: .medium))
            .frame(width: size, height: size).background(Color(.systemGray6), in: Circle())
    }
}

struct FriendsSummary: View {
    let plans: [FriendPlan]
    var body: some View {
        if !plans.isEmpty {
            HStack(spacing: 9) {
                HStack(spacing: -6) {
                    ForEach(Array(plans.prefix(3))) { plan in
                        InitialsView(text: plan.initials).overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
                Text("\(plans.count) friend\(plans.count == 1 ? "" : "s") planning a night")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct GenreTag: View {
    let text: String
    var body: some View {
        Text(text).font(.caption).padding(.horizontal, 10).padding(.vertical, 6)
            .overlay(Capsule().stroke(Color(.systemGray4), lineWidth: 0.5))
    }
}

struct EventRow: View {
    @Environment(PartyStore.self) private var store
    let event: PartyEvent
    var body: some View {
        HStack(spacing: 14) {
            NavigationLink(value: event) {
                HStack(spacing: 14) {
                    EventArtwork(event: event).frame(width: 66, height: 76).clipShape(RoundedRectangle(cornerRadius: 10))
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.title).font(.system(size: 16, weight: .semibold)).foregroundStyle(.primary)
                        Text(event.dateLabel).font(.caption).foregroundStyle(.secondary)
                        Text("\(event.neighborhood) · \(event.organizerName ?? "Toronto")").font(.caption).foregroundStyle(.secondary).lineLimit(1)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.contentShape(Rectangle())
            }.buttonStyle(.plain)
            SaveButton(event: event)
        }.padding(.vertical, 14)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity).padding(.vertical, 17)
            .foregroundStyle(.white).background(.black.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 14))
    }
}
