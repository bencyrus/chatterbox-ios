//
//  ContentView.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import SwiftUI

/// Main app view with tab navigation between Home and Settings
struct ContentView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(languageManager.localizedText(
                        english: "Home",
                        french: "Accueil"
                    ))
                }
                .tag(0)
                .environmentObject(languageManager)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text(languageManager.localizedText(
                        english: "Settings",
                        french: "Paramètres"
                    ))
                }
                .tag(1)
                .environmentObject(languageManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LanguageManager(apiService: NetworkManager(baseURL: "https://example.com/api/v1")))
}
