//
//  LanguageManager.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation
import SwiftUI

/// Manages app language state and localization
class LanguageManager: ObservableObject {
    @Published var currentLanguage: Language = .english
    @Published var prompts: [Prompt] = []
    
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
    
    init() {
        loadPrompts()
    }
    
    /// Returns localized text based on current language setting
    func localizedText(english: String, french: String) -> String {
        switch currentLanguage {
        case .english: return english
        case .french: return french
        }
    }
    
    /// Loads prompts from JSON file for current language
    private func loadPrompts() {
        let fileName = currentLanguage.rawValue
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decodedPrompts = try? JSONDecoder().decode([Prompt].self, from: data) else {
            print("Failed to load prompts for language: \(currentLanguage.rawValue)")
            return
        }
        
        DispatchQueue.main.async {
            self.prompts = decodedPrompts
        }
    }
    
    /// Updates the current language and reloads prompts
    func setLanguage(_ language: Language) {
        currentLanguage = language
        loadPrompts()
    }
} 