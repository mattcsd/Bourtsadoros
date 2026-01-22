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
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Using system sound (you can replace with custom sound files)
            let soundURL = URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tock.caf")
            metronomePlayer = try AVAudioPlayer(contentsOf: soundURL)
            metronomePlayer?.prepareToPlay()
            
            accentPlayer = try AVAudioPlayer(contentsOf: soundURL)
            accentPlayer?.prepareToPlay()
            accentPlayer?.volume = 1.5
            
        } catch {
            print("Error setting up audio: \(error)")
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
            
            if self.beatNumber == 0 && self.settings.accentFirstBeat {
                self.accentPlayer?.currentTime = 0
                self.accentPlayer?.play()
            } else {
                self.metronomePlayer?.currentTime = 0
                self.metronomePlayer?.play()
            }
            
            self.beatNumber = (self.beatNumber + 1) % self.settings.beatsPerMeasure
        }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let elapsedInCurrentBeat = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: beatDuration)
            let newProgress = CGFloat(elapsedInCurrentBeat / beatDuration)
            
            DispatchQueue.main.async {
                self.progress = newProgress
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
