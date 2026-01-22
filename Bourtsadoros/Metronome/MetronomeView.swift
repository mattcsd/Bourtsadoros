//
//  Metronome/MetronomeView.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//

import SwiftUI

struct MetronomeView: View {
    @StateObject private var viewModel = MetronomeViewModel()
    let circleSize: CGFloat = 200
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // BPM Display
                    VStack(spacing: 5) {
                        Text("\(Int(viewModel.settings.bpm))")
                            .font(.system(size: 72, weight: .heavy))
                            .foregroundColor(.white)
                        
                        Text("BPM")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Circle Animation
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 10)
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
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 5) {
                            Text("Beat")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(viewModel.beatNumber + 1)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(viewModel.beatNumber == 0 && viewModel.settings.accentFirstBeat ? .red : .white)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Start/Stop Button
                    Button(action: viewModel.toggleMetronome) {
                        HStack(spacing: 15) {
                            Image(systemName: viewModel.isPlaying ? "stop.fill" : "play.fill")
                                .font(.title2)
                            
                            Text(viewModel.isPlaying ? "Stop Metronome" : "Start Metronome")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isPlaying ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
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
                                Text("\(Int(viewModel.settings.bpm)) BPM")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                            
                            Slider(value: $viewModel.settings.bpm, in: viewModel.minBPM...viewModel.maxBPM, step: 1)
                                .onChange(of: viewModel.settings.bpm) { _ in
                                    viewModel.updateBPM(viewModel.settings.bpm)
                                }
                                .accentColor(.blue)
                            
                            HStack(spacing: 10) {
                                ForEach([40, 80, 120, 160, 200, 240], id: \.self) { presetBPM in
                                    Button("\(presetBPM)") {
                                        viewModel.updateBPM(Double(presetBPM))
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(viewModel.settings.bpm == Double(presetBPM) ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(viewModel.settings.bpm == Double(presetBPM) ? .white : .gray)
                                    .cornerRadius(6)
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
                                Text("\(viewModel.settings.beatsPerMeasure)/4")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            HStack(spacing: 10) {
                                Button(action: {
                                    viewModel.updateBeatsPerMeasure(viewModel.settings.beatsPerMeasure - 1)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach([2, 3, 4, 5, 6, 7, 8], id: \.self) { beats in
                                            Button(action: {
                                                viewModel.updateBeatsPerMeasure(beats)
                                            }) {
                                                Text("\(beats)/4")
                                                    .font(.body)
                                                    .fontWeight(viewModel.settings.beatsPerMeasure == beats ? .bold : .regular)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(viewModel.settings.beatsPerMeasure == beats ? Color.blue.opacity(0.3) : Color.clear)
                                                    .foregroundColor(viewModel.settings.beatsPerMeasure == beats ? .white : .gray)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    viewModel.updateBeatsPerMeasure(viewModel.settings.beatsPerMeasure + 1)
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
                            
                            Toggle("Accent first beat", isOn: $viewModel.settings.accentFirstBeat)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Metronome")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                viewModel.cleanup()
            }
        }
    }
}
