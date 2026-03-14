import SpriteKit

struct PhysicsCategory {
    static let ball: UInt32 = 0x1 << 0
    static let peg: UInt32 = 0x1 << 1
    static let target: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
}
