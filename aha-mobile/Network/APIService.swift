import Foundation

enum APIError: Error {
    case invalidURL
    case decodingError
    case networkError(Error)
}

class APIService {
    static let baseURL = "https://aha.youthacks.org/api"

    static func fetch<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidURL
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }

    static func fetchEvent(for slug: String) async throws -> Event {
        return try await fetch("/events/\(slug)")
    }

    static func fetchProducts(for eventSlug: String) async throws -> [Product] {
        // You can use this to validate t:?he event exists
        _ = try await fetchEvent(for: eventSlug)
        return try await fetch("/\(eventSlug)/products")
    }
}
