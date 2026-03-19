import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: URL
    private let session: URLSession
    private var accessToken: String?
    
    private init() {
        // 从环境变量或配置读取
        self.baseURL = URL(string: "http://localhost:8080/api/v1")!
        self.session = URLSession(configuration: .default)
    }
    
    func setAccessToken(_ token: String?) {
        self.accessToken = token
    }
    
    // MARK: - Generic Request
    
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 400...499:
            let error = try? JSONDecoder().decode(APIErrorDetail.self, from: data)
            throw APIError.clientError(error?.error ?? "Unknown error")
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.unknown
        }
    }
}

// MARK: - HTTP Methods

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Errors

enum APIError: Error, LocalizedError {
    case invalidResponse
    case unauthorized
    case clientError(String)
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Authentication required"
        case .clientError(let message):
            return message
        case .serverError:
            return "Server error"
        case .unknown:
            return "Unknown error"
        }
    }
}

struct APIErrorDetail: Decodable {
    let error: String
}

// MARK: - Request/Response Models

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let display_name: String?
}

struct AuthResponse: Decodable {
    let token: TokenResponse
    let user: UserResponse
}

struct TokenResponse: Decodable {
    let access_token: String
    let refresh_token: String
    let expires_in: Int
}

struct UserResponse: Decodable {
    let id: String
    let email: String
    let display_name: String?
    let avatar_url: String?
}
