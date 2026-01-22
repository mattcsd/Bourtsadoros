//
//  AudioInputService.swift
//  Bourtsadoros
//
//  Created by kez542 on 22/1/26.
//

// Shared/Services/AudioInputService.swift
import AVFoundation
import Combine

class AudioInputService: ObservableObject {
    @Published var currentFrequency: Double = 0
    @Published var currentNote: String = "A"
    @Published var isListening = false
    @Published var errorMessage: String?
    
    private var audioEngine = AVAudioEngine()
    private var timer: Timer?
    
    func startListening() {
        // First, stop anything that might be running
        stopListening()
        
        // Request microphone permission if needed
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupAudioInput()
                } else {
                    self?.errorMessage = "Microphone permission denied. Please enable in Settings."
                    self?.setupSimulationMode()
                }
            }
        }
    }
    
    private func setupAudioInput() {
        do {
            // Setup audio session - THIS IS CRITICAL
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
            try audioSession.setActive(true)
            
            // Get the input node
            let inputNode = audioEngine.inputNode
            let inputFormat = inputNode.inputFormat(forBus: 0)
            
            // If inputFormat is invalid (happens sometimes), use a default format
            let recordingFormat: AVAudioFormat
            if inputFormat.sampleRate > 0 {
                recordingFormat = inputFormat
            } else {
                // Fallback to standard format
                recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
            }
            
            print("Using format: \(recordingFormat.sampleRate) Hz, \(recordingFormat.channelCount) channels")
            
            // Install tap with proper format
            inputNode.installTap(onBus: 0,
                               bufferSize: 1024,
                               format: recordingFormat) { [weak self] buffer, time in
                self?.processAudioBuffer(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            DispatchQueue.main.async {
                self.isListening = true
                self.errorMessage = nil
                print("Audio engine started successfully")
            }
            
        } catch {
            print("Failed to setup audio input: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to start microphone: \(error.localizedDescription)"
                self.setupSimulationMode()
            }
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // For demo purposes, we'll simulate frequency detection
        // In a real app, you'd implement actual pitch detection here
        
        let simulatedFreq = 440.0 + Double.random(in: -5...5) // Simulate around A440
        
        DispatchQueue.main.async {
            self.currentFrequency = simulatedFreq
            self.currentNote = self.frequencyToNote(simulatedFreq)
        }
    }
    
    private func setupSimulationMode() {
        // Fallback simulation when microphone isn't available
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.isListening else { return }
            
            // Simulate a frequency that changes over time
            let time = Date().timeIntervalSince1970
            let variation = sin(time) * 10.0
            let simulatedFreq = 440.0 + variation
            
            DispatchQueue.main.async {
                self.currentFrequency = simulatedFreq
                self.currentNote = self.frequencyToNote(simulatedFreq)
            }
        }
        
        DispatchQueue.main.async {
            self.isListening = true
            print("Running in simulation mode")
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.async {
            self.isListening = false
        }
    }
    
    private func frequencyToNote(_ frequency: Double) -> String {
        let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        guard frequency > 0 else { return "--" }
        
        let a4Index = 9 // A is index 9 (A440)
        let cents = 1200 * log2(frequency / 440.0)
        let semitones = cents / 100
        var noteIndex = (a4Index + Int(round(semitones))) % 12
        
        if noteIndex < 0 {
            noteIndex += 12
        }
        
        return notes[noteIndex]
    }
    
    // For manual testing
    func simulateFrequency(_ frequency: Double) {
        DispatchQueue.main.async {
            self.currentFrequency = frequency
            self.currentNote = self.frequencyToNote(frequency)
        }
    }
}
