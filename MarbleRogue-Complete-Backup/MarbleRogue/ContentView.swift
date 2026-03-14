import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var gameState = GameStateManager()
    
    var body: some View {
        ZStack {
            GameView(gameState: gameState)
            
            HUDView(
                score: gameState.score,
                level: gameState.level,
                ballsRemaining: gameState.ballsRemaining
            )
            
            if gameState.showUpgradePicker {
                UpgradePicker(
                    upgrades: gameState.availableUpgrades,
                    onSelect: { upgrade in
                        gameState.selectUpgrade(upgrade)
                    }
                )
            }
            
            if gameState.isGameOver {
                GameOverView(
                    score: gameState.score,
                    onRestart: {
                        gameState.restart()
                    }
                )
            }
        }
    }
}

class GameStateManager: ObservableObject {
    @Published var score = 0
    @Published var level = 1
    @Published var ballsRemaining = 10
    @Published var showUpgradePicker = false
    @Published var isGameOver = false
    @Published var availableUpgrades: [BallModifier] = []
    
    private let upgradeSystem = UpgradeSystem()
    
    func levelComplete() {
        availableUpgrades = upgradeSystem.getRandomUpgrades(count: 3)
        showUpgradePicker = true
    }
    
    func selectUpgrade(_ upgrade: BallModifier) {
        upgradeSystem.applyUpgrade(upgrade)
        showUpgradePicker = false
        level += 1
        ballsRemaining = 10
    }
    
    func gameOver() {
        isGameOver = true
    }
    
    func restart() {
        score = 0
        level = 1
        ballsRemaining = 10
        isGameOver = false
        upgradeSystem.reset()
    }
    
    func addScore(_ points: Int) {
        score += points
    }
    
    func useBall() {
        ballsRemaining -= 1
        if ballsRemaining <= 0 {
            gameOver()
        }
    }
}

struct GameView: UIViewRepresentable {
    @ObservedObject var gameState: GameStateManager
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        
        let scene = GameScene(size: CGSize(width: 400, height: 800))
        scene.scaleMode = .aspectFill
        scene.gameState = gameState
        
        view.presentScene(scene)
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
}

#Preview {
    ContentView()
}
