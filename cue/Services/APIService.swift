//
//  APIService.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation

/// Simple API service protocol
protocol APIService {
    func fetchUserData() async -> UserData
    func fetchPrompts(language: String) async -> [Prompt]
    func updateLanguagePreference(language: String) async
    func fetchUserProgress(language: String) async -> [UserProgress]
    func updatePromptStatus(promptId: Int, language: String, isCompleted: Bool) async
    
    // Authentication related
    func setAuthorizationHeader(_ header: String?)
}

/// User data from backend
struct UserData: Codable {
    let preferredLanguage: String
    let userId: String?
}

/// API response wrapper for prompts
struct PromptsResponse: Codable {
    let prompts: [Prompt]
} 