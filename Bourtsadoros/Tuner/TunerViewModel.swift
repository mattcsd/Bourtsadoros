//
//  Tuner/TunerViewModel.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//

import Foundation
import Combine

class TunerViewModel: ObservableObject {
    @Published var selectedInstrument: Instrument = .guitar
    @Published var currentFrequency: Double = 0
    @Published var targetNote: String = "A"
    @Published var needlePosition: CGFloat = 0
    
    // Guitar strings
    let guitarStrings: [TuningString] = [
        TuningString(note: "E", frequency: 329.63),
        TuningString(note: "B", frequency: 246.94),
        TuningString(note: "G", frequency: 196.00),
        TuningString(note: "D", frequency: 146.83),
        TuningString(note: "A", frequency: 110.00),
        TuningString(note: "E", frequency: 82.41)
    ]
    
    // Bass strings
    let bassStrings: [TuningString] = [
        TuningString(note: "G", frequency: 98.0),
        TuningString(note: "D", frequency: 73.42),
        TuningString(note: "A", frequency: 55.0),
        TuningString(note: "E", frequency: 41.20)
    ]
    
    var currentStrings: [TuningString] {
        selectedInstrument == .guitar ? guitarStrings : bassStrings
    }
    
    func updateFrequency(_ frequency: Double, targetNote: String) {
        currentFrequency = frequency
        self.targetNote = targetNote
        updateNeedlePosition()
    }
    
    private func updateNeedlePosition() {
        let baseFreq: Double = 440.0
        let maxOffset: CGFloat = 100
        
        let cents = 1200 * log2(currentFrequency / baseFreq)
        let normalized = cents / 50.0
        let offset = CGFloat(normalized) * maxOffset
        
        needlePosition = max(-maxOffset, min(maxOffset, offset))
    }
    
    func isStringInTune(_ string: TuningString) -> Bool {
        guard let targetFreq = currentStrings.first(where: { $0.note == string.note })?.frequency else {
            return false
        }
        
        return abs(currentFrequency - targetFreq) < 1.0
    }
    
    // For testing/demo
    func testFrequency(_ frequency: Double, note: String) {
        updateFrequency(frequency, targetNote: note)
    }
}
