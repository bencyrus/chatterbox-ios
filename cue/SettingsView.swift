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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    LanguagePicker()
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
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(LanguageManager())
} 