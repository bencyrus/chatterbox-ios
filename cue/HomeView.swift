//
//  HomeView.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var selectedTab: Int
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(languageManager.prompts) { prompt in
                        NavigationLink(value: prompt) {
                            PromptCard(prompt: prompt)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle(languageManager.localizedText(
                english: "Prompts",
                french: "Sujets"
            ))
            .navigationDestination(for: Prompt.self) { prompt in
                PromptDetailView(prompt: prompt)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(languageManager.currentLanguage.flag)
                        .font(.title2)
                }
            }
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 0 {
                navigationPath = NavigationPath()
            }
        }
    }
}

struct PromptCard: View {
    let prompt: Prompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt.main_prompt)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PromptDetailView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let prompt: Prompt
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(prompt.main_prompt)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FollowUpQuestionView(question: prompt.followup_1)
                        FollowUpQuestionView(question: prompt.followup_2)
                        FollowUpQuestionView(question: prompt.followup_3)
                        FollowUpQuestionView(question: prompt.followup_4)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .padding()
        }
        .navigationTitle(languageManager.localizedText(
            english: "Prompt Details",
            french: "Détails du Sujet"
        ))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(languageManager.currentLanguage.flag)
                    .font(.title2)
            }
        }
    }
}

struct FollowUpQuestionView: View {
    let question: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
                .foregroundColor(.primary)
            
            Text(question)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(selectedTab: .constant(0))
            .environmentObject(LanguageManager())
    }
} 