//
//  LanguagePicker.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import SwiftUI

struct LanguagePicker: View {
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        HStack {
            Text(languageManager.localizedText(
                english: "Language",
                french: "Langue"
            ))
            .font(.body)
            .foregroundColor(.primary)
            
            Spacer()
            
            Menu {
                ForEach(LanguageManager.Language.allCases, id: \.self) { language in
                    Button(action: {
                        languageManager.setLanguage(language)
                    }) {
                        Text("\(language.flag) \(language.displayName)")
                            .font(.body)
                    }
                }
            } label: {
                HStack {
                    Text(languageManager.currentLanguage.flag)
                        .font(.title2)
                    Text(languageManager.currentLanguage.displayName)
                        .font(.body)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    LanguagePicker()
        .environmentObject(LanguageManager(apiService: NetworkManager(baseURL: "https://example.com/api/v1")))
        .padding()
} 