//
//  AppConfig.swift
//  chatterbox
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation

/// App configuration and settings
struct AppConfig {
    
    // MARK: - API Configuration
    
    /// API base URL
    static let apiURL = "https://chatterbox-express-625901299681.europe-west1.run.app/api/v1"
    
    // MARK: - App Information
    
    /// App version information
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    /// Build number
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Bundle identifier
    static var bundleIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.chatterbox.app"
    }
    
    // MARK: - Security Settings
    
    /// Keychain service identifier
    static let keychainService = "com.chatterbox.app.auth"
    
    // MARK: - API Timeouts
    
    /// Default request timeout
    static let requestTimeout: TimeInterval = 30
    
    /// Authentication request timeout (longer for email delivery)
    static let authRequestTimeout: TimeInterval = 60
}

// MARK: - Configuration Validation

extension AppConfig {
    
    /// Validate the current configuration
    static func validateConfiguration() {
        // Validate API URL format
        guard URL(string: apiURL) != nil else {
            fatalError("Invalid API URL configuration: \(apiURL)")
        }
        
        print("🔧 Chatterbox App - Version \(appVersion) (\(buildNumber))")
        print("🌐 API: \(apiURL)")
    }
} 