//
//  File.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 27/02/26.
//
import SwiftUI
import AVFoundation
import UIKit
// Adding @MainActor ensures all calls to this class happen on the main thread
@MainActor
final class AudioManager {
    // This is now concurrency-safe because it's isolated to the MainActor
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    func playBackgroundMusic(fileName: String, loops: Int = -1) { // -1 is infinite, 0 is play once
        guard let asset = NSDataAsset(name: fileName) else {
            print("❌ Could not find \(fileName) in Assets.xcassets")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(data: asset.data)
            audioPlayer?.numberOfLoops = loops // Use the variable here!
            audioPlayer?.play()
            print(" Playing \(fileName)")
        } catch {
            print(" Playback error: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
    }
}
