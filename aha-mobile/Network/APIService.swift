
import Foundation

enum APIError: Error {
    case invalidURL
    case decodingError
    case networkError(Error)
}

class APIService {
    static func fetchProducts(for eventCode: String) async throws -> [Product] {
        let urlString = "https://aha.youthacks.org/api/\(eventCode)/products"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        print("🔍 API response: \(String(data: data, encoding: .utf8) ?? "No body")")

        do {
            return try JSONDecoder().decode([Product].self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}
