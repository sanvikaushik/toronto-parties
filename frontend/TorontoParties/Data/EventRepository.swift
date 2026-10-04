import Foundation

protocol EventRepository {
    func loadCatalog() async throws -> Catalog
}

enum CatalogCoding {
    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

struct BundledEventRepository: EventRepository {
    let bundle: Bundle
    init(bundle: Bundle = .main) { self.bundle = bundle }
    func loadCatalog() async throws -> Catalog {
        guard let url = bundle.url(forResource: "catalog", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try CatalogCoding.decoder().decode(Catalog.self, from: Data(contentsOf: url))
    }
}

/// Talks to our own backend; Eventbrite credentials never belong in this app.
struct APIEventRepository: EventRepository {
    let baseURL: URL
    var session: URLSession = .shared
    var catalogURL: URL { baseURL.appendingPathComponent("v1/catalog") }
    func loadCatalog() async throws -> Catalog {
        var request = URLRequest(url: catalogURL)
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse,
              (200..<300).contains(response.statusCode) else { throw URLError(.badServerResponse) }
        return try CatalogCoding.decoder().decode(Catalog.self, from: data)
    }
}

struct AppConfiguration {
    let backendURL: URL?
    var isDemo: Bool { backendURL == nil }
    static var current: AppConfiguration {
        let raw = ProcessInfo.processInfo.environment["BACKEND_BASE_URL"]
            ?? Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String ?? ""
        let url = URL(string: raw)
        return AppConfiguration(backendURL: url?.scheme == "https" && url?.host != nil ? url : nil)
    }
    func repository() -> any EventRepository {
        if let backendURL { return APIEventRepository(baseURL: backendURL) }
        return BundledEventRepository()
    }
}
