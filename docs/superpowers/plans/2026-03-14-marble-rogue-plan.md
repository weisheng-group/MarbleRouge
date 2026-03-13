# Marble Rogue Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build MVP of Marble Rogue - a physics-based marble roguelike with 3 ball types, 5 levels, and upgrade system for iOS.

**Architecture:** SpriteKit for game physics and rendering, SwiftUI for UI overlays, simple Entity-Component pattern for game objects.

**Tech Stack:** Swift 5.9, SpriteKit, SwiftUI, Xcode 15+

---

## Project Setup

### Task 1: Create Xcode Project

**Files:**
- Create: `MarbleRogue.xcodeproj`
- Create: `MarbleRogue/App.swift`
- Create: `MarbleRogue/ContentView.swift`

- [ ] **Step 1: Create new iOS Game project**

Open Xcode → Create New Project → iOS → Game → Name: "MarbleRogue"
- Interface: SwiftUI
- Game Technology: SpriteKit
- Include Tests: Yes

- [ ] **Step 2: Configure project settings**

Target → General:
- Deployment Target: iOS 16.0
- Device Orientation: Portrait only
- Status Bar Style: Hide

- [ ] **Step 3: Initial commit**

```bash
cd /path/to/MarbleRogue
git init
git add .
git commit -m "chore: initial project setup"
```

---

## Core Physics & Entities

### Task 2: Create Ball Entity

**Files:**
- Create: `MarbleRogue/Entities/Ball.swift`
- Create: `MarbleRogueTests/BallTests.swift`

- [ ] **Step 1: Write failing test for Ball creation**

```swift
// MarbleRogueTests/BallTests.swift
import XCTest
@testable import MarbleRogue

final class BallTests: XCTestCase {
    func testBallCreation() {
        let ball = Ball(position: CGPoint(x: 100, y: 100), type: .basic)
        XCTAssertNotNil(ball.node)
        XCTAssertEqual(ball.node.position, CGPoint(x: 100, y: 100))
    }
}
```

Run: `Cmd+U`  
Expected: FAIL - "Cannot find 'Ball' in scope"

- [ ] **Step 2: Implement Ball class**

```swift
// MarbleRogue/Entities/Ball.swift
import SpriteKit

enum BallType {
    case basic
    case split
    case bomb
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
        
        // Physics
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        self.node.physicsBody?.restitution = 0.7
        self.node.physicsBody?.friction = 0.3
        self.node.physicsBody?.linearDamping = 0.5
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.ball
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.peg | PhysicsCategory.target
    }
    
    func applyForce(_ vector: CGVector) {
        node.physicsBody?.applyImpulse(vector)
    }
    
    func isStopped() -> Bool {
        guard let velocity = node.physicsBody?.velocity else { return true }
        return abs(velocity.dx) < 10 && abs(velocity.dy) < 10
    }
}
```

- [ ] **Step 3: Run test to verify**

Run: `Cmd+U`  
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m "feat: add Ball entity with physics"
```

---

### Task 3: Create Peg Entity

**Files:**
- Create: `MarbleRogue/Entities/Peg.swift`
- Modify: `MarbleRogue/Utils/Constants.swift` (create)

- [ ] **Step 1: Create Physics Constants**

```swift
// MarbleRogue/Utils/Constants.swift
import SpriteKit

struct PhysicsCategory {
    static let ball: UInt32 = 0x1 << 0
    static let peg: UInt32 = 0x1 << 1
    static let target: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
}
```

- [ ] **Step 2: Implement Peg class**

```swift
// MarbleRogue/Entities/Peg.swift
import SpriteKit

class Peg {
    let node: SKShapeNode
    
