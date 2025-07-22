//
//  LocalProgressManager.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation

/// Manages local storage of prompt completion status
class LocalProgressManager: ObservableObject {
    private let userDefaults = UserDefaults.standard
    private let progressKey = "user_prompt_progress"
    
    /// Get completion status for all prompts from local storage
    func getLocalProgress() -> [Int: Bool] {
        return userDefaults.object(forKey: progressKey) as? [Int: Bool] ?? [:]
    }
    
    /// Check if a specific prompt is completed locally
    func isPromptCompleted(_ promptId: Int) -> Bool {
        let progress = getLocalProgress()
        return progress[promptId] ?? false
    }
    
    /// Update local completion status for a prompt
    func setPromptCompleted(_ promptId: Int, isCompleted: Bool) {
        var progress = getLocalProgress()
        progress[promptId] = isCompleted
        userDefaults.set(progress, forKey: progressKey)
    }
    
    /// Sync backend progress with local storage (backend wins)
    func syncWithBackendProgress(_ backendProgress: [UserProgress]) {
        var localProgress = getLocalProgress()
        
        // Update local storage with backend data
        for progress in backendProgress {
            localProgress[progress.promptId] = progress.isCompleted
        }
        
        userDefaults.set(localProgress, forKey: progressKey)
    }
    
    /// Get all completed prompt IDs
    func getCompletedPromptIds() -> Set<Int> {
        let progress = getLocalProgress()
        return Set(progress.compactMap { key, value in value ? key : nil })
    }
    
    /// Clear all local progress (for testing or logout)
    func clearAllProgress() {
        userDefaults.removeObject(forKey: progressKey)
    }
} 