//
//  Tuner/TunerModel.swift
//  Bourtsadoros
//
//  Created by Matthaios Tsikalakis-Reeder on 7/1/26.
//

import Foundation

enum Instrument: String, CaseIterable {
    case guitar = "Guitar"
    case bass = "Bass"
}

struct TuningString: Identifiable {
    let id = UUID()
    let note: String
    let frequency: Double
    
    var displayName: String {
        return note
    }
}
