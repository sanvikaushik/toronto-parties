# Toronto Parties — SwiftUI prototype

A native iPhone prototype with a clean monochrome design, disco-ball artwork, discovery/search, genre filters, event details, DJ profiles, sample friends, bookmarks, and local attendance choices. iOS 17+, Xcode 16+; no third-party packages.

## Run it

1. Open `TorontoParties.xcodeproj` in Xcode.
2. Select the **TorontoParties** scheme and an iPhone simulator.
3. Press **Run** (⌘R). No account or backend setup is needed.

To run on your own iPhone, select your Apple development team under Signing & Capabilities, then choose your connected phone. Simulator builds do not need a team.

## Where to edit

- `TorontoParties/Features/`: screens and interactions.
- `TorontoParties/Design/`: reusable UI and layout tokens.
- `TorontoParties/Models/Catalog.swift`: event, artist, and community models.
- `TorontoParties/Resources/catalog.json`: all sample event, artist, and friend data.
- `TorontoParties/Data/EventRepository.swift`: bundled and HTTP data providers.
- `TorontoParties/App/PartyStore.swift`: loading, filtering, bookmarks, attendance, persistence.

Event content is data-driven; views do not contain specific event records. App copy and visual styles remain in the SwiftUI components. Sample event dates are fixed October 2026 fixtures, not a live feed.

## Connect your backend later

The app talks to **your backend**, which can import and normalize Eventbrite events. Do not put an Eventbrite token in the iOS app.

Set the `BACKEND_BASE_URL` environment variable in Xcode's scheme → Run → Arguments to your HTTPS backend origin. Alternatively provide the `BackendBaseURL` Info.plist value for a built app. If neither valid HTTPS setting exists, the app uses the bundled JSON.

The starter adapter requests `GET <baseURL>/v1/catalog`. This is a **proposed app API**, not an Eventbrite endpoint or Eventbrite response schema. Return the shape in `Resources/catalog.json`:

- `events`: stable IDs, title, ISO-8601 `startsAt` (with timezone), venue, neighborhood, genres, description, minimumAge, priceLabel, artistIDs, artworkName, artworkURL, ticketURL, featured.
- `artists`: stable ID, name, tagline, bio.
- `friendPlans`: stable ID, name, initials, eventID, status.

For live images set `artworkURL` to an HTTPS URL; `artworkName` is only for bundled assets. Null ticket links show a preview notice; real HTTP(S) ticket links open the provider. Optional artwork and ticket fields may be null or omitted. Return dates such as `2026-10-17T22:00:00-04:00` (no fractional seconds with the current decoder).

Eventbrite ingestion and organizer/DJ enrichment belong in the backend. Social data will require your own account/community service; it is not assumed to come from Eventbrite. Add pagination, authentication, cache policy, and incremental loading when implementing the production API. The repository protocol is the boundary for those changes.

## Prototype boundaries

- Events, venues, DJs and friends are fictional fixtures.
- Saved nights and attendance persist only on this device through UserDefaults.
- Attendance is not sent to anyone. Share uses the native share sheet; it does not create an invitation system.
- No purchases, live reviews, actual crowd demographics, media uploads, authentication, or live Eventbrite synchronization are implemented.
- Disco artwork is generated concept imagery; replace with your own licensed/organizer artwork for launch.

## Tests

Use Product → Test (⌘U). Tests cover fixture relationships, persistence/reset, combined search/filtering, error recovery state, and backend path composition.

## Verification

Built and launched on the iPhone 18 Pro / iOS 27 simulator with Xcode's installed Swift 6.4 compiler. All 5 unit tests passed. The Discover screen was visually checked; `Design/discover-preview.png` is the actual simulator capture. Full manual navigation and physical-device testing remain for follow-up.
