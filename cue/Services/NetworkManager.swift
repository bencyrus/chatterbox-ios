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
    private var authorizationHeader: String?
    
    init(baseURL: String = "https://your-api-domain.com/api/v1") {
        self.baseURL = baseURL
    }
    
    // MARK: - Authentication
    
    func setAuthorizationHeader(_ header: String?) {
        self.authorizationHeader = header
    }
    
    func fetchUserData() async -> UserData {
        // Since backend doesn't have a /user endpoint, use local preferences
        let storedLanguage = UserDefaults.standard.string(forKey: "preferredLanguage") ?? "en"
        print("📱 Using local user data: language=\(storedLanguage)")
        return UserData(preferredLanguage: storedLanguage, userId: nil)
    }
    
    func fetchPrompts(language: String) async -> [Prompt] {
        // GET /prompts?language=en
        guard let url = URL(string: "\(baseURL)/prompts?language=\(language)") else {
            print("❌ Invalid URL for prompts")
            return []
        }
        
        var request = URLRequest(url: url)
        if let authHeader = authorizationHeader {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            print("🔐 Making authenticated request to: \(url)")
        } else {
            print("⚠️ Making unauthenticated request to: \(url)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check for HTTP errors
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 API Response: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("❌ API Error: \(httpResponse.statusCode)")
                    if let errorData = String(data: data, encoding: .utf8) {
                        print("Error response: \(errorData)")
                    }
                    return []
                }
            }
            
            // Debug: Print raw response
            if let responseString = String(data: data, encoding: .utf8) {
                print("📝 Raw API Response: \(responseString)")
            }
            
            // Try to decode as PromptsResponse (wrapped) first, then fallback to direct array
            if let promptsResponse = try? JSONDecoder().decode(PromptsResponse.self, from: data) {
                print("✅ Decoded as PromptsResponse: \(promptsResponse.prompts.count) prompts")
                return promptsResponse.prompts
            } else if let prompts = try? JSONDecoder().decode([Prompt].self, from: data) {
                print("✅ Decoded as direct array: \(prompts.count) prompts")
                return prompts
            } else {
                print("❌ Failed to decode prompts response")
                
                // Try to decode as backend format for debugging
                if let backendPrompts = try? JSONDecoder().decode([BackendPrompt].self, from: data) {
                    print("📊 Backend format detected: \(backendPrompts.count) prompts")
                    // Convert backend format to iOS format
                    return backendPrompts.compactMap { backendPrompt in
                        guard backendPrompt.followups.count >= 4 else {
                            print("⚠️ Prompt \(backendPrompt.id) has only \(backendPrompt.followups.count) followups")
                            return nil
                        }
                        return Prompt(
                            id: backendPrompt.id,
                            main_prompt: backendPrompt.main_prompt,
                            followup_1: backendPrompt.followups[0],
                            followup_2: backendPrompt.followups[1],
                            followup_3: backendPrompt.followups[2],
                            followup_4: backendPrompt.followups[3]
                        )
                    }
                }
                
                return []
            }
        } catch {
            print("❌ Network error fetching prompts: \(error)")
            return []
        }
    }
    
    func updateLanguagePreference(language: String) async {
        // Backend doesn't have user language preference endpoint yet
        // Store locally for now
        UserDefaults.standard.set(language, forKey: "preferredLanguage")
        print("💾 Stored language preference locally: \(language)")
    }
    
    func fetchUserProgress(language: String) async -> [UserProgress] {
        // Backend doesn't have user progress endpoints yet
        // Progress is managed locally
        print("📊 Using local progress data (no backend /user/progress endpoint)")
        return []
    }
    
    func updatePromptStatus(promptId: Int, language: String, isCompleted: Bool) async {
        // Backend doesn't have user progress endpoints yet
        // Progress is managed locally via LocalProgressManager
        print("💾 Progress stored locally: prompt \(promptId) = \(isCompleted)")
    }
} 