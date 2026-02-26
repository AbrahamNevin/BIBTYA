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
    
    // MARK: - TRAFFIC (IMPOSSIBLE MODE)
    func setupTraffic() {
        let lanes = [
            frame.midY + 170, // Upper lane
            frame.midY - 10   // Lower lane
        ]
        
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
            
            if !movingRight {
                car.zRotation = .pi * 2
            } else {
                car.zRotation = 0
            }
            
            car.physicsBody = SKPhysicsBody(rectangleOf: car.size)
            car.physicsBody?.isDynamic = false
            car.physicsBody?.categoryBitMask = 2
            addChild(car)
            
            let duration = Double.random(in: 0.5...1.5)
            
            let move = SKAction.moveTo(x: endX, duration: duration)
            let reset = SKAction.run { car.position.x = startX }
            let sequence = SKAction.sequence([move, reset])
            car.run(SKAction.repeatForever(sequence))
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
            let moveAction = SKAction.move(to: newPosition, duration: 0.12)
            biptya.run(moveAction) {
                self.isMoving = false
                if self.biptya.position.y > self.frame.maxY - 100 {
                    self.triggerSceneTransition()
                }
            }
        }
    }
    // sending 'contact' risks causing data races
    
    // MARK: - COLLISION HANDLING
    // Using nonisolated to satisfy the delegate, then jumping to @MainActor
   
        nonisolated func didBegin(_ contact: SKPhysicsContact) {
            // 1. Extract the data immediately on the background thread
            // These are just Ints (categoryBitMask), so they are safe to send
            let maskA = contact.bodyA.categoryBitMask
            let maskB = contact.bodyB.categoryBitMask
            
            // 2. Pass ONLY the integers into the MainActor task
            Task { @MainActor in
                if maskA == 1 || maskB == 1 {
                    self.triggerSceneTransition()
                }
            }
        }
    @MainActor
    private func triggerSceneTransition() {
        guard let currentView = self.view else { return }
        
        // Important: Ensure InjuredScene is defined in your project
        let nextScene = InjuredScene(size: self.size)
        nextScene.didChooseCorridor = self.didChooseCorridor
        nextScene.scaleMode = .aspectFill
        
        let transition = SKTransition.crossFade(withDuration: 0.6)
        currentView.presentScene(nextScene, transition: transition)
    }

    // MARK: - UI BUTTONS
    func createButtons() {
        let btnSize = CGSize(width: 100, height: 100)
        spawnButton(name: "up", pos: CGPoint(x: frame.minX + 80, y: frame.minY + 250), size: btnSize, color: .blue)
        spawnButton(name: "down", pos: CGPoint(x: frame.minX + 80, y: frame.minY + 100), size: btnSize, color: .blue)
        spawnButton(name: "left", pos: CGPoint(x: frame.maxX - 220, y: frame.minY + 150), size: btnSize, color: .red)
        spawnButton(name: "right", pos: CGPoint(x: frame.maxX - 80, y: frame.minY + 150), size: btnSize, color: .red)
    }

    func spawnButton(name: String, pos: CGPoint, size: CGSize, color: UIColor) {
        let btn = SKSpriteNode(color: color, size: size)
        btn.name = name
        btn.position = pos
        btn.alpha = 0.3
        btn.zPosition = 10
        addChild(btn)
        
        let label = SKLabelNode(text: name.uppercased())
        label.fontSize = 20
        label.fontName = "AvenirNext-Bold"
        label.verticalAlignmentMode = .center
        btn.addChild(label)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let tappedNodes = nodes(at: touch.location(in: self))
        for node in tappedNodes {
            if let name = node.name { moveBiptya(direction: name) }
        }
    }
}
