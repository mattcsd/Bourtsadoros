//
//  LoopPlayer/LoopPlayerView.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//


import SwiftUI

struct LoopPlayerView: View {
    @StateObject private var viewModel = LoopPlayerViewModel()
    let circleSize: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 40) {
            // Circle Animation
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: circleSize, height: circleSize)
                
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.blue, .purple, .blue]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: circleSize, height: circleSize)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .blue.opacity(0.3), radius: 5)
                
                VStack(spacing: 5) {
                    Text("\(Int(viewModel.bpm))")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Text("BPM")
                        .font(.caption)
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
                    Slider(value: $viewModel.bpm, in: viewModel.minBPM...viewModel.maxBPM, step: 1)
                        .frame(width: 250)
                        .onChange(of: viewModel.bpm) { _ in
                            viewModel.updateBPM(viewModel.bpm)
                        }
                    
                    HStack(spacing: 30) {
                        Button(action: viewModel.decrementBPM) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Text("\(Int(viewModel.bpm))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 80)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        
                        Button(action: viewModel.incrementBPM) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack(spacing: 10) {
                        ForEach([60, 90, 120, 150], id: \.self) { presetBPM in
                            Button("\(presetBPM)") {
                                viewModel.updateBPM(Double(presetBPM))
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.bpm == Double(presetBPM) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(viewModel.bpm == Double(presetBPM) ? .white : .gray)
                            .cornerRadius(15)
                        }
                    }
                }
            }
            
            // Play/Pause Controls
            HStack(spacing: 40) {
                Button(action: viewModel.restartLoop) {
                    Image(systemName: "backward.end.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(12)
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
                
                Button(action: viewModel.togglePlayback) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isPlaying ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(viewModel.isPlaying ? .red : .green)
                    }
                }
                
                Button(action: viewModel.toggleMute) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(12)
                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
            }
            
            Spacer()
        }
        .padding()
        .onDisappear {
            viewModel.cleanup()
        }
    }
}
