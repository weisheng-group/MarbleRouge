import SpriteKit

class Peg {
    let node: SKShapeNode
    let radius: CGFloat = 8
    
    init(position: CGPoint) {
        self.node = SKShapeNode(circleOfRadius: radius)
        self.node.position = position
        self.node.fillColor = .magenta
        self.node.strokeColor = .white
        self.node.lineWidth = 1
        self.node.glowWidth = 2
        
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.node.physicsBody?.isDynamic = false
        self.node.physicsBody?.restitution = 0.9
        self.node.physicsBody?.friction = 0.0
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.peg
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
    }
    
    func hitAnimation() {
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        let color = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 1.0, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        node.run(SKAction.group([scale, color]))
    }
}
