//
//  LoginView.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import SwiftUI

/// Main login view that handles the authentication flow
struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text(languageManager.localizedText(
                        english: "Welcome to Cue",
                        french: "Bienvenue dans Cue"
                    ))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                    Text(languageManager.localizedText(
                        english: "Sign in to access your conversation prompts",
                        french: "Connectez-vous pour accéder à vos sujets de conversation"
                    ))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Auth content based on state
                Group {
                    switch authManager.authState {
                    case .idle, .error:
                        EmailEntryView()
                    case .requestingCode:
                        LoadingView(message: languageManager.localizedText(
                            english: "Sending code...",
                            french: "Envoi du code..."
                        ))
                    case .codeRequested(let email):
                        CodeVerificationView(email: email)
                    case .verifyingCode:
                        LoadingView(message: languageManager.localizedText(
                            english: "Verifying code...",
                            french: "Vérification du code..."
                        ))
                    case .authenticated:
                        // This should not be shown as authenticated users see main app
                        EmptyView()
                    }
                }
                
                // Error display
                if case .error(let message) = authManager.authState {
                    ErrorView(message: message)
                }
                
                Spacer()
                
                // Language Picker
                VStack(spacing: 8) {
                    Text(languageManager.localizedText(
                        english: "Language / Langue",
                        french: "Langue / Language"
                    ))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(LanguageManager.Language.allCases, id: \.self) { language in
                            Button(action: {
                                languageManager.setLanguage(language)
                            }) {
                                HStack(spacing: 4) {
                                    Text(language.flag)
                                        .font(.body)
                                    Text(language.displayName)
                                        .font(.caption)
                                        .fontWeight(languageManager.currentLanguage == language ? .semibold : .regular)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    languageManager.currentLanguage == language ? 
                                    Color.blue.opacity(0.2) : Color.clear
                                )
                                .cornerRadius(8)
                            }
                            .foregroundColor(languageManager.currentLanguage == language ? .blue : .secondary)
                        }
                    }
                }
                .padding(.bottom, 20)
                
                // Footer
                Text(languageManager.localizedText(
                    english: "A verification code will be sent to your email",
                    french: "Un code de vérification sera envoyé à votre email"
                ))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
        }
    }
}

/// Email entry view
struct EmailEntryView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var email = ""
    @FocusState private var emailFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(languageManager.localizedText(
                    english: "Email Address",
                    french: "Adresse Email"
                ))
                .font(.headline)
                
                TextField(
                    languageManager.localizedText(
                        english: "Enter your email",
                        french: "Entrez votre email"
                    ),
                    text: $email
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($emailFieldFocused)
                .onSubmit {
                    if !email.isEmpty {
                        Task {
                            await authManager.requestLoginCode(email: email)
                        }
                    }
                }
            }
            
            Button(action: {
                Task {
                    await authManager.requestLoginCode(email: email)
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(languageManager.localizedText(
                        english: "Send Code",
                        french: "Envoyer le Code"
                    ))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(email.isEmpty || authManager.isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(email.isEmpty || authManager.isLoading)
        }
        .onAppear {
            emailFieldFocused = true
        }
    }
}

/// Code verification view
struct CodeVerificationView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var languageManager: LanguageManager
    let email: String
    
    @State private var code = ""
    @FocusState private var codeFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text(languageManager.localizedText(
                    english: "Check your email",
                    french: "Vérifiez votre email"
                ))
                .font(.title2)
                .fontWeight(.semibold)
                
                Text(languageManager.localizedText(
                    english: "We sent a 6-digit code to:",
                    french: "Nous avons envoyé un code à 6 chiffres à :"
                ))
                .font(.body)
                .foregroundColor(.secondary)
                
                Text(email)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(languageManager.localizedText(
                    english: "Verification Code",
                    french: "Code de Vérification"
                ))
                .font(.headline)
                
                TextField(
                    languageManager.localizedText(
                        english: "000000",
                        french: "000000"
                    ),
                    text: $code
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .focused($codeFieldFocused)
                .multilineTextAlignment(.center)
                .font(.title3)
                .onChange(of: code) { _, newValue in
                    // Limit to 6 digits
                    if newValue.count > 6 {
                        code = String(newValue.prefix(6))
                    }
                    
                    // Auto-submit when 6 digits are entered
                    if newValue.count == 6 {
                        Task {
                            await authManager.verifyLoginCode(email: email, code: newValue)
                        }
                    }
                }
            }
            
            Button(action: {
                Task {
                    await authManager.verifyLoginCode(email: email, code: code)
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(languageManager.localizedText(
                        english: "Verify Code",
                        french: "Vérifier le Code"
                    ))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(code.count != 6 || authManager.isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(code.count != 6 || authManager.isLoading)
            
            // Back button
            Button(action: {
                authManager.resetState()
            }) {
                Text(languageManager.localizedText(
                    english: "Use different email",
                    french: "Utiliser un autre email"
                ))
                .foregroundColor(.blue)
            }
            .padding(.top, 8)
        }
        .onAppear {
            codeFieldFocused = true
        }
    }
}

/// Loading view for auth operations
struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.2)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(height: 100)
    }
}

/// Error view for auth errors
struct ErrorView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager(authService: AuthService(baseURL: "https://example.com/api/v1")))
        .environmentObject(LanguageManager(apiService: NetworkManager(baseURL: "https://example.com/api/v1")))
} 