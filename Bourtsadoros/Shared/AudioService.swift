//
// Shared/AudioService.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 22/1/26.
//
// Shared/Services/AudioService.swift
import AVFoundation

class AudioService {
    static let shared = AudioService()
    
    private init() {
        // Don't set up session here - let each feature set up what it needs
    }
    
    func createPlayer(for filename: String, extension: String = "wav") -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: `extension`) else {
            print("Audio file not found: \(filename).\(`extension`)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("Error creating audio player: \(error)")
            return nil
        }
    }
}
