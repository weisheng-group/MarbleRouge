import SpriteKit

protocol BallModifier {
    var id: String { get }
    var name: String { get }
    var description: String { get }
    var rarity: Rarity { get }
    func apply(to ball: Ball)
}

enum Rarity: CaseIterable {
    case common, rare, epic, legendary
    
    var color: UIColor {
        switch self {
        case .common: return .white
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var displayName: String {
        switch self {
        case .common: return "普通"
        case .rare: return "稀有"
        case .epic: return "史诗"
        case .legendary: return "传说"
        }
    }
}

// MARK: - Split Modifier
class SplitModifier: BallModifier {
    let id = "split"
    let name = "分裂"
    let description = "击中后分裂成2个弹珠"
    let rarity: Rarity = .common
    
    func apply(to ball: Ball) {
        ball.node.fillColor = .green
    }
}

// MARK: - Bomb Modifier
class BombModifier: BallModifier {
    let id = "bomb"
    let name = "炸弹"
    let description = "2秒后爆炸，范围伤害"
    let rarity: Rarity = .rare
    
    func apply(to ball: Ball) {
        ball.node.fillColor = .red
    }
}

// MARK: - Pierce Modifier
class PierceModifier: BallModifier {
    let id = "pierce"
    let name = "穿透"
    let description = "穿透目标继续飞行"
    let rarity: Rarity = .common
    
    func apply(to ball: Ball) {
        ball.node.fillColor = .yellow
        ball.node.physicsBody?.collisionBitMask = PhysicsCategory.wall
    }
}
