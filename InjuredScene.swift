//
//  InjuredScene.swift
//  BIBTYA
//
//  Created by Nevin Abraham on 26/02/26.
//
import SpriteKit
import AVFoundation
class InjuredScene: SKScene {
    var didChooseCorridor: Bool = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        let bgImage = SKSpriteNode(imageNamed: "injured_background")
        bgImage.size = self.size
        bgImage.position = CGPoint(x: frame.midX, y: frame.midY)
        bgImage.zPosition = 1
        addChild(bgImage)
        
        // 1. Force the audio session to stay active and ignore the silent switch
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, mode: .default, options: [])
            try? session.setActive(true)

        // 2. Stop construction and play crash
        AudioManager.shared.stopMusic()
        AudioManager.shared.playBackgroundMusic(fileName: "CarCrash", loops: 0)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "BIBTYA IS INJURED"; label.fontSize = 50; label.fontColor = .red
        label.position = CGPoint(x: frame.midX, y: frame.midY); label.zPosition = 2; label.alpha = 0
        addChild(label)

        let fenceBtn = spawnButton(name: "buildFence",
                                   text: didChooseCorridor ? "BUILD FENCE" : "FENCE LOCKED",
                                   pos: CGPoint(x: frame.midX, y: frame.midY - 120),
                                   color: didChooseCorridor ? .systemGreen : .darkGray)
        
        let escalateBtn = spawnButton(name: "escalate",
                                     text: "CONTINUE AS IT IS",
                                     pos: CGPoint(x: frame.midX, y: frame.midY - 220),
                                     color: .white)
        
        // Animations
        let shake = SKAction.repeat(SKAction.sequence([SKAction.moveBy(x: -10, y: 0, duration: 0.05), SKAction.moveBy(x: 10, y: 0, duration: 0.05)]), count: 20)
        bgImage.run(shake)
        bgImage.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 3.0)]))
        label.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 2.0)]))
        
        let btnFade = SKAction.sequence([SKAction.wait(forDuration: 4.0), SKAction.fadeIn(withDuration: 1.0)])
        [fenceBtn, escalateBtn].forEach { $0.alpha = 0; addChild($0); $0.run(btnFade) }
    }

    func spawnButton(name: String, text: String, pos: CGPoint, color: UIColor) -> SKSpriteNode {
        let btn = SKSpriteNode(color: color, size: CGSize(width: 300, height: 60))
        btn.name = name; btn.position = pos; btn.zPosition = 3
        let t = SKLabelNode(text: text); t.fontSize = 22; t.fontName = "AvenirNext-Bold"
        t.fontColor = (color == .white) ? .black : .white; t.verticalAlignmentMode = .center
        btn.addChild(t); return btn
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(where: { $0.name == "escalate" }) {
            // TRIGGER ESCALATION ENDING
            NotificationCenter.default.post(name: NSNotification.Name("GoToEscalationEnding"), object: nil)
        }
        else if tappedNodes.contains(where: { $0.name == "buildFence" }) {
            if didChooseCorridor {
                NotificationCenter.default.post(name: NSNotification.Name("GoToFenceBuild"), object: nil)
            } else {
                let s = SKAction.repeat(SKAction.sequence([
                    SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                    SKAction.moveBy(x: -10, y: 0, duration: 0.05)
                ]), count: 3)
                childNode(withName: "buildFence")?.run(s)
            }
        }
    }
}

