//
//  TestToneGenerator.swift
//  Bourtsadoros
//
//  Created by kez542 on 23/1/26.
//


// Shared/Services/TestToneGenerator.swift
import AVFoundation

class TestToneGenerator {
    static let shared = TestToneGenerator()
    
    private var audioEngine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    
    func playTestTone(frequency: Double = 440.0) {
        stop()
        
        let sampleRate = 44100.0
        var currentPhase: Double = 0
        
        sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                let sample = sin(2.0 * .pi * currentPhase)
                currentPhase += frequency / sampleRate
                if currentPhase >= 1.0 { currentPhase -= 1.0 }
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = Float(sample) * 0.1
                }
            }
            
            return noErr
        }
        
        if let sourceNode = sourceNode {
            audioEngine.attach(sourceNode)
            
            let mixer = audioEngine.mainMixerNode
            audioEngine.connect(sourceNode, to: mixer, format: mixer.outputFormat(forBus: 0))
            
            do {
                try audioEngine.start()
                print("Playing test tone at \(frequency)Hz")
            } catch {
                print("Failed to start test tone: \(error)")
            }
        }
    }
    
    func stop() {
        audioEngine.stop()
        if let sourceNode = sourceNode {
            audioEngine.detach(sourceNode)
        }
        sourceNode = nil
    }
}