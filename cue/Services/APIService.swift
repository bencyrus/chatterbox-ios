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
    func fetchUserProgress() async -> [UserProgress]
    func updatePromptStatus(promptId: Int, isCompleted: Bool) async
}

/// User data from backend
struct UserData: Codable {
    let preferredLanguage: String
    let userId: String?
} 