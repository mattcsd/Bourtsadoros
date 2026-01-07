//
//  TunerView.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reederon 7/1/26.
//

import SwiftUI

struct TunerView: View {
    // Guitar strings with Double frequencies
    let guitarStrings: [(String, Double)] = [
        ("E", 329.63),  // High E
        ("B", 246.94),  // B
        ("G", 196.00),  // G
        ("D", 146.83),  // D
        ("A", 110.00),  // A
        ("E", 82.41)    // Low E
    ]
    
    // Bass strings with Double frequencies (UPDATE THESE)
    let bassStrings: [(String, Double)] = [
        ("G", 98.0),    // UPDATE with actual frequency
        ("D", 73.42),   // UPDATE with actual frequency
        ("A", 55.0),    // UPDATE with actual frequency
        ("E", 41.20)    // UPDATE with actual frequency
    ]
    
    @State private var selectedInstrument = "Guitar"
    @State private var currentFrequency: Double = 0
    @State private var targetNote = "A"
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            Text("Chromatic Tuner")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Instrument Picker
            Picker("Instrument", selection: $selectedInstrument) {
                Text("Guitar").tag("Guitar")
                Text("Bass").tag("Bass")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Frequency Display
            VStack(spacing: 5) {
                Text("\(currentFrequency, specifier: "%.1f") Hz")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Target: \(targetNote)")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 20)
            
            // Visual Tuner
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                
                HStack(spacing: 0) {
                    ForEach(-10...10, id: \.self) { i in
                        VStack {
                            Rectangle()
                                .fill(i == 0 ? Color.green : Color.gray.opacity(0.5))
                                .frame(width: 2, height: i == 0 ? 60 : 30)
                            
                            if abs(i) % 5 == 0 {
                                Text("\(i)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                            }
                        }
                        .frame(width: 20)
                    }
                }
                
                // Needle
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 4, height: 80)
                    .offset(x: needlePosition(for: currentFrequency))
            }
            .frame(height: 120)
            .padding(.horizontal)
            
            // Strings Display
            VStack(spacing: 12) {
                ForEach(getCurrentStrings(), id: \.0) { stringName, frequency in
                    HStack {
                        Text(stringName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 50)
                            .foregroundColor(.white)
                        
                        Text("\(frequency, specifier: "%.1f") Hz")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Tuning indicator
                        Circle()
                            .fill(isStringInTune(stringName, frequency: frequency) ?
                                  Color.green : Color.gray.opacity(0.5))
                            .frame(width: 24, height: 24)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                    .padding(.horizontal)
                }
            }
            
            // Test Buttons (remove when implementing real microphone)
            VStack(spacing: 10) {
                Text("Test Frequencies")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 15) {
                    Button("A (440 Hz)") {
                        currentFrequency = 440.0
                        targetNote = "A"
                    }
                    .buttonStyle(TunerButtonStyle(color: .blue))
                    
                    Button("E (329.6 Hz)") {
                        currentFrequency = 329.63
                        targetNote = "E"
                    }
                    .buttonStyle(TunerButtonStyle(color: .blue))
                    
                    Button("Detune") {
                        currentFrequency = 435.0
                        targetNote = "A"
                    }
                    .buttonStyle(TunerButtonStyle(color: .orange))
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.top)
        .background(Color.black.ignoresSafeArea())
    }
    
    func getCurrentStrings() -> [(String, Double)] {
        return selectedInstrument == "Guitar" ? guitarStrings : bassStrings
    }
    
    func isStringInTune(_ string: String, frequency: Double) -> Bool {
        // Check if current frequency is within ±1 Hz of target
        guard let targetFreq = getCurrentStrings().first(where: { $0.0 == string })?.1 else {
            return false
        }
        
        return abs(currentFrequency - targetFreq) < 1.0
    }
    
    func needlePosition(for frequency: Double) -> CGFloat {
        // Center around A440
        let baseFreq: Double = 440.0
        let maxOffset: CGFloat = 100
        
        // Calculate cents difference (musical measurement)
        let cents = 1200 * log2(frequency / baseFreq)
        
        // Map cents to screen position (±50 cents = full width)
        let normalized = cents / 50.0
        let offset = CGFloat(normalized) * maxOffset
        
        // Clamp between bounds
        return max(-maxOffset, min(maxOffset, offset))
    }
}

// Custom button style for tuner
struct TunerButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
