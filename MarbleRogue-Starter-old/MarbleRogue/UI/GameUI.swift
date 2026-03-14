import SwiftUI

struct UpgradePicker: View {
    let upgrades: [BallModifier]
    let onSelect: (BallModifier) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("选择升级")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .purple, radius: 10)
                
                Text("为你的弹珠选择一个强化")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                ForEach(upgrades.indices, id: \.self) { index in
                    UpgradeCard(modifier: upgrades[index]) {
                        onSelect(upgrades[index])
                    }
                }
            }
            .padding(24)
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
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    
                    Text(modifier.rarity.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(modifier.rarity.color).opacity(0.3))
                        .foregroundColor(Color(modifier.rarity.color))
                        .cornerRadius(4)
                    
                    Circle()
                        .fill(Color(modifier.rarity.color))
                        .frame(width: 12, height: 12)
                        .shadow(color: Color(modifier.rarity.color), radius: 5)
                }
                
                Text(modifier.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(modifier.rarity.color), lineWidth: 2)
            )
        }
        .foregroundColor(.white)
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct HUDView: View {
    let score: Int
    let level: Int
    let ballsRemaining: Int
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                HUDItem(title: "分数", value: "\(score)", color: .yellow)
                HUDItem(title: "关卡", value: "\(level)", color: .cyan)
                HUDItem(title: "弹珠", value: "\(ballsRemaining)", color: .magenta)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

struct HUDItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("游戏结束")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .shadow(color: .red, radius: 10)
                
                VStack(spacing: 8) {
                    Text("最终得分")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("\(score)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow, radius: 10)
                }
                
                Button(action: onRestart) {
                    Text("重新开始")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                }
            }
        }
    }
}
