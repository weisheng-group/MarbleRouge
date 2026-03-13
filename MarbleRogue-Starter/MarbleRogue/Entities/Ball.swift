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
        self.node = SKShapeNode(circleOfRadius: 10)
        self.node.position = position
        self.node.fillColor = .cyan
        self.node.strokeColor = .white
        self.node.lineWidth = 2
        self.node.glowWidth = 5
        
        // Physics
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        self.node.physicsBody?.restitution = 0.8
        self.node.physicsBody?.friction = 0.2
        self.node.physicsBody?.linearDamping = 0.3
        self.node.physicsBody?.angularDamping = 0.3
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.ball
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.peg | PhysicsCategory.target | PhysicsCategory.wall
        self.node.physicsBody?.collisionBitMask = PhysicsCategory.peg | PhysicsCategory.wall
        self.node.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func applyForce(_ vector: CGVector) {
        node.physicsBody?.applyImpulse(vector)
    }
    
    func isStopped() -> Bool {
        guard let velocity = node.physicsBody?.velocity else { return true }
        return abs(velocity.dx) < 5 && abs(velocity.dy) < 5
    }
    
    func applyModifier(_ modifier: BallModifier) {
        modifiers.append(modifier)
        modifier.apply(to: self)
    }
}
