//
//  File.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 27/02/26.
//
import SwiftUI
import AVFoundation
//import UIKit
// Adding @MainActor ensures all calls to this class happen on the main thread
@MainActor
final class AudioManager {
    // This is now concurrency-safe because it's isolated to the MainActor
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?

    func playBackgroundMusic(fileName: String) {
        // Look into the Asset Catalog for a Data Asset
        guard let asset = NSDataAsset(name: fileName) else {
            print("❌ Could not find \(fileName) in Assets.xcassets")
            return
        }

        do {
            // Initialize player using the data from the asset
            audioPlayer = try AVAudioPlayer(data: asset.data)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            print("✅ Playing \(fileName) from Assets")
        } catch {
            print("❌ Playback error: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
    }
}
