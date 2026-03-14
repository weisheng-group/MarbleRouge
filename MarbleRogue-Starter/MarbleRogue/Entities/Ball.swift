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
        
        // Create ball with NEON colors - MUST BE VISIBLE
        self.node = SKShapeNode(circleOfRadius: 20)
        self.node.position = position
        self.node.zPosition = 1000
        
        // Bright neon cyan - impossible to miss
        self.node.fillColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.node.strokeColor = UIColor.white
        self.node.lineWidth = 5
        
        // Ensure it's not hidden
        self.node.isHidden = false
        self.node.alpha = 1.0
        
        // White inner circle for contrast
        let inner = SKShapeNode(circleOfRadius: 8)
        inner.fillColor = .white
        inner.strokeColor = .clear
        inner.position = CGPoint(x: -5, y: 5)
        inner.zPosition = 1
        node.addChild(inner)
        
        // Physics
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: 20)
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
