import SwiftUI

struct FriendsView: View {
    @Environment(PartyStore.self) private var store
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                PageHeading(eyebrow: "YOUR TORONTO CIRCLE", title: "Better\ntogether.", subtitle: "Good nights start with your people.")
                if store.isDemo { Label("Sample friends · Preview only", systemImage: "person.2").font(.caption).foregroundStyle(.secondary) }
                let myPlans = store.events.filter { store.attendance[$0.id] != nil }
                if !myPlans.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Your plans").font(.title3.bold())
                        ForEach(myPlans) { event in
                            HStack { NavigationLink(event.title, value: event).font(.subheadline.weight(.medium)); Spacer(); Text(store.attendance[event.id]?.rawValue ?? "").font(.caption).foregroundStyle(.secondary) }.padding(.vertical, 9)
                        }
                    }
                }
                Text("Around your circle").font(.title3.bold())
                if store.friendPlans.isEmpty { ContentUnavailableView("Your circle starts here", systemImage: "person.2", description: Text("Friend activity will appear when your community is connected.")) }
                ForEach(store.friendPlans) { plan in
                    if let event = store.events.first(where: { $0.id == plan.eventID }) {
                        NavigationLink(value: event) {
                            HStack(alignment: .top, spacing: 14) {
                                InitialsView(text: plan.initials, size: 42)
                                VStack(alignment: .leading, spacing: 7) {
                                    Text("\(plan.name) · \(plan.status.lowercased())").font(.caption).foregroundStyle(.secondary)
                                    Text(event.title).font(.subheadline.weight(.semibold))
                                    Text(event.dateLabel).font(.caption).foregroundStyle(.secondary)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                EventArtwork(event: event).frame(width: 48, height: 58).clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }.buttonStyle(.plain)
                        Divider()
                    }
                }
                VStack(alignment: .leading, spacing: 12) {
                    Text("One night. Everyone in.").font(.title3.bold())
                    Text("Share the idea with your group chat.").font(.subheadline).foregroundStyle(.secondary)
                    ShareLink(item: "I'm trying Toronto Parties — a prototype for finding Bollywood nights and planning with friends in Toronto.") {
                        Label("Share the idea", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity).padding(15)
                    }.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 0.5))
                }
            }.padding(Layout.inset)
        }.toolbar(.hidden, for: .navigationBar)
    }
}

struct SavedView: View {
    @Environment(PartyStore.self) private var store
    private var saved: [PartyEvent] { store.events.filter { store.savedIDs.contains($0.id) } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                PageHeading(eyebrow: "YOUR SHORTLIST", title: "Worth a night.", subtitle: "All the nights you've kept an eye on.")
                if saved.isEmpty {
                    ContentUnavailableView("Start your shortlist", systemImage: "bookmark", description: Text("Tap a bookmark on Discover to keep a night here."))
                } else { ForEach(saved) { event in EventRow(event: event); Divider() } }
            }.padding(Layout.inset)
        }.toolbar(.hidden, for: .navigationBar)
    }
}

struct ProfileView: View {
    @Environment(PartyStore.self) private var store
    @State private var confirmReset = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                PageHeading(eyebrow: "YOUR SPACE", title: "Hello, night owl.", subtitle: "Your city. Your kind of night.")
                HStack(spacing: 18) {
                    InitialsView(text: "YOU", size: 62)
                    VStack(alignment: .leading, spacing: 5) { Text("Your local profile").font(.headline); Text("No account needed to explore").font(.caption).foregroundStyle(.secondary) }
                }
                Divider()
                HStack {
                    stat("Saved nights", value: store.savedIDs.count)
                    Spacer()
                    stat("Your plans", value: store.attendance.count)
                    Spacer()
                }
                Divider()
                Label("Stored on this device", systemImage: "lock").font(.headline)
                Text("Bookmarks and plans stay on this device. This prototype doesn't send invitations, share attendance, or create an account.").foregroundStyle(.secondary).font(.subheadline).lineSpacing(5)
                VStack(alignment: .leading, spacing: 8) {
                    Text("ABOUT THIS PREVIEW").font(.system(size: 10, design: .monospaced)).tracking(1.5)
                    Text(store.isDemo ? "You're browsing fictional events and sample friends. The artwork is generated concept imagery. Live listings can be connected through your backend." : "Events are loaded from the configured backend. Your personal saves and plans are still stored locally.")
                        .font(.caption).foregroundStyle(.secondary).lineSpacing(4)
                }.padding(18).background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14))
                Button("Reset my saved nights and plans", role: .destructive) { confirmReset = true }.font(.subheadline)
            }.padding(Layout.inset)
        }.toolbar(.hidden, for: .navigationBar)
            .confirmationDialog("Clear your local saved nights and plans?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset local data", role: .destructive) { store.resetPersonalData() }
            }
    }
    private func stat(_ label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 5) { Text("\(value)").font(.title.bold()); Text(label).font(.caption).foregroundStyle(.secondary) }
    }
}
