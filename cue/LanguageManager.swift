//
//  LanguageManager.swift
//  cue
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
    
    init(apiService: APIService = MockAPIService()) {
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
    
    /// Check if a prompt is completed
    func isPromptCompleted(_ promptId: Int) -> Bool {
        return progressManager.isPromptCompleted(promptId)
    }
    
    /// Toggle completion status for a prompt
    @MainActor
    func togglePromptCompletion(_ promptId: Int) {
        let currentStatus = progressManager.isPromptCompleted(promptId)
        let newStatus = !currentStatus
        
        // Update local storage immediately for responsiveness
        progressManager.setPromptCompleted(promptId, isCompleted: newStatus)
        
        // Update backend in background
        Task {
            await apiService.updatePromptStatus(promptId: promptId, isCompleted: newStatus)
        }
        
        // Trigger UI update
        objectWillChange.send()
    }
    
    /// Load user data and prompts from backend
    @MainActor
    private func loadInitialData() async {
        // 1. Get user's language preference from backend
        let userData = await apiService.fetchUserData()
        if let backendLanguage = Language(rawValue: userData.preferredLanguage) {
            self.currentLanguage = backendLanguage
        }
        
        // 2. Load prompts for the language
        let prompts = await apiService.fetchPrompts(language: currentLanguage.rawValue)
        self.prompts = prompts
        
        // 3. Sync progress from backend
        let backendProgress = await apiService.fetchUserProgress()
        progressManager.syncWithBackendProgress(backendProgress)
    }
    
    /// Update language preference
    @MainActor
    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        
        currentLanguage = language
        
        Task {
            // Update backend preference
            await apiService.updateLanguagePreference(language: language.rawValue)
            
            // Load new prompts
            let prompts = await apiService.fetchPrompts(language: language.rawValue)
            await MainActor.run {
                self.prompts = prompts
            }
        }
    }
} 