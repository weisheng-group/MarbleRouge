import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameState: GameStateManager?
    
    private var currentBall: Ball?
    private var pegs: [Peg] = []
    private var targets: [Target] = []
    private var aimLine: SKShapeNode?
    private var touchStartPoint: CGPoint?
    private let startPosition = CGPoint(x: 200, y: 100)
    
    private var isAiming = false
    private var hasFired = false
    
    override func didMove(to view: SKView) {
        setupScene()
        setupLevel()
        spawnBall()
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
        
        // Create triangular peg layout
        let rows = 6
        let cols = 5
        let spacing: CGFloat = 50
        let startX = size.width / 2
        let startY = size.height - 200
        
        for row in 0..<rows {
            for col in 0..<cols {
                let xOffset = CGFloat(col - cols/2) * spacing + (row % 2 == 0 ? 0 : spacing/2)
                let x = startX + xOffset
                let y = startY - CGFloat(row) * spacing
                
                if x > 30 && x < size.width - 30 {
                    let peg = Peg(position: CGPoint(x: x, y: y))
                    pegs.append(peg)
                    addChild(peg.node)
                }
            }
        }
        
        // Add targets at top
        for i in 0..<4 {
            let x = size.width / 2 + CGFloat(i - 1) * 80 - 40
            let target = Target(position: CGPoint(x: x, y: size.height - 80))
            targets.append(target)
            addChild(target.node)
        }
    }
    
    func spawnBall() {
        currentBall?.node.removeFromParent()
        hasFired = false
        
        let ball = UpgradeSystem.shared.createBallWithUpgrades(at: startPosition)
        currentBall = ball
        addChild(ball.node)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !hasFired else { return }
        let location = touch.location(in: self)
        
        // Only allow aiming from bottom area
        if location.y < 250 {
            isAiming = true
            touchStartPoint = currentBall?.node.position ?? startPosition
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isAiming, let startPoint = touchStartPoint else { return }
        let location = touch.location(in: self)
        
        updateAimLine(from: startPoint, to: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isAiming, let startPoint = touchStartPoint else { return }
        let location = touch.location(in: self)
        
        isAiming = false
        touchStartPoint = nil
        
        // Only fire if dragged far enough
        let dx = location.x - startPoint.x
        let dy = location.y - startPoint.y
        let distance = sqrt(dx*dx + dy*dy)
        
        if distance > 20 {
            fireBall(from: startPoint, to: location)
        } else {
            aimLine?.removeFromParent()
        }
    }
    
    private func updateAimLine(from start: CGPoint, to end: CGPoint) {
        aimLine?.removeFromParent()
        
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        aimLine = SKShapeNode(path: path)
        aimLine?.strokeColor = .white
        aimLine?.lineWidth = 3
        aimLine?.alpha = 0.6
        aimLine?.glowWidth = 5
        addChild(aimLine!)
    }
    
    private func fireBall(from start: CGPoint, to target: CGPoint) {
        aimLine?.removeFromParent()
        hasFired = true
        gameState?.useBall()
        
        guard let ball = currentBall else { return }
        
        let dx = target.x - start.x
        let dy = target.y - start.y
        let power: CGFloat = 0.12
        
        ball.applyForce(CGVector(dx: dx * power, dy: dy * power))
        
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
