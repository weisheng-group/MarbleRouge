# MarbleRogue - 完整Xcode项目

## 🚀 快速开始

1. **下载项目**
   ```bash
   git clone git@github.com:weisheng-group/MarbleRogue.git
   cd MarbleRogue
   ```

2. **打开项目**
   - 双击 `MarbleRogue.xcodeproj`
   - 或 Xcode → File → Open → 选择 `MarbleRogue.xcodeproj`

3. **运行**
   - 选择 iPhone 15 Pro 模拟器
   - 按 `Cmd+R`

## 📁 项目结构

```
MarbleRogue/
├── MarbleRogue.xcodeproj      # 项目文件
└── MarbleRogue/
    ├── App.swift              # App入口
    ├── ContentView.swift      # 主视图
    ├── GameScene.swift        # 游戏场景
    ├── Assets.xcassets/       # 资源
    ├── Entities/              # 游戏实体
    │   ├── Ball.swift
    │   ├── Peg.swift
    │   ├── Target.swift
    │   └── BallModifier.swift
    ├── Systems/               # 游戏系统
    │   └── UpgradeSystem.swift
    ├── UI/                    # 用户界面
    │   └── GameUI.swift
    └── Utils/                 # 工具
        └── Constants.swift
```

## 🎮 操作说明

| 操作 | 说明 |
|------|------|
| 按住屏幕底部 | 瞄准 |
| 向后拖动 | 拉弓蓄力 |
| 松开 | 发射弹珠 |
| 击中钉子 | 弹跳得分 |
| 击中目标 | 获得分数 |
| 清除所有目标 | 进入升级选择 |

## 🔧 系统要求

- macOS 14.0+
- Xcode 15.0+
- iOS 16.0+

## 📝 注意事项

- 项目使用 SwiftUI + SpriteKit
- 竖屏 only
- 首次运行可能需要等待 Swift 编译
