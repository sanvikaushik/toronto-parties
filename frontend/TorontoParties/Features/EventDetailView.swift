import SwiftUI

struct EventDetailView: View {
    @Environment(PartyStore.self) private var store
    let event: PartyEvent
    @State private var showFriends = false
    @State private var showDemoNotice = false
    @State private var selectedArtist: Artist?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                EventArtwork(event: event).frame(height: 240).clipShape(RoundedRectangle(cornerRadius: Layout.radius))
                VStack(alignment: .leading, spacing: 12) {
                    Text(event.dateLabel.uppercased()).font(.system(size: 10, weight: .medium, design: .monospaced)).tracking(2).foregroundStyle(.secondary)
                    Text(event.title).font(.system(size: 35, weight: .bold)).tracking(-1.2)
                    HStack { ForEach(event.genres, id: \.self) { GenreTag(text: $0) }; GenreTag(text: "\(event.minimumAge)+") }
                }
                Divider()
                VStack(spacing: 17) {
                    detailRow("clock", "When", "\(event.timeLabel) · Toronto time")
                    detailRow("mappin", "Where", "\(event.venue)\n\(event.neighborhood)")
                    detailRow("ticket", "Entry", event.priceLabel)
                }
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Text("The night").font(.title3.bold())
                    Text(event.description).font(.subheadline).foregroundStyle(.secondary).lineSpacing(5)
                }
                VStack(alignment: .leading, spacing: 14) {
                    Text("Make it your night").font(.title3.bold())
                    HStack {
                        ForEach(Attendance.allCases, id: \.self) { status in
                            Button {
                                store.setAttendance(store.attendance[event.id] == status ? nil : status, for: event)
                            } label: {
                                Label(status.rawValue, systemImage: store.attendance[event.id] == status ? "checkmark.circle.fill" : "circle")
                                    .font(.subheadline).frame(maxWidth: .infinity).padding(.vertical, 13)
                                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                            }.buttonStyle(.plain).accessibilityIdentifier("attendance-\(status.rawValue)")
                        }
                    }
                    Text("Your choice stays on this device in the prototype.").font(.caption).foregroundStyle(.secondary)
                }
                if !store.friends(for: event).isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 13) {
                        Text("Your people").font(.title3.bold())
                        FriendsSummary(plans: store.friends(for: event))
                        Button { showFriends = true } label: { Label("See who's going", systemImage: "arrow.up.right").font(.subheadline) }
                    }
                }
                ForEach(store.artists.filter { event.artistIDs.contains($0.id) }) { artist in
                    Divider()
                    Button { selectedArtist = artist } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("BEHIND THE DECKS").font(.system(size: 9, design: .monospaced)).tracking(1.4).foregroundStyle(.secondary)
                                Text(artist.name).font(.headline)
                                Text(artist.tagline).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer(); Image(systemName: "arrow.up.right")
                        }
                    }.buttonStyle(.plain)
                }
            }.padding(Layout.inset)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .topBarTrailing) { SaveButton(event: event) } }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                if let url = event.ticketURL, ["https", "http"].contains(url.scheme?.lowercased() ?? "") {
                    Link(destination: url) { Label("Get tickets", systemImage: "arrow.up.right") }.buttonStyle(PrimaryButtonStyle())
                    Text("Opens the ticket provider").font(.caption2).foregroundStyle(.secondary)
                } else {
                    Button { showDemoNotice = true } label: { Label("Preview ticket flow", systemImage: "arrow.up.right") }.buttonStyle(PrimaryButtonStyle())
                    Text("Sample event · No tickets for sale").font(.caption2).foregroundStyle(.secondary)
                }
            }.padding(.horizontal, Layout.inset).padding(.vertical, 10).background(.white)
        }
        .alert("You're in the prototype", isPresented: $showDemoNotice) { Button("Got it", role: .cancel) {} }
            message: { Text("Real events will open their ticket page. Your backend will supply that link; this sample event cannot be booked.") }
        .sheet(isPresented: $showFriends) {
            NavigationStack {
                List(store.friends(for: event)) { friend in
                    HStack(spacing: 15) { InitialsView(text: friend.initials); Text(friend.name); Spacer(); Text(friend.status).foregroundStyle(.secondary) }
                }.navigationTitle("Your people")
                    .safeAreaInset(edge: .bottom) { Text("Sample community activity").font(.caption).padding() }
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showFriends = false } } }
            }.presentationDetents([.medium, .large])
        }
        .sheet(item: $selectedArtist) { artist in
            NavigationStack {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "waveform").font(.system(size: 50, weight: .ultraLight)).padding(.vertical)
                    Text(artist.name).font(.largeTitle.bold())
                    Text(artist.tagline).foregroundStyle(.secondary)
                    Text(artist.bio).lineSpacing(5)
                    Text("Sample DJ profile").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                }.padding(30).navigationTitle("Behind the decks").navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { selectedArtist = nil } } }
            }.presentationDetents([.medium, .large])
        }
    }
    private func detailRow(_ icon: String, _ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon).frame(width: 20)
            Text(title).foregroundStyle(.secondary).frame(width: 49, alignment: .leading)
            Text(value).frame(maxWidth: .infinity, alignment: .leading)
        }.font(.subheadline)
    }
}
