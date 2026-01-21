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
                    Label("Bourtsa", systemImage: "repeat.circle.fill")
                }
            
            MetronomeView()
                .tabItem {
                    Label("Metronome", systemImage: "metronome.fill")
                }
            
            TunerView()
                .tabItem {
                    Label("Tuner", systemImage: "tuningfork")
                }
        }
        .preferredColorScheme(.dark)
        .accentColor(.blue)
    }
}
