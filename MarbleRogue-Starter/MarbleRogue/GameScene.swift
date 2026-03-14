import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameState: GameStateManager?
    
    private var currentBall: Ball?
    private var pegs: [Peg] = []
    private var targets: [Target] = []
    private var aimLine: SKShapeNode?
    private var touchStartPoint: CGPoint?
    private var startPosition: CGPoint {
        return CGPoint(x: size.width / 2, y: 80)
    }
    
    private var isAiming = false
    private var hasFired = false
    
    override func didMove(to view: SKView) {
        setupScene()
        setupLevel()
        spawnBall()
        
        // Debug: Show where the ball should be
        print("Screen size: \(size)")
        print("Ball start position: \(startPosition)")
    }
    
    private func setupScene() {
        backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        setupWalls()
    }
    
    private func setupWalls() {
        let thickness: CGFloat = 20
        let wallColor = UIColor.purple.withAlphaComponent(0.3)
        
        // Left wall
        let leftWall = SKShapeNode(rectOf: CGSize(width: thickness, height: size.height))
        leftWall.fillColor = wallColor
        leftWall.position = CGPoint(x: -thickness/2, y: size.height/2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: thickness, height: size.height))
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(leftWall)
        
        // Right wall
        let rightWall = SKShapeNode(rectOf: CGSize(width: thickness, height: size.height))
        rightWall.fillColor = wallColor
        rightWall.position = CGPoint(x: size.width + thickness/2, y: size.height/2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: thickness, height: size.height))
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        addChild(rightWall)
    }
    
    func setupLevel() {
        // Clear existing
        pegs.forEach { $0.node.removeFromParent() }
        targets.forEach { $0.node.removeFromParent() }
        pegs.removeAll()
        targets.removeAll()
        
        // Create classic Peggle-style board layout
        let rows = 8
        let cols = 7
        let spacingX: CGFloat = 50
        let spacingY: CGFloat = 45
        let startX = size.width / 2
        let startY = size.height - 180
        
        // Create triangular peg pattern (like real pachinko/Peggle)
        for row in 0..<rows {
            let pegsInRow = cols - abs(row - 3)  // More pegs in middle rows
            let rowWidth = CGFloat(pegsInRow - 1) * spacingX
            let rowStartX = startX - rowWidth / 2
            
            for col in 0..<pegsInRow {
                let x = rowStartX + CGFloat(col) * spacingX
                let y = startY - CGFloat(row) * spacingY
                
                // Color variation based on row
                let peg = Peg(position: CGPoint(x: x, y: y), row: row)
                pegs.append(peg)
                addChild(peg.node)
            }
        }
        
        // Add bucket/targets at bottom
        let bucketY: CGFloat = 80
        for i in 0..<5 {
            let x = size.width * 0.2 + CGFloat(i) * size.width * 0.15
            let target = Target(position: CGPoint(x: x, y: bucketY), pointValue: 50 + i * 50)
            targets.append(target)
            addChild(target.node)
        }
    }
    
    func spawnBall() {
        currentBall?.node.removeFromParent()
        hasFired = false
        
        // Force ball position to bottom center, higher up
        let ballX = size.width / 2
        let ballY: CGFloat = 120  // Fixed position above the buckets
        let ballPos = CGPoint(x: ballX, y: ballY)
        
        print("=== SPAWNING BALL ===")
        print("Screen size: \(size)")
        print("Ball position: \(ballPos)")
        
        let ball = Ball(position: ballPos, type: .basic)  // Use basic ball for testing
        currentBall = ball
        ball.node.zPosition = 1000  // Extremely high z-index
        
        // Force visibility
        ball.node.isHidden = false
        ball.node.alpha = 1.0
        
        addChild(ball.node)
        
        print("Ball node added: \(ball.node)")
        print("Ball parent: \(String(describing: ball.node.parent))")
        
        // Add indicator at same position
        addAimIndicator(at: ballPos)
    }
    
    private func addAimIndicator(at position: CGPoint) {
        // Remove old indicator
        childNode(withName: "aimIndicator")?.removeFromParent()
        
        // Large pulsing ring
        let ring = SKShapeNode(circleOfRadius: 40)
        ring.name = "aimIndicator"
        ring.position = position
        ring.fillColor = .clear
        ring.strokeColor = .yellow
        ring.lineWidth = 4
        ring.alpha = 0.8
        ring.zPosition = 99
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        ring.run(SKAction.repeatForever(pulse))
        
        addChild(ring)
        
        // Label below
        let label = SKLabelNode(text: "← 向后拖动瞄准")
        label.name = "aimIndicator"
        label.position = CGPoint(x: position.x, y: position.y - 60)
        label.fontSize = 18
        label.fontColor = .yellow
        label.alpha = 0.9
        label.zPosition = 99
        addChild(label)
    }
    
    // MARK: - Touch Handling (Slingshot Style)
    
    private var aimDirection: CGVector = .zero
    private var dragDistance: CGFloat = 0
    private let maxDragDistance: CGFloat = 150
    private let maxPower: CGFloat = 25
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !hasFired else { return }
        let location = touch.location(in: self)
        
        // Only allow aiming from bottom area near the ball
        let ballPos = currentBall?.node.position ?? startPosition
        let distance = hypot(location.x - ballPos.x, location.y - ballPos.y)
        
        if distance < 100 && location.y < 200 {
            isAiming = true
            touchStartPoint = ballPos
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isAiming, let startPoint = touchStartPoint else { return }
        let location = touch.location(in: self)
        
        // Calculate drag vector (opposite direction for slingshot feel)
        let dx = startPoint.x - location.x
        let dy = startPoint.y - location.y
        dragDistance = min(hypot(dx, dy), maxDragDistance)
        
        // Calculate aim direction (opposite to drag)
        let angle = atan2(dy, dx)
        aimDirection = CGVector(dx: cos(angle), dy: sin(angle))
        
        updateAimLine(from: startPoint, direction: angle, power: dragDistance / maxDragDistance)
        updateBallPositionWhileAiming(from: startPoint, direction: angle, drag: dragDistance)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isAiming else { return }
        
        isAiming = false
        touchStartPoint = nil
        
        // Fire with power based on drag distance
        if dragDistance > 20 {
            let power = (dragDistance / maxDragDistance) * maxPower
            fireBall(direction: aimDirection, power: power)
        } else {
            aimLine?.removeFromParent()
            // Reset ball position
            currentBall?.node.position = startPosition
        }
    }
    
    private func updateAimLine(from start: CGPoint, direction: CGFloat, power: CGFloat) {
        aimLine?.removeFromParent()
        
        // Draw trajectory preview
        let lineLength: CGFloat = 100 + 100 * power
        let endX = start.x + cos(direction) * lineLength
        let endY = start.y + sin(direction) * lineLength
        
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: CGPoint(x: endX, y: endY))
        
        aimLine = SKShapeNode(path: path)
        aimLine?.strokeColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.8)
        aimLine?.lineWidth = 4
        aimLine?.lineCap = .round
        aimLine?.glowWidth = 8
        
        // Dashed line effect
        let pattern: [CGFloat] = [10, 5]
        let dashedPath = path.copy(dashingWithPhase: 0, lengths: pattern)
        aimLine?.path = dashedPath
        
        addChild(aimLine!)
    }
    
    private func updateBallPositionWhileAiming(from start: CGPoint, direction: CGFloat, drag: CGFloat) {
        // Pull ball back in opposite direction of aim
        let pullDistance = drag * 0.3
        let ballX = start.x - cos(direction) * pullDistance
        let ballY = start.y - sin(direction) * pullDistance
        currentBall?.node.position = CGPoint(x: ballX, y: ballY)
    }
    
    private func fireBall(direction: CGVector, power: CGFloat) {
        aimLine?.removeFromParent()
        hasFired = true
        gameState?.useBall()
        
        guard let ball = currentBall else { return }
        
        // Reset ball to start position then apply impulse
        ball.node.position = startPosition
        
        // Apply force in aim direction
        let impulse = CGVector(dx: direction.dx * power, dy: direction.dy * power)
        ball.applyForce(impulse)
        
        // Check when ball stops
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if ball.isStopped() {
                timer.invalidate()
                self.checkLevelComplete()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !(self.gameState?.isGameOver ?? true) {
                        self.spawnBall()
                    }
                }
            }
            
            // Timeout after 10 seconds
            if timer.fireDate.timeIntervalSinceNow < -10 {
                timer.invalidate()
                self.checkLevelComplete()
                self.spawnBall()
            }
        }
    }
    
    private func checkLevelComplete() {
        let remainingTargets = targets.filter { !$0.isHit }.count
        if remainingTargets == 0 {
            gameState?.levelComplete()
        }
    }
    
    // MARK: - Collision Handling
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Ball hits peg
        if (bodyA.categoryBitMask == PhysicsCategory.ball && bodyB.categoryBitMask == PhysicsCategory.peg) {
            if let pegNode = bodyB.node as? SKShapeNode,
               let peg = pegs.first(where: { $0.node == pegNode }) {
                peg.hitAnimation()
            }
        } else if (bodyB.categoryBitMask == PhysicsCategory.ball && bodyA.categoryBitMask == PhysicsCategory.peg) {
            if let pegNode = bodyA.node as? SKShapeNode,
               let peg = pegs.first(where: { $0.node == pegNode }) {
                peg.hitAnimation()
            }
        }
        
        // Ball hits target
        if (bodyA.categoryBitMask == PhysicsCategory.ball && bodyB.categoryBitMask == PhysicsCategory.target) {
            if let targetNode = bodyB.node as? SKShapeNode,
               let target = targets.first(where: { $0.node == targetNode }) {
                let points = target.hit()
                gameState?.addScore(points)
                
                // Particle effect
                createHitParticles(at: contact.contactPoint)
            }
        } else if (bodyB.categoryBitMask == PhysicsCategory.ball && bodyA.categoryBitMask == PhysicsCategory.target) {
            if let targetNode = bodyA.node as? SKShapeNode,
               let target = targets.first(where: { $0.node == targetNode }) {
                let points = target.hit()
                gameState?.addScore(points)
                createHitParticles(at: contact.contactPoint)
            }
        }
    }
    
    private func createHitParticles(at position: CGPoint) {
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.position = position
            particle.fillColor = .yellow
            particle.strokeColor = .clear
            addChild(particle)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 30...60)
            let move = SKAction.moveBy(
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                duration: 0.3
            )
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let scale = SKAction.scale(to: 0.1, duration: 0.3)
            
            particle.run(SKAction.group([move, fade, scale])) {
                particle.removeFromParent()
            }
        }
    }
}
