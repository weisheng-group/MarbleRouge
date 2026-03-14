import SpriteKit

class Target {
    let node: SKShapeNode
    let pointValue: Int
    var isHit: Bool = false
    private let originalColor: UIColor
    
    init(position: CGPoint, pointValue: Int = 100) {
        self.pointValue = pointValue
        self.originalColor = .yellow
        
        self.node = SKShapeNode(rectOf: CGSize(width: 30, height: 30), cornerRadius: 5)
        self.node.position = position
        self.node.fillColor = originalColor
        self.node.strokeColor = .orange
        self.node.lineWidth = 2
        
        self.node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30))
        self.node.physicsBody?.isDynamic = false
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.target
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
    }
    
    func hit() -> Int {
        if isHit { return 0 }
        isHit = true
        
        let scale = SKAction.sequence([
            SKAction.scale(to: 1.4, duration: 0.1),
            SKAction.scale(to: 0.1, duration: 0.2)
        ])
        let fade = SKAction.fadeOut(withDuration: 0.2)
        
        node.run(SKAction.group([scale, fade])) {
            self.node.isHidden = true
        }
        
        return pointValue
    }
    
    func reset() {
        isHit = false
        node.isHidden = false
        node.alpha = 1.0
        node.setScale(1.0)
        node.fillColor = originalColor
    }
}
