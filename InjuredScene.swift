import SpriteKit
import AVFoundation

class InjuredScene: SKScene {
    var didChooseCorridor: Bool = false
    
    // Define the signature orange color
    let biptyaOrange = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        let bgImage = SKSpriteNode(imageNamed: "injured_background")
        bgImage.size = self.size
        bgImage.position = CGPoint(x: frame.midX, y: frame.midY)
        bgImage.zPosition = 1
        addChild(bgImage)
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)

        AudioManager.shared.stopMusic()
        AudioManager.shared.playBackgroundMusic(fileName: "CarCrash", loops: 0)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "BIBTYA IS INJURED"
        label.fontSize = 50
        label.fontColor = .red
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        label.zPosition = 2
        label.alpha = 0
        addChild(label)

        // Updated button spawning with the new style
        let fenceBtn = spawnButton(
            name: "buildFence",
            text: didChooseCorridor ? "BUILD FENCE" : "FENCE LOCKED",
            pos: CGPoint(x: frame.midX, y: frame.midY - 150),
            borderColor: didChooseCorridor ? biptyaOrange : .darkGray
        )
        
        let escalateBtn = spawnButton(
            name: "escalate",
            text: "CONTINUE AS IT IS",
            pos: CGPoint(x: frame.midX, y: frame.midY - 260),
            borderColor: biptyaOrange
        )
        
        // Animations
        let shake = SKAction.repeat(SKAction.sequence([
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05)
        ]), count: 20)
        
        bgImage.run(shake)
        bgImage.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 3.0)]))
        label.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 2.0)]))
        
        let btnFade = SKAction.sequence([SKAction.wait(forDuration: 4.0), SKAction.fadeIn(withDuration: 1.0)])
        [fenceBtn, escalateBtn].forEach { btn in
            btn.alpha = 0
            addChild(btn)
            btn.run(btnFade)
        }
    }

    // UPDATED: SpriteKit implementation of the SwiftUI button style
    func spawnButton(name: String, text: String, pos: CGPoint, borderColor: UIColor) -> SKNode {
        let btnSize = CGSize(width: 320, height: 80)
        
        // 1. The Container Node (Allows us to move the whole button as one unit)
        let container = SKNode()
        container.name = name
        container.position = pos
        container.zPosition = 3
        
        // 2. The Main Body (Black 80% Opacity)
        let shape = SKShapeNode(rectOf: btnSize, cornerRadius: 12)
        shape.fillColor = UIColor.black.withAlphaComponent(0.8)
        
        // 3. The Outline (2pt Stroke)
        shape.strokeColor = borderColor
        shape.lineWidth = 2
        container.addChild(shape)
        
        // 4. The Label
        let t = SKLabelNode(text: text)
        t.fontSize = 20
        t.fontName = "AvenirNext-Bold"
        t.fontColor = .white
        t.verticalAlignmentMode = .center
        t.position = CGPoint(x: 0, y: 0)
        container.addChild(t)
        
        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        // Check container or its children
        if let tappedButton = tappedNodes.first(where: { $0.name == "escalate" || $0.parent?.name == "escalate" }) {
            let buttonNode = tappedButton.name == "escalate" ? tappedButton : tappedButton.parent
            buttonNode?.run(buttonPressAction())
            NotificationCenter.default.post(name: NSNotification.Name("GoToEscalationEnding"), object: nil)
        }
        else if let tappedButton = tappedNodes.first(where: { $0.name == "buildFence" || $0.parent?.name == "buildFence" }) {
            let buttonNode = tappedButton.name == "buildFence" ? tappedButton : tappedButton.parent
            
            if didChooseCorridor {
                buttonNode?.run(buttonPressAction())
                NotificationCenter.default.post(name: NSNotification.Name("GoToFenceBuild"), object: nil)
            } else {
                // Denied shake animation
                let shake = SKAction.repeat(SKAction.sequence([
                    SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                    SKAction.moveBy(x: -10, y: 0, duration: 0.05)
                ]), count: 3)
                buttonNode?.run(shake)
            }
        }
    }
    
    private func buttonPressAction() -> SKAction {
        return SKAction.sequence([
            SKAction.scale(to: 0.95, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
    }
}
