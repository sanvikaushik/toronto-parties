import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { DiscoverView().navigationDestination(for: PartyEvent.self) { EventDetailView(event: $0) } }
                .tabItem { Label("Discover", systemImage: "square.grid.2x2") }
            NavigationStack { FriendsView().navigationDestination(for: PartyEvent.self) { EventDetailView(event: $0) } }
                .tabItem { Label("Friends", systemImage: "person.2") }
            NavigationStack { SavedView().navigationDestination(for: PartyEvent.self) { EventDetailView(event: $0) } }
                .tabItem { Label("Saved", systemImage: "bookmark") }
            NavigationStack { ProfileView() }
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

struct DiscoverView: View {
    @Environment(PartyStore.self) private var store
    @State private var query = ""
    @State private var filter: NightFilter = .all
    @State private var searchVisible = false
    private var results: [PartyEvent] { store.matchingEvents(query: query, filter: filter) }
    private var featured: PartyEvent? { results.first(where: \.featured) ?? results.first }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                HStack {
                    Label("Toronto", systemImage: "location.circle").font(.subheadline.weight(.medium))
                    Spacer()
                    if store.isDemo { Text("DEMO").font(.system(size: 9, weight: .medium, design: .monospaced)).tracking(1.5).foregroundStyle(.secondary) }
                    Button { withAnimation { searchVisible.toggle() }; if !searchVisible { query = "" } } label: {
                        Image(systemName: searchVisible ? "xmark" : "magnifyingglass").frame(width: 44, height: 44)
                    }.accessibilityLabel(searchVisible ? "Close search" : "Search nights")
                }
                PageHeading(eyebrow: "THE CITY, AFTER HOURS", title: "Find your\nnext night.", subtitle: "Bollywood. Toronto. Your people.")
                if searchVisible {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField("Event, neighborhood or DJ", text: $query).autocorrectionDisabled()
                            .accessibilityIdentifier("event-search")
                    }.padding(14).background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 23) {
                        ForEach(NightFilter.allCases, id: \.self) { option in
                            Button { filter = option } label: {
                                VStack(spacing: 10) {
                                    Text(option.rawValue).font(.subheadline.weight(filter == option ? .semibold : .regular))
                                    Rectangle().fill(filter == option ? Color.primary : Color.clear).frame(height: 2)
                                }.foregroundStyle(filter == option ? .primary : .secondary)
                            }.buttonStyle(.plain).accessibilityAddTraits(filter == option ? .isSelected : [])
                        }
                    }
                }
                if store.isLoading && store.events.isEmpty {
                    ProgressView("Finding your next night…").frame(maxWidth: .infinity).padding(40)
                } else if let error = store.errorMessage {
                    ContentUnavailableView { Label("Couldn't load events", systemImage: "wifi.exclamationmark") }
                        description: { Text(error) } actions: { Button("Try again") { Task { await store.load() } } }
                } else if let featured {
                    featuredCard(featured)
                    let remaining = results.filter { $0.id != featured.id }
                    if !remaining.isEmpty {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack { Text("Coming up").font(.title3.bold()); Spacer(); Text("\(remaining.count) nights").font(.caption).foregroundStyle(.secondary) }
                            ForEach(remaining) { event in EventRow(event: event); Divider() }
                        }
                    }
                } else {
                    ContentUnavailableView.search(text: query.isEmpty ? filter.rawValue : query)
                }
                if !store.organizers.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Promoters to know").font(.title3.bold())
                            Spacer()
                            Text("PROFILES").font(.system(size: 9, design: .monospaced)).tracking(1.2).foregroundStyle(.secondary)
                        }
                        ForEach(store.organizers) { organizer in
                            HStack(spacing: 13) {
                                Image(systemName: "sparkle").font(.system(size: 16)).frame(width: 42, height: 42).background(Color(.systemGray6), in: Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(organizer.name).font(.subheadline.weight(.semibold))
                                    Text(organizer.note).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                    if let previous = organizer.recentListing {
                                        Text(previous).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                                    }
                                }
                                Spacer(minLength: 0)
                                Link(destination: organizer.eventbriteURL) {
                                    Image(systemName: "arrow.up.right").font(.subheadline).frame(width: 36, height: 40)
                                }.accessibilityLabel("Open \(organizer.name) on Eventbrite")
                            }.padding(.vertical, 7)
                            if organizer.id != store.organizers.last?.id { Divider() }
                        }
                    }
                }
                if store.isDemo { Text("Event snapshots checked Oct 4, 2026 · demo friend activity · not a live feed.")
                    .font(.caption).foregroundStyle(.secondary).lineSpacing(3) }
            }.padding(.horizontal, Layout.inset).padding(.bottom, 24)
        }.toolbar(.hidden, for: .navigationBar).refreshable { await store.load() }
    }
    private func featuredCard(_ event: PartyEvent) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            NavigationLink(value: event) {
                EventArtwork(event: event).frame(height: 215)
                    .overlay(alignment: .bottomLeading) {
                        Text("THE WEEKEND EDIT  ↗").font(.system(size: 10, weight: .semibold, design: .monospaced)).tracking(1.5)
                            .foregroundStyle(.white).padding(18).background(.black.opacity(0.25), in: Capsule()).padding(10)
                    }.clipShape(RoundedRectangle(cornerRadius: Layout.radius))
            }.buttonStyle(.plain).accessibilityLabel("View \(event.title)")
            HStack(alignment: .top) {
                NavigationLink(value: event) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(event.title).font(.title3.bold()).tracking(-0.5)
                        Text("\(event.dateLabel) · \(event.neighborhood)").font(.caption).foregroundStyle(.secondary)
                        if let organizer = event.organizerName {
                            Text("BY \(organizer.uppercased())").font(.system(size: 9, weight: .medium, design: .monospaced)).tracking(1.1).foregroundStyle(.secondary)
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.buttonStyle(.plain)
                SaveButton(event: event)
            }
            FriendsSummary(plans: store.friends(for: event))
        }
    }
}
