import SpriteKit

class Peg {
    let node: SKShapeNode
    let radius: CGFloat = 8
    let row: Int
    
    init(position: CGPoint, row: Int = 0) {
        self.row = row
        self.node = SKShapeNode(circleOfRadius: radius)
        self.node.position = position
        
        // Different colors for different rows (like Peggle)
        let colors: [UIColor] = [
            .systemBlue,
            .systemGreen,
            .systemYellow,
            .systemOrange,
            .systemRed,
            .systemPurple,
            .systemPink,
            .cyan
        ]
        let color = colors[row % colors.count]
        
        self.node.fillColor = color
        self.node.strokeColor = .white
        self.node.lineWidth = 1.5
        
        // Add subtle 3D effect
        let highlight = SKShapeNode(circleOfRadius: 3)
        highlight.fillColor = .white
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -2, y: 2)
        highlight.alpha = 0.4
        node.addChild(highlight)
        
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.node.physicsBody?.isDynamic = false
        self.node.physicsBody?.restitution = 0.9  // Very bouncy
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
