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
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        return UserData(
            preferredLanguage: "en",
            userId: "mock_user_123"
        )
    }
    
    func fetchPrompts(language: String) async -> [Prompt] {
        try? await Task.sleep(nanoseconds: 500_000_000)
        
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
    
    func fetchUserProgress() async -> [UserProgress] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // Mock some completed prompts
        return [
            UserProgress(promptId: 1, isCompleted: true, completedAt: Date()),
            UserProgress(promptId: 3, isCompleted: true, completedAt: Date().addingTimeInterval(-86400)),
            UserProgress(promptId: 5, isCompleted: false, completedAt: nil)
        ]
    }
    
    func updatePromptStatus(promptId: Int, isCompleted: Bool) async {
        try? await Task.sleep(nanoseconds: 200_000_000)
        print("📡 Updated prompt \(promptId) completion status to: \(isCompleted)")
    }
} 