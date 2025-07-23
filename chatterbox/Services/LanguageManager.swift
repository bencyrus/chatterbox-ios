//
//  LanguageManager.swift
//  chatterbox
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation
import SwiftUI

/// Manages app language state and data from API
class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language = .english
    @Published var prompts: [Prompt] = []
    
    private let apiService: APIService
    private let progressManager = LocalProgressManager()
    
    enum Language: String, CaseIterable {
        case english = "en"
        case french = "fr"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .french: return "Français"
            }
        }
        
        var flag: String {
            switch self {
            case .english: return "🇺🇸"
            case .french: return "🇫🇷"
            }
        }
    }
    
    init(apiService: APIService) {
        self.apiService = apiService
        Task {
            await loadInitialData()
        }
    }
    
    /// Returns localized text based on current language setting
    func localizedText(english: String, french: String) -> String {
        switch currentLanguage {
        case .english: return english
        case .french: return french
        }
    }
    
    /// Check if a prompt is completed in the current language
    func isPromptCompleted(_ promptId: Int) -> Bool {
        return progressManager.isPromptCompleted(promptId, language: currentLanguage.rawValue)
    }
    
    /// Toggle completion status for a prompt in the current language
    @MainActor
    func togglePromptCompletion(_ promptId: Int) {
        let currentStatus = progressManager.isPromptCompleted(promptId, language: currentLanguage.rawValue)
        let newStatus = !currentStatus
        
        // Update local storage immediately for responsiveness
        progressManager.setPromptCompleted(promptId, language: currentLanguage.rawValue, isCompleted: newStatus)
        
        // Update backend in background
        Task {
            await apiService.updatePromptStatus(promptId: promptId, language: currentLanguage.rawValue, isCompleted: newStatus)
        }
        
        // Trigger UI update
        objectWillChange.send()
    }
    
    /// Get completion count for current language
    func getCompletionCount() -> Int {
        return progressManager.getCompletionCount(for: currentLanguage.rawValue)
    }
    
    /// Set authorization header for API requests
    func setAuthorizationHeader(_ header: String?) {
        apiService.setAuthorizationHeader(header)
    }
    
    /// Load user data and prompts from backend
    @MainActor
    private func loadInitialData() async {
        print("🚀 Loading initial data...")
        
        // 1. Get user's language preference from backend
        print("📱 Fetching user data...")
        let userData = await apiService.fetchUserData()
        if let backendLanguage = Language(rawValue: userData.preferredLanguage) {
            self.currentLanguage = backendLanguage
            print("🌍 Set language to: \(backendLanguage.displayName)")
        } else {
            print("⚠️ Using default language: \(currentLanguage.displayName)")
        }
        
        // 2. Load prompts for the language
        print("📚 Fetching prompts for language: \(currentLanguage.rawValue)...")
        let prompts = await apiService.fetchPrompts(language: currentLanguage.rawValue)
        self.prompts = prompts
        print("✅ Loaded \(prompts.count) prompts")
        
        // 3. Sync progress from backend for this language
        print("📊 Syncing progress...")
        let backendProgress = await apiService.fetchUserProgress(language: currentLanguage.rawValue)
        progressManager.syncWithBackendProgress(backendProgress, language: currentLanguage.rawValue)
        print("✅ Initial data loading complete")
    }
    
    /// Update language preference
    @MainActor
    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        
        currentLanguage = language
        print("🔄 Language changed to: \(language.displayName)")
        
        Task {
            // Update backend preference
            print("💾 Updating backend language preference...")
            await apiService.updateLanguagePreference(language: language.rawValue)
            
            // Load new prompts
            print("📚 Fetching prompts for new language: \(language.rawValue)...")
            let prompts = await apiService.fetchPrompts(language: language.rawValue)
            await MainActor.run {
                self.prompts = prompts
                print("✅ Updated to \(prompts.count) prompts for \(language.displayName)")
            }
            
            // Sync progress for the new language
            print("📊 Syncing progress for new language...")
            let backendProgress = await apiService.fetchUserProgress(language: language.rawValue)
            await MainActor.run {
                progressManager.syncWithBackendProgress(backendProgress, language: language.rawValue)
                
                // Trigger UI update to reflect completion status for new language
                objectWillChange.send()
                print("✅ Language change complete")
            }
        }
    }
} 