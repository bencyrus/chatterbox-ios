//
//  NetworkManager.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation

/// Simple production API service
class NetworkManager: APIService {
    private let baseURL: String
    
    init(baseURL: String = "https://your-api-domain.com/api/v1") {
        self.baseURL = baseURL
    }
    
    func fetchUserData() async -> UserData {
        guard let url = URL(string: "\(baseURL)/user"),
              let data = try? await URLSession.shared.data(from: url).0,
              let userData = try? JSONDecoder().decode(UserData.self, from: data) else {
            return UserData(preferredLanguage: "en", userId: nil)
        }
        return userData
    }
    
    func fetchPrompts(language: String) async -> [Prompt] {
        // GET /prompts?language=en
        guard let url = URL(string: "\(baseURL)/prompts?language=\(language)"),
              let data = try? await URLSession.shared.data(from: url).0,
              let prompts = try? JSONDecoder().decode([Prompt].self, from: data) else {
            return []
        }
        return prompts
    }
    
    func updateLanguagePreference(language: String) async {
        // PUT /user/language
        guard let url = URL(string: "\(baseURL)/user/language") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["language": language]
        request.httpBody = try? JSONEncoder().encode(body)
        
        _ = try? await URLSession.shared.data(for: request)
    }
    
    func fetchUserProgress() async -> [UserProgress] {
        guard let url = URL(string: "\(baseURL)/user/progress"),
              let data = try? await URLSession.shared.data(from: url).0,
              let progress = try? JSONDecoder().decode([UserProgress].self, from: data) else {
            return []
        }
        return progress
    }
    
    func updatePromptStatus(promptId: Int, isCompleted: Bool) async {
        guard let url = URL(string: "\(baseURL)/user/progress/\(promptId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["isCompleted": isCompleted, "completedAt": isCompleted ? Date() : nil] as [String: Any?]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        _ = try? await URLSession.shared.data(for: request)
    }
} 