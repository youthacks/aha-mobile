import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(code: Int)
    case decodingError
    case networkError(Error)
}

class APIService {
    static let baseURL = "https://aha.youthacks.org/api"

    static func fetch<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        print("🔗 Requesting: \(url)")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("📥 Response: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(code: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ Decoding error: \(error)")
            throw APIError.decodingError
        }
    }

    static func fetchEvent(for slug: String) async throws -> Event {
        try await fetch("/events/\(slug)")
    }

    static func fetchProducts(for eventSlug: String) async throws -> [Product] {
        try await fetch("/events/\(eventSlug)/products")
    }
}
