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
    @StateObject private var languageManager = LanguageManager(
        apiService: AppConfiguration.current.apiService
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(languageManager)
        }
    }
}

/// App configuration for API service selection
struct AppConfiguration {
    let apiService: APIService
    
    static let current = AppConfiguration()
    
    private init() {
        // 🔧 SWITCH BETWEEN MOCK AND PRODUCTION API HERE
        #if DEBUG
        // Use mock API in debug builds
        self.apiService = MockAPIService()
        #else
        // Use real API in release builds
        self.apiService = NetworkManager(baseURL: "https://your-api-domain.com/api/v1")
        #endif
        
        // 🚧 FOR TESTING: Force mock API even in release
        // self.apiService = MockAPIService()
        
        // 🚀 FOR PRODUCTION: Force real API with your domain
        // self.apiService = NetworkManager(baseURL: "https://your-api-domain.com/api/v1")
    }
}
