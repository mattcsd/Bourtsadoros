//
//  Tuner/TunerView.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//

// Tuner/TunerView.swift (Updated - simpler version)
import SwiftUI

struct TunerView: View {
    @StateObject private var viewModel = TunerViewModel()
    @State private var showMicrophoneAlert = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            Text("Chromatic Tuner")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Instrument Picker
            InstrumentPickerView(viewModel: viewModel)
            
            // Frequency Display
            FrequencyDisplayView(viewModel: viewModel)
            
            // Visual Tuner
            VisualTunerView(needlePosition: viewModel.needlePosition)
            
            // Listening Button
            ListeningButtonView(viewModel: viewModel)
            
            // Strings Display
            StringsDisplayView(viewModel: viewModel)
            
            // Test Buttons
            if !viewModel.isListening {
                TestButtonsView(viewModel: viewModel)
            }
            
            Spacer()
        }
        .padding(.top)
        .background(Color.black.ignoresSafeArea())
        .alert("Microphone Access Required",
               isPresented: $showMicrophoneAlert) {
            Button("OK") { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable microphone access in Settings to use the tuner.")
        }
        .onChange(of: viewModel.errorMessage) { error in
            if error != nil {
                showMicrophoneAlert = true
            }
        }
    }
}

// MARK: - Subviews

struct InstrumentPickerView: View {
    @ObservedObject var viewModel: TunerViewModel
    
    var body: some View {
        Picker("Instrument", selection: $viewModel.selectedInstrument) {
            ForEach(Instrument.allCases, id: \.self) { instrument in
                Text(instrument.rawValue).tag(instrument)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .disabled(viewModel.isListening)
    }
}

struct FrequencyDisplayView: View {
    @ObservedObject var viewModel: TunerViewModel
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(viewModel.currentFrequency, specifier: "%.1f") Hz")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Note: \(viewModel.currentNote)")
                .font(.title3)
                .foregroundColor(.gray)
            
            Text("Target: \(viewModel.targetNote)")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 20)
    }
}

struct VisualTunerView: View {
    let needlePosition: CGFloat
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 120)
            
            // Scale markings
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
                .offset(x: needlePosition)
        }
        .frame(height: 120)
        .padding(.horizontal)
    }
}

struct ListeningButtonView: View {
    @ObservedObject var viewModel: TunerViewModel
    
    var body: some View {
        Button(action: viewModel.toggleListening) {
            HStack(spacing: 15) {
                Image(systemName: viewModel.isListening ? "mic.circle.fill" : "mic.circle")
                    .font(.title2)
                
                Text(viewModel.isListening ? "Listening... Tap to Stop" : "Start Listening")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.isListening ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(color: viewModel.isListening ? .red.opacity(0.5) : .green.opacity(0.5),
                   radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct StringsDisplayView: View {
    @ObservedObject var viewModel: TunerViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.currentStrings) { string in
                StringRowView(viewModel: viewModel, string: string)
            }
        }
        .padding(.top, 20)
    }
}

struct StringRowView: View {
    @ObservedObject var viewModel: TunerViewModel
    let string: TuningString
    
    var body: some View {
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
                .overlay(
                    Text(viewModel.isStringInTune(string) ? "✓" : "")
                        .font(.caption)
                        .foregroundColor(.white)
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct TestButtonsView: View {
    @ObservedObject var viewModel: TunerViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Test Frequencies (Demo)")
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 15) {
                ForEach(viewModel.currentStrings.prefix(3), id: \.note) { string in
                    Button("\(string.note)") {
                        viewModel.testFrequency(string.frequency, note: string.note)
                    }
                    .tunerButtonStyle(color: .blue)
                }
                
                Button("Detune") {
                    viewModel.testFrequency(435.0, note: "A")
                }
                .tunerButtonStyle(color: .orange)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Helper Extension

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
