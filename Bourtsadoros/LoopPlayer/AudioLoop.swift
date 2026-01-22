//
//  LoopPlayer/LoopPlayerModel.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//


import Foundation

struct AudioLoop {
    let name: String
    let fileName: String
    let baseBPM: Double
    
    static let bourtsadoros = AudioLoop(
        name: "La Bourtsadoros",
        fileName: "la_bourtsadoros",
        baseBPM: 120
    )
}
