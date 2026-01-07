//
//  LoopPlayerView.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//

import SwiftUI
import AVFoundation

struct LoopPlayerView: View {
    @State private var isPlaying = false
    @State private var bpm: Double = 120
    @State private var audioPlayer: AVAudioPlayer?
    @State private var progress: CGFloat = 0
    @State private var updateTimer: Timer?
    
    // Add this state for file selection
    @State private var selectedAudioFile = "la_bourtsadoros"
    
    let circleSize: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 40) {
            // Circle Animation
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                    .frame(width: circleSize, height: circleSize)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.05), value: progress)
                
                VStack {
                    Text("\(Int(bpm)) BPM")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Loop Speed")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // BPM Controls
            VStack(spacing: 20) {
                Text("Playback Speed")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("40")
                        .foregroundColor(.gray)
                    
                    Slider(value: $bpm, in: 40...240, step: 1)
                        .onChange(of: bpm) { newValue in
                            updatePlaybackSpeed()
                        }
                    
                    Text("240")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                HStack(spacing: 30) {
                    Button(action: { bpm = max(40, bpm - 5) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    Text("\(Int(bpm))")
                        .font(.title2)
                        .frame(width: 60)
                    
                    Button(action: { bpm = min(240, bpm + 5) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Play/Pause Button
            Button(action: togglePlayback) {
                HStack(spacing: 15) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(isPlaying ? .red : .green)
                    
                    Text(isPlaying ? "Pause Loop" : "Play Loop")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .onAppear {
            setupAudio()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    func setupAudio() {
        guard let url = Bundle.main.url(forResource: selectedAudioFile, withExtension: "wav") else {
            print("Audio file not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.enableRate = true
            audioPlayer?.rate = 1.0 // Start at normal speed
            audioPlayer?.prepareToPlay()
            
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
            updateTimer?.invalidate()
            updateTimer = nil
        } else {
            audioPlayer?.play()
            startProgressUpdates()
        }
        isPlaying.toggle()
    }
    
    func startProgressUpdates() {
        updateTimer?.invalidate()
        
        // Calculate how long one loop should take at current BPM
        // Assuming the audio file is a 1-bar loop at 120 BPM
        let loopDuration = 60.0 / bpm * 2 // For a 2-beat bar at current BPM
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            guard let player = audioPlayer else { return }
            
            // Calculate progress based on BPM timing
            let elapsedTime = player.currentTime.truncatingRemainder(dividingBy: loopDuration)
            let newProgress = CGFloat(elapsedTime / loopDuration)
            
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.05)) {
                    progress = newProgress
                }
            }
        }
    }
    
    func updatePlaybackSpeed() {
        guard let player = audioPlayer else { return }
        
        // Change playback rate based on BPM
        // Base rate is at 120 BPM = 1.0
        player.rate = Float(bpm / 120.0)
        
        // Restart progress updates if playing
        if isPlaying {
            updateTimer?.invalidate()
            startProgressUpdates()
        }
    }
    
    func cleanup() {
        audioPlayer?.stop()
        updateTimer?.invalidate()
        updateTimer = nil
    }
}
