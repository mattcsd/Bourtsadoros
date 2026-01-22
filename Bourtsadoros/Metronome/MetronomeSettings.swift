//
//  Metronome/MetronomeModel.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//


import Foundation

struct MetronomeSettings {
    var bpm: Double
    var beatsPerMeasure: Int
    var accentFirstBeat: Bool
    
    static let `default` = MetronomeSettings(
        bpm: 120,
        beatsPerMeasure: 4,
        accentFirstBeat: true
    )
}
