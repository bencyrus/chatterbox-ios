//
//  MockAPIService.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation

/// Simple mock API service
class MockAPIService: APIService {
    
    func fetchUserData() async -> UserData {
        // Simulate small delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock user data - backend will override language preference
        return UserData(
            preferredLanguage: "en", // Backend always wins
            userId: "mock_user_123"
        )
    }
    
    func fetchPrompts(language: String) async -> [Prompt] {
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Load from local JSON (simulating API response)
        guard let url = Bundle.main.url(forResource: language, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let prompts = try? JSONDecoder().decode([Prompt].self, from: data) else {
            return []
        }
        
        return prompts
    }
    
    func updateLanguagePreference(language: String) async {
        try? await Task.sleep(nanoseconds: 200_000_000)
        print("📡 Updated language preference to: \(language)")
    }
} 