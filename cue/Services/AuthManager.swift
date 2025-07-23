//
//  AuthManager.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation
import SwiftUI

/// Main authentication manager for the app
@MainActor
class AuthManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var authState: AuthState = .idle
    @Published var isAuthenticating = false
    @Published var currentAccount: Account?
    
    // MARK: - Private Properties
    
    private let authService: AuthService
    
    // MARK: - Computed Properties
    
    var isAuthenticated: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }
    
    var isLoading: Bool {
        return isAuthenticating
    }
    
    // MARK: - Initialization
    
    init(authService: AuthService) {
        self.authService = authService
        
        // Check for existing authentication on startup
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Request login code for email
    func requestLoginCode(email: String) async {
        guard !email.isEmpty, email.contains("@") else {
            authState = .error("Please enter a valid email address")
            return
        }
        
        isAuthenticating = true
        authState = .requestingCode
        
        do {
            _ = try await authService.requestLoginCode(email: email)
            authState = .codeRequested(email: email)
        } catch {
            authState = .error(error.localizedDescription)
        }
        
        isAuthenticating = false
    }
    
    /// Verify login code and authenticate
    func verifyLoginCode(email: String, code: String) async {
        guard !code.isEmpty, code.count == 6 else {
            authState = .error("Please enter a valid 6-digit code")
            return
        }
        
        isAuthenticating = true
        authState = .verifyingCode
        
        do {
            let response = try await authService.verifyLoginCode(email: email, code: code)
            currentAccount = response.account
            authState = .authenticated(response.account)
        } catch {
            authState = .error(error.localizedDescription)
        }
        
        isAuthenticating = false
    }
    
    /// Logout user
    func logout() async {
        isAuthenticating = true
        
        do {
            try await authService.logout()
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
        
        currentAccount = nil
        authState = .idle
        isAuthenticating = false
    }
    
    /// Reset authentication state
    func resetState() {
        authState = .idle
        isAuthenticating = false
    }
    
    /// Check if user is already authenticated
    func checkAuthenticationStatus() async {
        // Check if we have stored credentials
        if authService.isAuthenticated() {
            do {
                let response = try await authService.verifyToken()
                currentAccount = response.account
                authState = .authenticated(response.account)
            } catch {
                // Token is invalid, clear stored data
                currentAccount = nil
                authState = .idle
            }
        } else {
            authState = .idle
        }
    }
    
    /// Get authorization header for API requests
    func getAuthorizationHeader() -> String? {
        return authService.getAuthorizationHeader()
    }
    
    /// Get current user account
    func getCurrentAccount() -> Account? {
        return currentAccount ?? authService.getStoredAccount()
    }
} 