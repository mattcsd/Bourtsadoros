//
//  Metronome/MetronomeViewModel.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//


import Foundation
import AVFoundation
import Combine

class MetronomeViewModel: ObservableObject {
    @Published var settings = MetronomeSettings.default
    @Published var isPlaying = false
    @Published var beatNumber = 0
    @Published var progress: CGFloat = 0
    
    private var metronomePlayer: AVAudioPlayer?
    private var accentPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var animationTimer: Timer?
    
    let minBPM: Double = 40
    let maxBPM: Double = 240
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Load custom click sounds from bundle
            if let clickURL = Bundle.main.url(forResource: "metronome", withExtension: "wav") {
                metronomePlayer = try AVAudioPlayer(contentsOf: clickURL)
                metronomePlayer?.prepareToPlay()
                metronomePlayer?.volume = 0.7
            }
            
            if let accentURL = Bundle.main.url(forResource: "metronome_accent", withExtension: "wav") {
                accentPlayer = try AVAudioPlayer(contentsOf: accentURL)
                accentPlayer?.prepareToPlay()
                accentPlayer?.volume = 1.0
            }
            
        } catch {
            print("Error setting up audio: \(error)")
            
            // Fallback: Create synthetic click sound if files not found
            createSyntheticSounds()
        }
    }
    
    // Fallback method if audio files aren't found
    private func createSyntheticSounds() {
        print("Creating synthetic metronome sounds...")
        
        // For now, we'll use the same sound but with different volumes
        // In a real app, you'd generate proper tones
        if let defaultURL = Bundle.main.url(forResource: "metronome_click", withExtension: "wav") ??
           Bundle.main.url(forResource: "la_bourtsadoros", withExtension: "wav") {
            
            do {
                let basePlayer = try AVAudioPlayer(contentsOf: defaultURL)
                basePlayer.prepareToPlay()
                
                // Clone for regular click
                metronomePlayer = try AVAudioPlayer(contentsOf: defaultURL)
                metronomePlayer?.volume = 0.5
                metronomePlayer?.prepareToPlay()
                
                // Clone for accent
                accentPlayer = try AVAudioPlayer(contentsOf: defaultURL)
                accentPlayer?.volume = 1.0
                accentPlayer?.prepareToPlay()
                
            } catch {
                print("Could not create fallback sounds: \(error)")
            }
        }
    }
    
    func toggleMetronome() {
        if isPlaying {
            stopMetronome()
        } else {
            startMetronome()
        }
    }
    
    func updateBPM(_ newBPM: Double) {
        settings.bpm = min(max(minBPM, newBPM), maxBPM)
        if isPlaying { restartMetronome() }
    }
    
    func updateBeatsPerMeasure(_ beats: Int) {
        settings.beatsPerMeasure = min(max(2, beats), 8)
        beatNumber = 0
        if isPlaying { restartMetronome() }
    }
    
    private func startMetronome() {
        stopMetronome()
        
        isPlaying = true
        beatNumber = 0
        progress = 0
        
        let beatDuration = 60.0 / settings.bpm
        
        timer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Play sound for current beat
            self.playBeatSound()
            
            // Move to next beat
            self.beatNumber = (self.beatNumber + 1) % self.settings.beatsPerMeasure
        }
        
        // Start smooth animation
        startAnimationTimer(beatDuration: beatDuration)
    }
    
    private func playBeatSound() {
        if beatNumber == 0 && settings.accentFirstBeat {
            accentPlayer?.currentTime = 0
            accentPlayer?.play()
        } else {
            metronomePlayer?.currentTime = 0
            metronomePlayer?.play()
        }
    }
    
    private func startAnimationTimer(beatDuration: TimeInterval) {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let elapsedInCurrentBeat = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: beatDuration)
            let newProgress = CGFloat(elapsedInCurrentBeat / beatDuration)
            
            DispatchQueue.main.async {
                self.progress = newProgress
                
                // Reset when we complete a beat
                if self.progress >= 1.0 {
                    self.progress = 0
                }
            }
        }
    }
    
    private func stopMetronome() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        animationTimer?.invalidate()
        animationTimer = nil
        beatNumber = 0
        progress = 0
    }
    
    private func restartMetronome() {
        if isPlaying {
            stopMetronome()
            startMetronome()
        }
    }
    
    func cleanup() {
        stopMetronome()
    }
}
