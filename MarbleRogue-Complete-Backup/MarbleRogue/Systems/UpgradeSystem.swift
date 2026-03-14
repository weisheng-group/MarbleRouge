import Foundation

class UpgradeSystem {
    static let shared = UpgradeSystem()
    
    private var availableModifiers: [BallModifier] = [
        SplitModifier(),
        BombModifier(),
        PierceModifier()
    ]
    
    private(set) var currentUpgrades: [BallModifier] = []
    
    func getRandomUpgrades(count: Int = 3) -> [BallModifier] {
        return availableModifiers.shuffled().prefix(count).map { $0 }
    }
    
    func applyUpgrade(_ modifier: BallModifier) {
        currentUpgrades.append(modifier)
    }
    
    func reset() {
        currentUpgrades.removeAll()
    }
    
    func createBallWithUpgrades(at position: CGPoint) -> Ball {
        let ball = Ball(position: position, type: .basic)
        for upgrade in currentUpgrades {
            ball.applyModifier(upgrade)
        }
        return ball
    }
}
