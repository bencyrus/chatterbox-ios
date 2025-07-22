//
//  cueApp.swift
//  cue
//
//  Created by Ben Cyrus on 2025-07-22.
//

import SwiftUI

/// Main app entry point
@main
struct cueApp: App {
    @StateObject private var languageManager = LanguageManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(languageManager)
        }
    }
}
