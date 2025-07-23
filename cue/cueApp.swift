//
//  cueApp.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import SwiftUI

/// Main app entry point
@main
struct cueApp: App {
    @StateObject private var authManager = AuthManager(
        authService: AuthService(baseURL: AppConfig.apiURL)
    )
    @StateObject private var languageManager = LanguageManager(
        apiService: NetworkManager(baseURL: AppConfig.apiURL)
    )
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                        .environmentObject(languageManager)
                        .environmentObject(authManager)
                } else {
                    LoginView()
                        .environmentObject(languageManager)
                        .environmentObject(authManager)
                }
            }
            .onAppear {
                AppConfig.validateConfiguration()
                setupAPIServiceAuth()
            }
            .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
                setupAPIServiceAuth()
            }
        }
    }
    
    /// Setup API service authentication when auth state changes
    private func setupAPIServiceAuth() {
        let authHeader = authManager.getAuthorizationHeader()
        languageManager.setAuthorizationHeader(authHeader)
    }
}
