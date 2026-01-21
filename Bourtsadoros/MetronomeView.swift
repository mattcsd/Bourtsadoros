//
//  MetronomeView.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//

import SwiftUI
import AVFoundation

struct MetronomeView: View {
    @State private var isPlaying = false
    @State private var bpm: Double = 120
    @State private var beatNumber = 0
    @State private var beatsPerMeasure = 4
    @State private var accentFirstBeat = true
    @State private var metronomePlayer: AVAudioPlayer?
    @State private var accentPlayer: AVAudioPlayer?
    @State private var timer: Timer?
    @State private var progress: CGFloat = 0
    @State private var animationTimer: Timer?
    
    let maxBPM: Double = 240
    let minBPM: Double = 40
    let circleSize: CGFloat = 200
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // BPM Display
                    VStack(spacing: 5) {
                        Text("\(Int(bpm))")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 0)
                        
                        Text("BPM")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Circle Animation (filling circle instead of pendulum)
                    ZStack {
                        // Background track
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                            .frame(width: circleSize, height: circleSize)
                        
                        // Progress fill
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [.blue, .purple, .blue]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(.degrees(-90)) // Start from top
                        
                        // Beat number in center
                        VStack(spacing: 5) {
                            Text("Beat")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(beatNumber + 1)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(beatNumber == 0 && accentFirstBeat ? .red : .white)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Start/Stop Button (moved up)
                    Button(action: toggleMetronome) {
                        HStack(spacing: 15) {
                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.title2)
                            
                            Text(isPlaying ? "Stop Metronome" : "Start Metronome")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: isPlaying ?
                                [Color.red, Color.red.opacity(0.7)] :
                                [Color.green, Color.green.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: isPlaying ? .red.opacity(0.5) : .green.opacity(0.5),
                               radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    // Controls Section
                    VStack(spacing: 25) {
                        // Tempo Control
                        VStack(spacing: 15) {
                            HStack {
                                Text("TEMPO")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(Int(bpm)) BPM")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            
                            // BPM Slider
                            Slider(value: $bpm, in: minBPM...maxBPM, step: 1)
                                .onChange(of: bpm) { _ in
                                    if isPlaying {
                                        restartMetronome()
                                    }
                                }
                                .accentColor(.blue)
                            
                            // Quick BPM buttons (common tempos)
                            HStack(spacing: 10) {
                                ForEach([40, 60, 80, 100, 120, 140, 160, 180, 200, 220, 240], id: \.self) { presetBPM in
                                    if presetBPM % 20 == 0 { // Show fewer for cleaner look
                                        Button("\(presetBPM)") {
                                            bpm = Double(presetBPM)
                                            if isPlaying {
                                                restartMetronome()
                                            }
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            bpm == Double(presetBPM) ?
                                            Color.blue : Color.gray.opacity(0.2)
                                        )
                                        .foregroundColor(bpm == Double(presetBPM) ? .white : .gray)
                                        .cornerRadius(6)
                                    }
                                }
                            }
                        }
                        
                        // Time Signature
                        VStack(spacing: 15) {
                            HStack {
                                Text("TIME SIGNATURE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(beatsPerMeasure)/4")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 10) {
                                Button(action: {
                                    beatsPerMeasure = max(2, beatsPerMeasure - 1)
                                    beatNumber = 0
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach([2, 3, 4, 5, 6, 7, 8], id: \.self) { beats in
                                            Button(action: {
                                                beatsPerMeasure = beats
                                                beatNumber = 0
                                            }) {
                                                Text("\(beats)/4")
                                                    .font(.body)
                                                    .fontWeight(beatsPerMeasure == beats ? .bold : .regular)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        beatsPerMeasure == beats ?
                                                        Color.blue.opacity(0.3) : Color.clear
                                                    )
                                                    .foregroundColor(beatsPerMeasure == beats ? .white : .gray)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    beatsPerMeasure = min(8, beatsPerMeasure + 1)
                                    beatNumber = 0
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        // Accent Toggle
                        VStack(spacing: 15) {
                            HStack {
                                Text("ACCENT SETTINGS")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: accentFirstBeat ? "1.circle.fill" : "1.circle")
                                    .foregroundColor(accentFirstBeat ? .red : .gray)
                                    .font(.title2)
                                
                                Toggle("Accent first beat", isOn: $accentFirstBeat)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Metronome")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupAudio()
            }
            .onDisappear {
                stopMetronome()
            }
        }
    }
    func setupAudio() {
        do {
            // Configure audio session
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Create a simple beep sound programmatically if no file exists
            if metronomePlayer == nil {
                // Create a simple click sound using a short beep
                let soundURL = URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tock.caf")
                metronomePlayer = try AVAudioPlayer(contentsOf: soundURL)
                metronomePlayer?.prepareToPlay()
                
                accentPlayer = try AVAudioPlayer(contentsOf: soundURL)
                accentPlayer?.prepareToPlay()
                accentPlayer?.volume = 1.5
            }
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
    
    func startMetronome() {
        stopMetronome() // Clean start
        
        isPlaying = true
        beatNumber = 0
        progress = 0
        
        let beatDuration = 60.0 / bpm
        
        // Start the sound timer
        timer = Timer.scheduledTimer(withTimeInterval: beatDuration, repeats: true) { _ in
            // Play sound
            if beatNumber == 0 && accentFirstBeat {
                accentPlayer?.currentTime = 0
                accentPlayer?.play()
            } else {
                metronomePlayer?.currentTime = 0
                metronomePlayer?.play()
            }
            
            // Move to next beat
            beatNumber = (beatNumber + 1) % beatsPerMeasure
        }
        
        // Start the animation timer (smooth circle fill)
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            // Calculate progress based on beat timing
            let elapsedInCurrentBeat = Date().timeIntervalSince1970.truncatingRemainder(dividingBy: beatDuration)
            let newProgress = CGFloat(elapsedInCurrentBeat / beatDuration)
            
            DispatchQueue.main.async {
                withAnimation(.linear(duration: 0.016)) {
                    progress = newProgress
                    
                    // Reset when we complete a beat
                    if progress >= 1.0 {
                        progress = 0
                    }
                }
            }
        }
    }
    
    func stopMetronome() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        animationTimer?.invalidate()
        animationTimer = nil
        beatNumber = 0
        
        withAnimation(.spring()) {
            progress = 0
        }
    }
    
    func restartMetronome() {
        if isPlaying {
            stopMetronome()
            startMetronome()
        }
    }
}
