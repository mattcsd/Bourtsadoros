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
    @State private var animationTimer: Timer?
    @State private var audioDuration: TimeInterval = 1.0
    
    @State private var selectedAudioFile = "la_bourtsadoros"
    
    let circleSize: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 40) {
            // Circle Animation
            ZStack {
                // Background track - thicker for better visual
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: circleSize, height: circleSize)
                
                // Progress fill with smoother gradient
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .blue,
                                .purple,
                                Color(red: 0.2, green: 0.5, blue: 1.0),
                                .blue
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 0)
                
                // Inner shadow circle for depth
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: circleSize - 24, height: circleSize - 24)
                
                // Center display
                VStack(spacing: 5) {
                    Text("\(Int(bpm))")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    
                    Text("BPM")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
            }
            
            // BPM Controls
            VStack(spacing: 25) {
                Text("BPM Selector")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    // Custom styled slider
                    ZStack {
                        // Background track
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)
                        
                        // Fill track
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: CGFloat((bpm - 40) / 200) * 250, height: 6)
                            
                            Spacer(minLength: 0)
                        }
                        .frame(width: 250)
                        
                        // Slider thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                            .offset(x: CGFloat((bpm - 40) / 200) * 250 - 125)
                    }
                    .frame(width: 250, height: 30)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newBPM = min(max(40, (value.location.x / 250) * 200 + 40), 240)
                                bpm = newBPM
                                updatePlaybackSpeed()
                            }
                    )
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            bpm = max(40, bpm - 1)
                            updatePlaybackSpeed()
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white).frame(width: 30, height: 30))
                        }
                        
                        Text("\(Int(bpm))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 80)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        
                        Button(action: {
                            bpm = min(240, bpm + 1)
                            updatePlaybackSpeed()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white).frame(width: 30, height: 30))
                        }
                    }
                    
                    // BPM presets (optional)
                    HStack(spacing: 10) {
                        ForEach([60, 90, 120, 150], id: \.self) { presetBPM in
                            Button("\(presetBPM)") {
                                bpm = Double(presetBPM)
                                updatePlaybackSpeed()
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                bpm == Double(presetBPM) ?
                                Color.blue : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(bpm == Double(presetBPM) ? .white : .gray)
                            .cornerRadius(15)
                        }
                    }
                }
            }
            
            // Play/Pause Controls
            HStack(spacing: 40) {
                Button(action: restartLoop) {
                    Image(systemName: "backward.end.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(12)
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
                
                Button(action: togglePlayback) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isPlaying ?
                                        [Color.red.opacity(0.3), Color.red.opacity(0.1)] :
                                        [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)
                            .shadow(color: isPlaying ? .red.opacity(0.3) : .green.opacity(0.3),
                                   radius: 10, x: 0, y: 5)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(isPlaying ? .red : .green)
                    }
                }
                
                Button(action: {
                    audioPlayer?.volume = audioPlayer?.volume == 0 ? 1 : 0
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(12)
                        .background(Circle().fill(Color.gray.opacity(0.2)))
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
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.enableRate = true
            audioPlayer?.rate = Float(bpm / 120.0)
            audioPlayer?.prepareToPlay()
            
            audioDuration = audioPlayer?.duration ?? 1.0
            
        } catch {
            print("Error loading audio: \(error.localizedDescription)")
        }
    }
    
    func togglePlayback() {
        guard let player = audioPlayer else { return }
        
        if isPlaying {
            player.pause()
            stopAnimation()
        } else {
            player.play()
            startSmoothAnimation()
        }
        
        isPlaying.toggle()
    }
    
    // NEW: Smoother animation with CADisplayLink-like approach
    func startSmoothAnimation() {
        stopAnimation()
        
        let loopDuration = 60.0 / bpm
        let startTime = Date().timeIntervalSince1970
        
        // Use a faster timer for smoother animation
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.008, repeats: true) { timer in
            let currentTime = Date().timeIntervalSince1970
            let elapsed = currentTime - startTime
            
            // Calculate progress with smoothing
            let rawProgress = elapsed.truncatingRemainder(dividingBy: loopDuration) / loopDuration
            
            // Apply easing function for smoother motion
            let smoothedProgress = easeInOutCubic(rawProgress)
            
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.008)) {
                    progress = smoothedProgress
                }
            }
        }
        
        // Ensure timer runs on main thread
        if let timer = animationTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    // Easing function for smoother animation
    func easeInOutCubic(_ x: Double) -> Double {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }
    
    func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    func updatePlaybackSpeed() {
        guard let player = audioPlayer else { return }
        
        // Update playback rate
        player.rate = Float(bpm / 120.0)
        
        // Restart animation with new BPM if playing
        if isPlaying {
            stopAnimation()
            startSmoothAnimation()
        }
    }
    
    func restartLoop() {
        guard let player = audioPlayer else { return }
        
        // Restart audio
        player.currentTime = 0
        
        // Smooth reset animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            progress = 0
        }
        
        // Restart smooth animation if playing
        if isPlaying {
            startSmoothAnimation()
        }
    }
    
    func cleanup() {
        audioPlayer?.stop()
        stopAnimation()
    }
}
