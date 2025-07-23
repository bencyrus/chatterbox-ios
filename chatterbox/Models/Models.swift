//
//  Models.swift
//  chatterbox
//
//  Created by Ben Cyrus on 2025-07-22.
//

import Foundation

/// Data model representing a conversation prompt with follow-up questions
struct Prompt: Codable, Identifiable, Hashable {
    let id: Int
    let main_prompt: String
    let followups: [String]
}

/// User progress for a specific prompt
struct UserProgress: Codable {
    let promptId: Int
    let isCompleted: Bool
    let completedAt: Date?
}

// MARK: - Authentication Models

/// Request model for requesting login code
struct LoginCodeRequest: Codable {
    let email: String
}

/// Response model for login code request
struct LoginCodeResponse: Codable {
    let success: Bool
    let message: String
    let expiresAt: String
    let messageId: String?
}

/// Request model for verifying login code
struct VerifyLoginRequest: Codable {
    let email: String
    let code: String
}

/// Response model for login verification
struct VerifyLoginResponse: Codable {
    let success: Bool
    let message: String
    let token: String
    let expiresAt: String
    let account: Account
}

/// Response model for token verification
struct VerifyTokenResponse: Codable {
    let success: Bool
    let message: String
    let account: Account
}

/// User account information
struct Account: Codable {
    let accountId: Int
    let email: String
}

/// General API error response
struct APIError: Codable {
    let error: String
    let message: String
    let timestamp: String?
}

/// Authentication state
enum AuthState {
    case idle
    case requestingCode
    case codeRequested(email: String)
    case verifyingCode
    case authenticated(Account)
    case error(String)
} 