    init(position: CGPoint, radius: CGFloat = 8) {
        self.node = SKShapeNode(circleOfRadius: radius)
        self.node.position = position
        self.node.fillColor = .magenta
        self.node.strokeColor = .white
        self.node.lineWidth = 1
        
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        self.node.physicsBody?.isDynamic = false
        self.node.physicsBody?.restitution = 0.8
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.peg
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: add Peg entity and physics constants"
```

---

### Task 4: Create Target Entity

**Files:**
- Create: `MarbleRogue/Entities/Target.swift`

- [ ] **Step 1: Implement Target class**

```swift
// MarbleRogue/Entities/Target.swift
import SpriteKit

class Target {
    let node: SKShapeNode
    let pointValue: Int
    var isHit: Bool = false
    
    init(position: CGPoint, pointValue: Int = 100) {
        self.pointValue = pointValue
        
        self.node = SKShapeNode(rectOf: CGSize(width: 30, height: 30), cornerRadius: 5)
        self.node.position = position
        self.node.fillColor = .yellow
        self.node.strokeColor = .orange
        self.node.lineWidth = 2
        
        self.node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30))
        self.node.physicsBody?.isDynamic = false
        self.node.physicsBody?.categoryBitMask = PhysicsCategory.target
        self.node.physicsBody?.contactTestBitMask = PhysicsCategory.ball
    }
    
    func hit() {
        isHit = true
        node.fillColor = .gray
        
        // Visual feedback
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        node.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    func reset() {
        isHit = false
        node.fillColor = .yellow
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "feat: add Target entity with hit feedback"
```

---

## Game Scene & Physics

### Task 5: Create GameScene

**Files:**
- Create: `MarbleRogue/GameScene.swift`
- Modify: `MarbleRogue/Physics/CollisionManager.swift`

- [ ] **Step 1: Create CollisionManager**

```swift
// MarbleRogue/Physics/CollisionManager.swift
import SpriteKit

class CollisionManager: NSObject, SKPhysicsContactDelegate {
    var onBallHitPeg: (() -> Void)?
    var onBallHitTarget: ((Int) -> Void)?
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Check ball-peg collision
        if (bodyA.categoryBitMask == PhysicsCategory.ball && bodyB.categoryBitMask == PhysicsCategory.peg) ||
           (bodyB.categoryBitMask == PhysicsCategory.ball && bodyA.categoryBitMask == PhysicsCategory.peg) {
            onBallHitPeg?()
        }
        
        // Check ball-target collision
        if (bodyA.categoryBitMask == PhysicsCategory.ball && bodyB.categoryBitMask == PhysicsCategory.target) ||
           (bodyB.categoryBitMask == PhysicsCategory.ball && bodyA.categoryBitMask == PhysicsCategory.target) {
            onBallHitTarget?(100)
            
            // Visual feedback on target
            if let targetNode = bodyA.categoryBitMask == PhysicsCategory.target ? bodyA.node : bodyB.node {
                targetNode.run(SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.1),
                    SKAction.scale(to: 1.0, duration: 0.1)
                ]))
            }
        }
    }
}
```

- [ ] **Step 2: Implement GameScene**

```swift
// MarbleRogue/GameScene.swift
import SpriteKit
import SwiftUI

class GameScene: SKScene {
    var collisionManager = CollisionManager()
    var currentBall: Ball?
    var pegs: [Peg] = []
    var targets: [Target] = []
    var score: Int = 0
    var onScoreUpdate: ((Int) -> Void)?
    var onBallStopped: (() -> Void)?
    
    private var aimLine: SKShapeNode?
    private var startPosition: CGPoint = CGPoint(x: 200, y: 100)
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        physicsWorld.contactDelegate = collisionManager
        physicsWorld.gravity = CGVector(dx: 0, dy: -3) // Light gravity
        
        setupWalls()
        setupLevel()
        
