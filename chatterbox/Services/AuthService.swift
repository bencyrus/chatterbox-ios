//
//  AuthService.swift
//  chatterbox
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation
import Security

/// Service for handling authentication operations
class AuthService: ObservableObject {
    
    // MARK: - Properties
    
    private let baseURL: String
    private let keychainService = "com.chatterbox.app"
    private let tokenKey = "auth_token"
    private let accountKey = "user_account"
    
    // MARK: - Initialization
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    // MARK: - Public Methods
    
    /// Request login code via email
    /// - Parameter email: User's email address
    /// - Returns: LoginCodeResponse or throws error
    func requestLoginCode(email: String) async throws -> LoginCodeResponse {
        guard let url = URL(string: "\(baseURL)/auth/request-login") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = LoginCodeRequest(email: email)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let error = try? JSONDecoder().decode(APIError.self, from: data)
            throw AuthError.serverError(error?.message ?? "Failed to request login code")
        }
        
        return try JSONDecoder().decode(LoginCodeResponse.self, from: data)
    }
    
    /// Verify login code and get JWT token
    /// - Parameters:
    ///   - email: User's email address
    ///   - code: 6-digit verification code
    /// - Returns: VerifyLoginResponse or throws error
    func verifyLoginCode(email: String, code: String) async throws -> VerifyLoginResponse {
        guard let url = URL(string: "\(baseURL)/auth/verify-login") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = VerifyLoginRequest(email: email, code: code)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let error = try? JSONDecoder().decode(APIError.self, from: data)
            throw AuthError.serverError(error?.message ?? "Failed to verify login code")
        }
        
        let loginResponse = try JSONDecoder().decode(VerifyLoginResponse.self, from: data)
        
        // Store token and account in keychain
        try storeToken(loginResponse.token)
        try storeAccount(loginResponse.account)
        
        return loginResponse
    }
    
    /// Verify stored JWT token
    /// - Returns: VerifyTokenResponse or throws error
    func verifyToken() async throws -> VerifyTokenResponse {
        guard let token = getStoredToken() else {
            throw AuthError.noTokenStored
        }
        
        guard let url = URL(string: "\(baseURL)/auth/verify") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            // Token is invalid, clear stored data
            clearStoredAuth()
            let error = try? JSONDecoder().decode(APIError.self, from: data)
            throw AuthError.tokenExpired(error?.message ?? "Token verification failed")
        }
        
        return try JSONDecoder().decode(VerifyTokenResponse.self, from: data)
    }
    
    /// Logout user (clear stored token)
    func logout() async throws {
        // Optionally call backend logout endpoint
        if let token = getStoredToken() {
            try await callLogoutEndpoint(token: token)
        }
        
        // Clear stored authentication data
        clearStoredAuth()
    }
    
    /// Get stored JWT token
    /// - Returns: Token string if available
    func getStoredToken() -> String? {
        return getFromKeychain(key: tokenKey)
    }
    
    /// Get stored user account
    /// - Returns: Account object if available
    func getStoredAccount() -> Account? {
        guard let data = getFromKeychain(key: accountKey)?.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(Account.self, from: data)
    }
    
    /// Check if user is authenticated
    /// - Returns: True if valid token exists
    func isAuthenticated() -> Bool {
        return getStoredToken() != nil
    }
    
    /// Get authorization header for API requests
    /// - Returns: Authorization header value
    func getAuthorizationHeader() -> String? {
        guard let token = getStoredToken() else {
            return nil
        }
        return "Bearer \(token)"
    }
    
    // MARK: - Private Methods
    
    private func callLogoutEndpoint(token: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/logout") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        _ = try? await URLSession.shared.data(for: request)
    }
    
    private func storeToken(_ token: String) throws {
        try storeInKeychain(key: tokenKey, value: token)
    }
    
    private func storeAccount(_ account: Account) throws {
        let data = try JSONEncoder().encode(account)
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        try storeInKeychain(key: accountKey, value: jsonString)
    }
    
    private func clearStoredAuth() {
        deleteFromKeychain(key: tokenKey)
        deleteFromKeychain(key: accountKey)
    }
    
    // MARK: - Keychain Helpers
    
    private func storeInKeychain(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw AuthError.keychainError
        }
        
        // Delete existing item if it exists
        deleteFromKeychain(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw AuthError.keychainError
        }
    }
    
    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return nil
    }
    
    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case invalidURL
    case serverError(String)
    case noTokenStored
    case tokenExpired(String)
    case keychainError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .serverError(let message):
            return message
        case .noTokenStored:
            return "No authentication token stored"
        case .tokenExpired(let message):
            return message
        case .keychainError:
            return "Keychain storage error"
        case .networkError:
            return "Network connection error"
        }
    }
} 