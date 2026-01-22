//
//  Tuner/TunerView.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//


import SwiftUI

struct TunerView: View {
    @StateObject private var viewModel = TunerViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            Text("Chromatic Tuner")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Instrument Picker
            Picker("Instrument", selection: $viewModel.selectedInstrument) {
                ForEach(Instrument.allCases, id: \.self) { instrument in
                    Text(instrument.rawValue).tag(instrument)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Frequency Display
            VStack(spacing: 5) {
                Text("\(viewModel.currentFrequency, specifier: "%.1f") Hz")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Target: \(viewModel.targetNote)")
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
                    .offset(x: viewModel.needlePosition)
            }
            .frame(height: 120)
            .padding(.horizontal)
            
            // Strings Display
            VStack(spacing: 12) {
                ForEach(viewModel.currentStrings) { string in
                    HStack {
                        Text(string.displayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(width: 50)
                            .foregroundColor(.white)
                        
                        Text("\(string.frequency, specifier: "%.1f") Hz")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        // Tuning indicator
                        Circle()
                            .fill(viewModel.isStringInTune(string) ? Color.green : Color.gray.opacity(0.5))
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
            
            // Test Buttons (for demo)
            VStack(spacing: 10) {
                Text("Test Frequencies")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 15) {
                    Button("A (440 Hz)") {
                        viewModel.testFrequency(440.0, note: "A")
                    }
                    .tunerButtonStyle(color: .blue)
                    
                    Button("E (329.6 Hz)") {
                        viewModel.testFrequency(329.63, note: "E")
                    }
                    .tunerButtonStyle(color: .blue)
                    
                    Button("Detune") {
                        viewModel.testFrequency(435.0, note: "A")
                    }
                    .tunerButtonStyle(color: .orange)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.top)
        .background(Color.black.ignoresSafeArea())
    }
}

// Helper View Modifier for Tuner buttons
struct TunerButtonStyle: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

extension View {
    func tunerButtonStyle(color: Color) -> some View {
        self.modifier(TunerButtonStyle(color: color))
    }
}
