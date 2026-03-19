import Foundation
import SwiftUI

@Observable
class AuthService {
    static let shared = AuthService()
    
    private let apiClient = APIClient.shared
    private let keychain = KeychainService.shared
    
    var currentUser: UserResponse?
    var isAuthenticated: Bool { currentUser != nil && keychain.accessToken != nil }
    
    private init() {
        // Check for existing token
        if let token = keychain.accessToken {
            apiClient.setAccessToken(token)
            Task { await fetchCurrentUser() }
        }
    }
    
    func login(email: String, password: String) async throws {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await apiClient.request("/auth/login", method: .POST, body: request)
        
        keychain.accessToken = response.token.access_token
        keychain.refreshToken = response.token.refresh_token
        apiClient.setAccessToken(response.token.access_token)
        
        currentUser = response.user
    }
    
    func register(email: String, password: String, displayName: String?) async throws {
        let request = RegisterRequest(email: email, password: password, display_name: displayName)
        let response: AuthResponse = try await apiClient.request("/auth/register", method: .POST, body: request)
        
        keychain.accessToken = response.token.access_token
        keychain.refreshToken = response.token.refresh_token
        apiClient.setAccessToken(response.token.access_token)
        
        currentUser = response.user
    }
    
    func logout() {
        keychain.accessToken = nil
        keychain.refreshToken = nil
        apiClient.setAccessToken(nil)
        currentUser = nil
    }
    
    private func fetchCurrentUser() async {
        do {
            let user: UserResponse = try await apiClient.request("/profile")
            currentUser = user
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
}

// MARK: - Keychain Service

class KeychainService {
    static let shared = KeychainService()
    
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    
    var accessToken: String? {
        get { get(accessTokenKey) }
        set {
            if let value = newValue {
                set(value, forKey: accessTokenKey)
            } else {
                delete(accessTokenKey)
            }
        }
    }
    
    var refreshToken: String? {
        get { get(refreshTokenKey) }
        set {
            if let value = newValue {
                set(value, forKey: refreshTokenKey)
            } else {
                delete(refreshTokenKey)
            }
        }
    }
    
    private func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private func set(_ value: String, forKey key: String) {
        delete(key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value.data(using: .utf8)!
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func delete(_ key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
