import SpriteKit

enum BallType {
    case basic
    case split
    case bomb
    case piercing
}

class Ball {
    let node: SKShapeNode
    let type: BallType
    var modifiers: [BallModifier] = []
    private var glowNode: SKShapeNode?
    
    init(position: CGPoint, type: BallType = .basic) {
        self.type = type
        
        // Main ball - BIGGER and BRIGHTER
        self.node = SKShapeNode(circleOfRadius: 18)  // Bigger
        self.node.position = position
        self.node.zPosition = 100  // On top
        
        // Bright neon cyan
        self.node.fillColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.node.strokeColor = UIColor.white
        self.node.lineWidth = 4
        self.node.glowWidth = 20
        
        // White center highlight
        let center = SKShapeNode(circleOfRadius: 6)
        center.fillColor = .white
        center.strokeColor = .clear
        center.position = CGPoint(x: -4, y: 4)
        center.alpha = 0.8
        node.addChild(center)
        
        // Add outer glow
        let glow = SKShapeNode(circleOfRadius: 16)
        glow.fillColor = .clear
        glow.strokeColor = UIColor.cyan
        glow.lineWidth = 3
        glow.alpha = 0.3
        glow.glowWidth = 10
        node.addChild(glow)
        self.glowNode = glow
        
        // Physics - must match visual size
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        self.node.physicsBody?.restitution = 0.9
        self.node.physicsBody?.friction = 0.0
        self.node.physicsBody?.linearDamping = 0.1
        self.node.physicsBody?.angularDamping = 0.1
        self.node.physicsBody?.allowsRotation = true
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.ball
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.peg | PhysicsCategory.target | PhysicsCategory.wall
        self.node.physicsBody?.collisionBitMask = PhysicsCategory.peg | PhysicsCategory.wall
        self.node.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func applyForce(_ vector: CGVector) {
        node.physicsBody?.applyImpulse(vector)
        
        // Add spin based on direction
        let spin = vector.dx * 0.1
        node.physicsBody?.angularVelocity = spin
        
        // Pulse glow on launch
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.1),
            SKAction.fadeAlpha(to: 0.3, duration: 0.3)
        ])
        glowNode?.run(pulse)
    }
    
    func isStopped() -> Bool {
        guard let velocity = node.physicsBody?.velocity else { return true }
        return abs(velocity.dx) < 3 && abs(velocity.dy) < 3
    }
    
    func applyModifier(_ modifier: BallModifier) {
        modifiers.append(modifier)
        modifier.apply(to: self)
    }
}
