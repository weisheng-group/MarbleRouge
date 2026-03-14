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
    
    init(position: CGPoint, type: BallType = .basic) {
        self.type = type
        
        // Cyberpunk neon ball
        self.node = SKShapeNode(circleOfRadius: 16)
        self.node.position = position
        self.node.zPosition = 100
        
        // Neon cyan core
        self.node.fillColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.node.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.node.lineWidth = 3
        self.node.glowWidth = 15
        
        // Inner white core for glow effect
        let core = SKShapeNode(circleOfRadius: 6)
        core.fillColor = .white
        core.strokeColor = .clear
        core.position = CGPoint(x: -3, y: 3)
        core.alpha = 0.9
        node.addChild(core)
        
        // Physics
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: 16)
        self.node.physicsBody?.restitution = 0.9
        self.node.physicsBody?.friction = 0.0
        self.node.physicsBody?.linearDamping = 0.1
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.ball
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.peg | PhysicsCategory.target | PhysicsCategory.wall
        self.node.physicsBody?.collisionBitMask = PhysicsCategory.peg | PhysicsCategory.wall
    }
    
    func applyForce(_ vector: CGVector) {
        node.physicsBody?.applyImpulse(vector)
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
