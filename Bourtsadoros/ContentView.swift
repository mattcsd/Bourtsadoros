//
//  ContentView.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LoopPlayerView()
                .tabItem {
                    Label("Metronome", systemImage: "metronome")
                }
            
            TunerView()
                .tabItem {
                    Label("Tuner", systemImage: "tuningfork")
                }
        }
        .preferredColorScheme(.dark) // Force dark mode
        .accentColor(.blue) // Set accent color
    }
}
