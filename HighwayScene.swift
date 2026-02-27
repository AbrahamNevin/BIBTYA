import SpriteKit
import SwiftUI

@MainActor
class HighwayScene: SKScene, SKPhysicsContactDelegate {
    var biptya: SKSpriteNode!
    var didChooseCorridor: Bool = false
    
    // Movement Constants
    let moveDistanceX: CGFloat = 300
    let moveDistanceY: CGFloat = 150
    var isMoving = false
    
    // Define the custom color to match SceneOne/Two
    let biptyaOrange = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1.0)
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        
        // 1. Setup Background
        let background = SKSpriteNode(imageNamed: "road_topview")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        background.size = self.size
        addChild(background)
        
        // 2. Setup Biptya
        biptya = SKSpriteNode(imageNamed: "bibtya_walk_away")
        biptya.size = CGSize(width: 150, height: 350)
        biptya.position = CGPoint(x: frame.midX, y: frame.minY + 60)
        
        biptya.physicsBody = SKPhysicsBody(rectangleOf: biptya.size)
        biptya.physicsBody?.categoryBitMask = 1
        biptya.physicsBody?.contactTestBitMask = 2
        biptya.physicsBody?.isDynamic = true
        addChild(biptya)
        
        setupTraffic()
        createButtons()
    }
    
    // MARK: - TRAFFIC
    func setupTraffic() {
        let lanes = [frame.midY + 170, frame.midY - 10]
        let carWidth: CGFloat = 800
        let carHeight: CGFloat = 450
        let offScreenOffset: CGFloat = 500
        
        for i in 0..<2 {
            let car = SKSpriteNode(imageNamed: "car_topview\(i+1)")
            car.size = CGSize(width: carWidth, height: carHeight)
            let movingRight = (i == 0)
            let startX = movingRight ? frame.minX - offScreenOffset : frame.maxX + offScreenOffset
            let endX = movingRight ? frame.maxX + offScreenOffset : frame.minX - offScreenOffset
            
            car.position = CGPoint(x: startX, y: lanes[i])
            car.zRotation = movingRight ? 0 : .pi * 2
            
            car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
            car.physicsBody?.isDynamic = false
            car.physicsBody?.categoryBitMask = 2
            addChild(car)
            
            let duration = Double.random(in: 0.5...1.5)
            let move = SKAction.moveTo(x: endX, duration: duration)
            let reset = SKAction.run { car.position.x = startX }
            car.run(SKAction.repeatForever(SKAction.sequence([move, reset])))
        }
    }
    
    // MARK: - MOVEMENT LOGIC
    func moveBiptya(direction: String) {
        if isMoving { return }
        var newPosition = biptya.position
        switch direction {
        case "up": newPosition.y += moveDistanceY
        case "down": newPosition.y -= moveDistanceY
        case "left": newPosition.x -= moveDistanceX
        case "right": newPosition.x += moveDistanceX
        default: return
        }
        
        let padding: CGFloat = 40
        if newPosition.x > frame.minX + padding && newPosition.x < frame.maxX - padding &&
           newPosition.y > frame.minY + padding && newPosition.y < frame.maxY + 150 {
            isMoving = true
            biptya.run(SKAction.move(to: newPosition, duration: 0.12)) {
                self.isMoving = false
                if self.biptya.position.y > self.frame.maxY - 100 {
                    self.triggerSceneTransition()
                }
            }
        }
    }

    nonisolated func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        Task { @MainActor in
            if maskA == 1 || maskB == 1 { self.triggerSceneTransition() }
        }
    }

    @MainActor
    private func triggerSceneTransition() {
        guard let currentView = self.view else { return }
        let nextScene = InjuredScene(size: self.size)
        nextScene.didChooseCorridor = self.didChooseCorridor
        nextScene.scaleMode = .aspectFill
        currentView.presentScene(nextScene, transition: SKTransition.crossFade(withDuration: 0.6))
    }

    // MARK: - UPDATED UI BUTTONS
    func createButtons() {
        let btnSize = CGSize(width: 120, height: 80) // Slightly wider for the text
        
        // D-Pad Style Layout
        spawnButton(name: "up", pos: CGPoint(x: frame.minX + 100, y: frame.minY + 220), size: btnSize)
        spawnButton(name: "down", pos: CGPoint(x: frame.minX + 100, y: frame.minY + 100), size: btnSize)
        spawnButton(name: "left", pos: CGPoint(x: frame.maxX - 240, y: frame.minY + 150), size: btnSize)
        spawnButton(name: "right", pos: CGPoint(x: frame.maxX - 100, y: frame.minY + 150), size: btnSize)
    }

    func spawnButton(name: String, pos: CGPoint, size: CGSize) {
        // 1. The Main Body (Black 80% Opacity)
        let btn = SKShapeNode(rectOf: size, cornerRadius: 12)
        btn.name = name
        btn.position = pos
        btn.fillColor = UIColor.black.withAlphaComponent(0.8)
        
        // 2. The Outline (2pt Orange Stroke)
        btn.strokeColor = biptyaOrange
        btn.lineWidth = 2
        btn.zPosition = 10
        addChild(btn)
        
        // 3. The Icon/Label
        let label = SKLabelNode(text: getArrowIcon(for: name))
        label.fontSize = 26
        label.fontName = "AvenirNext-Bold"
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        label.name = name // Ensure label is also tappable
        btn.addChild(label)
    }
    
    private func getArrowIcon(for name: String) -> String {
        switch name {
        case "up": return "▲"
        case "down": return "▼"
        case "left": return "◀"
        case "right": return "▶"
        default: return ""
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let tappedNodes = nodes(at: touch.location(in: self))
        for node in tappedNodes {
            if let name = node.name {
                // Simple scale effect for feedback
                let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
                let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                node.run(SKAction.sequence([scaleDown, scaleUp]))
                
                moveBiptya(direction: name)
            }
        }
    }
}
