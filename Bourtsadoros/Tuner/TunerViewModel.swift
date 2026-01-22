//
//  Tuner/TunerViewModel.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//
// Tuner/TunerViewModel.swift
import Foundation
import Combine

class TunerViewModel: ObservableObject {
    @Published var selectedInstrument: Instrument = .guitar
    @Published var currentFrequency: Double = 0
    @Published var currentNote: String = "A"
    @Published var targetNote: String = "A"
    @Published var needlePosition: CGFloat = 0
    @Published var isListening = false
    @Published var errorMessage: String?
    
    private let audioService = AudioInputService()
    private var cancellables = Set<AnyCancellable>()
    
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
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen for frequency updates
        audioService.$currentFrequency
            .receive(on: RunLoop.main)
            .sink { [weak self] frequency in
                self?.currentFrequency = frequency
                self?.updateNeedlePosition()
            }
            .store(in: &cancellables)
        
        audioService.$currentNote
            .receive(on: RunLoop.main)
            .sink { [weak self] note in
                self?.currentNote = note
            }
            .store(in: &cancellables)
        
        audioService.$isListening
            .receive(on: RunLoop.main)
            .assign(to: &$isListening)
        
        audioService.$errorMessage
            .receive(on: RunLoop.main)
            .assign(to: &$errorMessage)
        
        // When current note changes, update target note
        $currentNote
            .receive(on: RunLoop.main)
            .assign(to: &$targetNote)
    }
    
    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }
    
    func startListening() {
        audioService.startListening()
    }
    
    func stopListening() {
        audioService.stopListening()
    }
    
    private func updateNeedlePosition() {
        let targetFreq: Double
        
        if let string = currentStrings.first(where: { $0.note == targetNote }) {
            targetFreq = string.frequency
        } else {
            targetFreq = 440.0 // Default to A440
        }
        
        let maxOffset: CGFloat = 100
        
        if currentFrequency > 0 && targetFreq > 0 {
            let cents = 1200 * log2(currentFrequency / targetFreq)
            let normalized = cents / 50.0
            needlePosition = CGFloat(normalized) * maxOffset
        } else {
            needlePosition = 0
        }
        
        // Clamp to bounds
        needlePosition = min(max(needlePosition, -100), 100)
    }
    
    func isStringInTune(_ string: TuningString) -> Bool {
        guard currentFrequency > 0 else { return false }
        
        let frequencyDiff = abs(currentFrequency - string.frequency)
        let tolerance = 1.0
        
        return frequencyDiff < tolerance
    }
    
    // For testing/demo
    func testFrequency(_ frequency: Double, note: String) {
        audioService.simulateFrequency(frequency)
        targetNote = note
        updateNeedlePosition()
    }
}