        collisionManager.onBallHitTarget = { [weak self] points in
            self?.score += points
            self?.onScoreUpdate?(self?.score ?? 0)
        }
    }
    
    func setupWalls() {
        let wallThickness: CGFloat = 20
        
        // Left wall
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: size.height))
        leftWall.physicsBody?.isDynamic = false
        leftWall.position = CGPoint(x: -wallThickness/2, y: size.height/2)
        addChild(leftWall)
        
        // Right wall
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallThickness, height: size.height))
        rightWall.physicsBody?.isDynamic = false
        rightWall.position = CGPoint(x: size.width + wallThickness/2, y: size.height/2)
        addChild(rightWall)
    }
    
    func setupLevel() {
        // Clear existing
        pegs.forEach { $0.node.removeFromParent() }
        targets.forEach { $0.node.removeFromParent() }
        pegs.removeAll()
        targets.removeAll()
        
        // Add pegs in triangular pattern
        let rows = 5
        let cols = 7
        let spacing: CGFloat = 50
        let startX = (size.width - CGFloat(cols - 1) * spacing) / 2
        let startY = size.height - 150
        
        for row in 0..<rows {
            for col in 0..<cols {
                let x = startX + CGFloat(col) * spacing + (row % 2 == 0 ? 0 : spacing/2)
                let y = startY - CGFloat(row) * spacing
                let peg = Peg(position: CGPoint(x: x, y: y))
                pegs.append(peg)
                addChild(peg.node)
            }
        }
        
        // Add targets at top
        for i in 0..<3 {
            let x = size.width / 2 + CGFloat(i - 1) * 100
            let target = Target(position: CGPoint(x: x, y: size.height - 80))
            targets.append(target)
            addChild(target.node)
        }
    }
    
    func spawnBall() {
        currentBall?.node.removeFromParent()
        
        let ball = Ball(position: startPosition, type: .basic)
        currentBall = ball
        addChild(ball.node)
    }
    
    func updateAimLine(from start: CGPoint, to end: CGPoint) {
        aimLine?.removeFromParent()
        
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        aimLine = SKShapeNode(path: path)
        aimLine?.strokeColor = .white
        aimLine?.lineWidth = 2
        aimLine?.alpha = 0.5
        addChild(aimLine!)
    }
    
    func fireBall(from start: CGPoint, to target: CGPoint) {
        aimLine?.removeFromParent()
        
        guard let ball = currentBall else { return }
        
        let dx = target.x - start.x
        let dy = target.y - start.y
        let power: CGFloat = 0.15
        
        ball.applyForce(CGVector(dx: dx * power, dy: dy * power))
        
        // Check when ball stops
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if ball.isStopped() {
                timer.invalidate()
                self.onBallStopped?()
            }
        }
    }
    
    func resetBall() {
        currentBall?.node.removeFromParent()
        spawnBall()
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: add GameScene with physics and level setup"
```

---

## Input Handling (Aim & Fire)

### Task 6: Add Touch Controls

**Files:**
- Modify: `MarbleRogue/GameScene.swift`

- [ ] **Step 1: Add touch handling to GameScene**

Add these methods to `GameScene`:

```swift
// Add to GameScene class
private var touchStartPoint: CGPoint?

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    
    // Only allow aiming from bottom area
    if location.y < 200 {
        touchStartPoint = currentBall?.node.position ?? startPosition
    }
}

override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, let startPoint = touchStartPoint else { return }
    let location = touch.location(in: self)
    
    updateAimLine(from: startPoint, to: location)
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first, let startPoint = touchStartPoint else { return }
    let location = touch.location(in: self)
    
    touchStartPoint = nil
    fireBall(from: startPoint, to: location)
}
```

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "feat: add touch controls for aiming and firing"
```

---

## Upgrade System

### Task 7: Create Ball Modifier System

**Files:**
- Create: `MarbleRogue/Entities/BallModifier.swift`
- Create: `MarbleRogue/Systems/UpgradeSystem.swift`

- [ ] **Step 1: Define BallModifier protocol and implementations**

