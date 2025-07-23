//
//  HomeView.swift
//  chatterbox
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
                            PromptCard(
                                prompt: prompt,
                                isCompleted: languageManager.isPromptCompleted(prompt.id)
                            )
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
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 0 {
                navigationPath = NavigationPath()
            }
        }
    }
}

struct PromptCard: View {
    let prompt: Prompt
    let isCompleted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(prompt.main_prompt)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                Spacer()
                
                // Completion badge
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCompleted ? Color(.systemGray6) : Color(.systemBackground))
                .stroke(isCompleted ? Color.green.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .overlay(
            // Completed indicator stripe
            isCompleted ? 
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 2)
            : nil
        )
    }
}

struct PromptDetailView: View {
    @EnvironmentObject var languageManager: LanguageManager
    let prompt: Prompt
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Completion status banner
                if languageManager.isPromptCompleted(prompt.id) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(languageManager.localizedText(
                            english: "Completed",
                            french: "Terminé"
                        ))
                        .font(.headline)
                        .foregroundColor(.green)
                        
                        Spacer()
                        
                        Button(action: {
                            languageManager.togglePromptCompletion(prompt.id)
                        }) {
                            Text(languageManager.localizedText(
                                english: "Mark as Incomplete",
                                french: "Marquer comme Incomplet"
                            ))
                            .font(.caption)
                            .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                
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
                
                // Mark as completed button
                if !languageManager.isPromptCompleted(prompt.id) {
                    Button(action: {
                        languageManager.togglePromptCompletion(prompt.id)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text(languageManager.localizedText(
                                english: "Mark as Completed",
                                french: "Marquer comme Terminé"
                            ))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                }
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
                HStack {
                    if languageManager.isPromptCompleted(prompt.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    Text(languageManager.currentLanguage.flag)
                        .font(.title2)
                }
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
            .environmentObject(LanguageManager(apiService: NetworkManager(baseURL: "https://example.com/api/v1")))
    }
} 