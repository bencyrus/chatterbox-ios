//
//  SettingsView.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import SwiftUI

/// Settings view with language selection and other preferences
struct SettingsView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var authManager: AuthManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // User Account Section
                VStack(spacing: 16) {
                    Text(languageManager.localizedText(
                        english: "Account",
                        french: "Compte"
                    ))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let account = authManager.getCurrentAccount() {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(account.email)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    
                                    Text(languageManager.localizedText(
                                        english: "Signed in",
                                        french: "Connecté"
                                    ))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            Button(action: {
                                showingLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text(languageManager.localizedText(
                                        english: "Sign Out",
                                        french: "Se Déconnecter"
                                    ))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Language Section
                VStack(spacing: 16) {
                    Text(languageManager.localizedText(
                        english: "Language",
                        french: "Langue"
                    ))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LanguagePicker()
                }
                .padding(.horizontal)
                
                // App Information
                VStack(spacing: 8) {
                    Text(languageManager.localizedText(
                        english: "App Version",
                        french: "Version de l'App"
                    ))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Text("\(AppConfig.appVersion) (\(AppConfig.buildNumber))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle(languageManager.localizedText(
                english: "Settings",
                french: "Paramètres"
            ))
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                languageManager.localizedText(
                    english: "Sign Out",
                    french: "Se Déconnecter"
                ),
                isPresented: $showingLogoutAlert
            ) {
                Button(
                    languageManager.localizedText(
                        english: "Cancel",
                        french: "Annuler"
                    ),
                    role: .cancel
                ) { }
                
                Button(
                    languageManager.localizedText(
                        english: "Sign Out",
                        french: "Se Déconnecter"
                    ),
                    role: .destructive
                ) {
                    Task {
                        await authManager.logout()
                    }
                }
            } message: {
                Text(languageManager.localizedText(
                    english: "Are you sure you want to sign out?",
                    french: "Êtes-vous sûr de vouloir vous déconnecter ?"
                ))
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager(apiService: NetworkManager(baseURL: "https://example.com/api/v1")))
        .environmentObject(AuthManager(authService: AuthService(baseURL: "https://example.com/api/v1")))
} 