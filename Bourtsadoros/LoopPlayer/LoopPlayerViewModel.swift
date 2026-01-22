//
//  LoopPlayer/LoopPlayerViewModel.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//

import Foundation
import AVFoundation
import Combine

class LoopPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var bpm: Double = 120
    @Published var progress: CGFloat = 0
    @Published var volume: Double = 1.0
    
    private var audioPlayer: AVAudioPlayer?
    private var animationTimer: Timer?
    private let audioLoop = AudioLoop.bourtsadoros
    
    let minBPM: Double = 40
    let maxBPM: Double = 240
    
    init() {
        setupAudio()
    }
    
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: audioLoop.fileName, withExtension: "wav") else {
            print("Audio file not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.enableRate = true
            audioPlayer?.rate = Float(bpm / audioLoop.baseBPM)
            audioPlayer?.volume = Float(volume)
            audioPlayer?.prepareToPlay()
            
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    func togglePlayback() {
        guard let player = audioPlayer else { return }
        
        if isPlaying {
            player.pause()
            stopAnimation()
        } else {
            player.play()
            startAnimation()
        }
        
        isPlaying.toggle()
    }
    
    func updateBPM(_ newBPM: Double) {
        bpm = min(max(minBPM, newBPM), maxBPM)
        audioPlayer?.rate = Float(bpm / audioLoop.baseBPM)
        if isPlaying { restartAnimation() }
    }
    
    func incrementBPM() { updateBPM(bpm + 1) }
    func decrementBPM() { updateBPM(bpm - 1) }
    
    func restartLoop() {
        audioPlayer?.currentTime = 0
        progress = 0
        if isPlaying { restartAnimation() }
    }
    
    func toggleMute() {
        volume = volume == 0 ? 1 : 0
        audioPlayer?.volume = Float(volume)
    }
    
    private func startAnimation() {
        stopAnimation()
        
        let loopDuration = 60.0 / bpm
        let startTime = Date().timeIntervalSince1970
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let currentTime = Date().timeIntervalSince1970
            let elapsed = currentTime - startTime
            let rawProgress = elapsed.truncatingRemainder(dividingBy: loopDuration) / loopDuration
            
            DispatchQueue.main.async {
                self.progress = rawProgress
            }
        }
    }
    
    private func restartAnimation() {
        if isPlaying {
            stopAnimation()
            startAnimation()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    func cleanup() {
        audioPlayer?.stop()
        stopAnimation()
    }
}
