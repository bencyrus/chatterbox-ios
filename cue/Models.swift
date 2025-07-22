//
//  Models.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation

/// Data model representing a conversation prompt with follow-up questions
struct Prompt: Codable, Identifiable, Hashable {
    let id: Int
    let main_prompt: String
    let followup_1: String
    let followup_2: String
    let followup_3: String
    let followup_4: String
}

/// User progress for a specific prompt
struct UserProgress: Codable {
    let promptId: Int
    let isCompleted: Bool
    let completedAt: Date?
} 