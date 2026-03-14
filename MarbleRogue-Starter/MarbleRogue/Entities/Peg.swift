import SpriteKit

class Peg {
    let node: SKShapeNode
    let radius: CGFloat = 8
    let row: Int
    
    init(position: CGPoint, row: Int = 0) {
        self.row = row
        self.node = SKShapeNode(circleOfRadius: radius)
        self.node.position = position
        
        // Cyberpunk neon colors
        let colors: [UIColor] = [
            UIColor(red: 1.0, green: 0.0, blue: 0.8, alpha: 1.0),   // Neon Pink
            UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),   // Neon Cyan
            UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),   // Neon Magenta
            UIColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0),   // Neon Purple
            UIColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0),   // Neon Green
        ]
        let color = colors[row % colors.count]
        
        self.node.fillColor = color
        self.node.strokeColor = .white
        self.node.lineWidth = 2
        self.node.glowWidth = 8
        
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.node.physicsBody?.isDynamic = false
        self.node.physicsBody?.restitution = 0.9
        self.node.physicsBody?.friction = 0.0
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.peg
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
    }
    
    func hitAnimation() {
        // Flash white
        let originalColor = node.fillColor
        let flash = SKAction.sequence([
            SKAction.run { self.node.fillColor = .white },
            SKAction.wait(forDuration: 0.05),
            SKAction.run { self.node.fillColor = originalColor }
        ])
        
        // Scale bounce
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        node.run(SKAction.group([flash, scale]))
    }
}