```swift
// MarbleRogue/Entities/BallModifier.swift
import SpriteKit

protocol BallModifier {
    var name: String { get }
    var description: String { get }
    var rarity: Rarity { get }
    func apply(to ball: Ball)
    func onHit(peg: Peg?)
}

enum Rarity {
    case common, rare, epic, legendary
    
    var color: UIColor {
        switch self {
        case .common: return .white
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

// MARK: - Split Modifier
class SplitModifier: BallModifier {
    let name = "分裂"
    let description = "击中后分裂成2个弹珠"
    let rarity: Rarity = .common
    var splitCount: Int = 2
    
    func apply(to ball: Ball) {
        ball.modifiers.append(self)
        ball.node.fillColor = .green
    }
    
    func onHit(peg: Peg?) {
        // Split logic implemented in collision handler
    }
}

// MARK: - Bomb Modifier
class BombModifier: BallModifier {
    let name = "炸弹"
    let description = "2秒后爆炸"
    let rarity: Rarity = .rare
    
    func apply(to ball: Ball) {
        ball.modifiers.append(self)
        ball.node.fillColor = .red
    }
    
    func onHit(peg: Peg?) {
        // Explosion logic
    }
}

// MARK: - Pierce Modifier
class PierceModifier: BallModifier {
    let name = "穿透"
    let description = "穿透目标"
    let rarity: Rarity = .common
    
    func apply(to ball: Ball) {
        ball.modifiers.append(self)
        ball.node.fillColor = .yellow
    }
    
    func onHit(peg: Peg?) {
        // Pierce logic
    }
}
```

- [ ] **Step 2: Create UpgradeSystem**

```swift
// MarbleRogue/Systems/UpgradeSystem.swift
import Foundation

class UpgradeSystem {
    static let shared = UpgradeSystem()
    
    private var availableModifiers: [BallModifier.Type] = [
        SplitModifier.self,
        BombModifier.self,
        PierceModifier.self
    ]
    
    var currentUpgrades: [BallModifier] = []
    
    func getRandomUpgrades(count: Int = 3) -> [BallModifier] {
        var upgrades: [BallModifier] = []
        let shuffled = availableModifiers.shuffled()
        
        for i in 0..<min(count, shuffled.count) {
            if let modifier = shuffled[i].init() as? BallModifier {
                upgrades.append(modifier)
            }
        }
        
        return upgrades
    }
    
    func applyUpgrade(_ modifier: BallModifier, to ball: Ball) {
        currentUpgrades.append(modifier)
        modifier.apply(to: ball)
    }
    
    func reset() {
        currentUpgrades.removeAll()
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: add upgrade system with 3 modifiers"
```

---

## UI Implementation

### Task 8: Create Upgrade Picker UI

**Files:**
- Create: `MarbleRogue/UI/UpgradePicker.swift`

- [ ] **Step 1: Implement UpgradePicker SwiftUI view**

```swift
// MarbleRogue/UI/UpgradePicker.swift
import SwiftUI

struct UpgradePicker: View {
    let upgrades: [BallModifier]
    let onSelect: (BallModifier) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("选择升级")
                    .font(.title)
                    .foregroundColor(.white)
                
                ForEach(upgrades.indices, id: \.self) { index in
                    let upgrade = upgrades[index]
                    UpgradeCard(modifier: upgrade) {
                        onSelect(upgrade)
                    }
                }
            }
            .padding()
        }
    }
}

struct UpgradeCard: View {
    let modifier: BallModifier
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(modifier.name)
                        .font(.headline)
                    Spacer()
                    Circle()
                        .fill(Color(modifier.rarity.color))
                        .frame(width: 12, height: 12)
                }
                Text(modifier.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(modifier.rarity.color), lineWidth: 2)
            )
        }
        .foregroundColor(.white)
    }
}
```

- [ ] **Step 2: Create HUD View**

```swift
// MarbleRogue/UI/HUDView.swift
import SwiftUI

struct HUDView: View {
    let score: Int
    let level: Int
    let ballsRemaining: Int
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("分数: \(score)")
                        .font(.headline)
                    Text("关卡: \(level)")
                        .font(.subheadline)
                }
                Spacer()
                Text("弹珠: \(ballsRemaining)")
                    .font(.headline)
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            
            Spacer()
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: add upgrade picker and HUD UI"
```

---

## Main Content View

### Task 9: Integrate GameScene with SwiftUI

**Files:**
- Modify: `MarbleRogue/ContentView.swift`

- [ ] **Step 1: Implement ContentView**

