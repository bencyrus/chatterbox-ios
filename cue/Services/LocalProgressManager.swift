//
//  LocalProgressManager.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation

/// Manages local storage of prompt completion status per language
class LocalProgressManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let progressKey = "user_prompt_progress_v2" // Changed key to reset old data
    
    /// Create a unique key for prompt completion (promptId_language)
    private func makeKey(promptId: Int, language: String) -> String {
        return "\(promptId)_\(language)"
    }
    
    /// Get completion status for all prompts from local storage
    private func getLocalProgress() -> [String: Bool] {
        return userDefaults.object(forKey: progressKey) as? [String: Bool] ?? [:]
    }
    
    /// Check if a specific prompt is completed in a specific language
    func isPromptCompleted(_ promptId: Int, language: String) -> Bool {
        let progress = getLocalProgress()
        let key = makeKey(promptId: promptId, language: language)
        return progress[key] ?? false
    }
    
    /// Update local completion status for a prompt in a specific language
    func setPromptCompleted(_ promptId: Int, language: String, isCompleted: Bool) {
        var progress = getLocalProgress()
        let key = makeKey(promptId: promptId, language: language)
        progress[key] = isCompleted
        userDefaults.set(progress, forKey: progressKey)
    }
    
    /// Sync backend progress with local storage (backend wins)
    func syncWithBackendProgress(_ backendProgress: [UserProgress], language: String) {
        var progress = getLocalProgress()
        
        // Update local storage with backend data for this language
        for promptProgress in backendProgress {
            let key = makeKey(promptId: promptProgress.promptId, language: language)
            progress[key] = promptProgress.isCompleted
        }
        
        userDefaults.set(progress, forKey: progressKey)
    }
    
    /// Get all completed prompt IDs for a specific language
    func getCompletedPromptIds(for language: String) -> Set<Int> {
        let progress = getLocalProgress()
        let languageSuffix = "_\(language)"
        
        var completedIds: Set<Int> = []
        for (key, isCompleted) in progress {
            if isCompleted && key.hasSuffix(languageSuffix) {
                let promptIdString = key.replacingOccurrences(of: languageSuffix, with: "")
                if let promptId = Int(promptIdString) {
                    completedIds.insert(promptId)
                }
            }
        }
        return completedIds
    }
    
    /// Get completion count for a specific language
    func getCompletionCount(for language: String) -> Int {
        return getCompletedPromptIds(for: language).count
    }
    
    /// Clear all local progress (for testing or logout)
    func clearAllProgress() {
        userDefaults.removeObject(forKey: progressKey)
    }
    
    /// Clear progress for a specific language only
    func clearProgress(for language: String) {
        var progress = getLocalProgress()
        let languageSuffix = "_\(language)"
        
        // Remove all keys for this language
        let keysToRemove = progress.keys.filter { $0.hasSuffix(languageSuffix) }
        for key in keysToRemove {
            progress.removeValue(forKey: key)
        }
        
        userDefaults.set(progress, forKey: progressKey)
    }
} 