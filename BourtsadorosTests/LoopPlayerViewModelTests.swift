//
//  LoopPlayerViewModelTests.swift
//  Bourtsadoros
//
//  Created by kez542 on 22/1/26.
//


// Create in BourtsadorosTests folder:
// LoopPlayerViewModelTests.swift
import XCTest
@testable import Bourtsadoros

class LoopPlayerViewModelTests: XCTestCase {
    var viewModel: LoopPlayerViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = LoopPlayerViewModel()
    }
    
    func testBPMClamping() {
        viewModel.updateBPM(500)  // Should clamp to max 240
        XCTAssertEqual(viewModel.bpm, 240)
        
        viewModel.updateBPM(20)   // Should clamp to min 40
        XCTAssertEqual(viewModel.bpm, 40)
    }
    
    func testPlayPauseToggle() {
        XCTAssertFalse(viewModel.isPlaying)
        viewModel.togglePlayback()
        XCTAssertTrue(viewModel.isPlaying)
        viewModel.togglePlayback()
        XCTAssertFalse(viewModel.isPlaying)
    }
}