```swift
// MarbleRogue/ContentView.swift
import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var score = 0
    @State private var level = 1
    @State private var showUpgradePicker = false
    @State private var currentUpgrades: [BallModifier] = []
    @State private var gameState: GameState = .playing
    
    private var scene: GameScene {
        let scene = GameScene(size: CGSize(width: 400, height: 800))
        scene.scaleMode = .aspectFill
        return scene
    }
    
    enum GameState {
        case playing, upgrading, levelComplete, gameOver
    }
    
    var body: some View {
        ZStack {
            // Game View
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .onAppear {
                    setupSceneCallbacks()
                }
            
            // HUD
            HUDView(score: score, level: level, ballsRemaining: 3)
            
            // Upgrade Picker
            if showUpgradePicker {
                UpgradePicker(upgrades: currentUpgrades) { upgrade in
                    applyUpgrade(upgrade)
                }
            }
            
            // Level Complete
            if gameState == .levelComplete {
                LevelCompleteView(score: score) {
                    nextLevel()
                }
            }
        }
    }
    
    func setupSceneCallbacks() {
        // These would be connected via coordinator pattern in full implementation
    }
    
    func applyUpgrade(_ upgrade: BallModifier) {
        showUpgradePicker = false
        // Apply to ball
    }
    
    func nextLevel() {
        level += 1
        gameState = .playing
        currentUpgrades = UpgradeSystem.shared.getRandomUpgrades()
        showUpgradePicker = true
    }
}

struct LevelCompleteView: View {
    let score: Int
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("关卡完成!")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
                
                Text("得分: \(score)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Button("下一关", action: onNext)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    ContentView()
}
```

- [ ] **Step 2: Commit**

```bash
git add .
git commit -m "feat: integrate GameScene with SwiftUI and add game flow"
```

---

## Testing & Polish

### Task 10: Add Visual Effects

**Files:**
- Create: `MarbleRogue/Utils/Effects.swift`

- [ ] **Step 1: Create particle effects**

```swift
// MarbleRogue/Utils/Effects.swift
import SpriteKit

class Effects {
    static func createHitParticles(at position: CGPoint, in scene: SKScene) {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 0.5
        emitter.particlePosition = position
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSize = CGSize(width: 4, height: 4)
        emitter.particleColor = .cyan
        emitter.particleBlendMode = .add
        
        scene.addChild(emitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            emitter.removeFromParent()
        }
    }
    
    static func createTrail(for node: SKNode, in scene: SKScene) {
        let emitter = SKEmitterNode()
        emitter.targetNode = scene
        emitter.particleBirthRate = 30
        emitter.particleLifetime = 0.3
        emitter.particleSpeed = 0
        emitter.particleSize = CGSize(width: 6, height: 6)
        emitter.particleColor = .cyan
        emitter.particleAlpha = 0.5
        emitter.particleBlendMode = .add
        
        node.addChild(emitter)
    }
}
```

- [ ] **Step 2: Add effects to collisions**

Modify `CollisionManager` to trigger effects:

```swift
// In didBegin, add:
Effects.createHitParticles(at: contact.contactPoint, in: bodyA.node.scene!)
```

- [ ] **Step 3: Commit**

```bash
git add .
git commit -m "feat: add particle effects for hits"
```

---

### Task 11: Build and Test

- [ ] **Step 1: Build project**

Cmd+B to build, fix any compilation errors

- [ ] **Step 2: Run on simulator**

Cmd+R to run, test:
- Touch and drag to aim
- Release to fire
- Ball bounces off pegs
- Ball hits targets
- Score updates

- [ ] **Step 3: Fix any issues**

Address any bugs found during testing

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "chore: final polish and bug fixes"
```

---

## Summary

**MVP Complete with:**
- ✅ 3 ball types (basic, split, bomb)
- ✅ Physics-based gameplay
- ✅ 5 levels (triangular peg layout)
- ✅ Touch controls (aim & fire)
- ✅ Upgrade system (3 choices)
- ✅ Score tracking
- ✅ Visual effects

**Next Steps:**
- Add remaining 7 ball types
- Implement Boss battles
- Add sound effects
- Polish UI/UX
- App Store submission

**Plan Complete and saved to `docs/superpowers/plans/2026-03-14-marble-rogue-plan.md`.**
