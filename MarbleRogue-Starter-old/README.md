# Marble Rogue - Xcode 导入指南

## 🚀 快速开始（5分钟）

### 1. 创建Xcode项目

打开Xcode → File → New → Project → iOS → **Game**

配置：
- **Product Name:** MarbleRogue
- **Team:** 你的Apple ID
- **Organization Identifier:** com.yourname
- **Interface:** SwiftUI
- **Game Technology:** SpriteKit
- **Language:** Swift

### 2. 导入源代码

将本文件夹中的所有 `.swift` 文件拖入Xcode项目：

```
MarbleRogue/
├── App.swift                    → 替换现有App.swift
├── ContentView.swift            → 替换现有ContentView.swift
├── GameScene.swift              → 拖入根目录
├── Entities/
│   ├── Ball.swift               → 创建Entities组，拖入
│   ├── Peg.swift
│   ├── Target.swift
│   └── BallModifier.swift
├── Systems/
│   └── UpgradeSystem.swift      → 创建Systems组，拖入
├── UI/
│   └── GameUI.swift             → 创建UI组，拖入
└── Utils/
    └── Constants.swift          → 创建Utils组，拖入
```

### 3. 项目设置

选中项目 → Targets → MarbleRogue → General:

**Deployment Info:**
- iOS: 16.0+
- Device Orientation: ☑️ Portrait (只保留竖屏)
- Status Bar Style: Hide status bar

**Signing & Capabilities:**
- Team: 选择你的Apple ID
- Bundle Identifier: 自动生成即可

### 4. 构建运行

- 选择目标设备（iPhone 15 Pro 模拟器）
- 按 `Cmd+R` 运行

---

## 🎮 操作说明

| 操作 | 说明 |
|------|------|
| 按住屏幕底部 | 瞄准 |
| 拖动 | 调整发射角度 |
| 松开 | 发射弹珠 |
| 击中目标 | 得分 |
| 清除所有目标 | 进入升级选择 |

---

## 📁 项目结构

```
MarbleRogue/
├── App.swift              # App入口
├── ContentView.swift      # SwiftUI主视图
├── GameScene.swift        # SpriteKit游戏场景
├── Entities/              # 游戏实体
│   ├── Ball.swift         # 弹珠
│   ├── Peg.swift          # 钉子
│   ├── Target.swift       # 目标
│   └── BallModifier.swift # 升级修饰器
├── Systems/               # 游戏系统
│   └── UpgradeSystem.swift # 升级系统
├── UI/                    # 用户界面
│   └── GameUI.swift       # 游戏UI组件
└── Utils/                 # 工具
    └── Constants.swift    # 常量定义
```

---

## 🔧 常见问题

### Q: 编译错误 "Cannot find type 'BallModifier'"
A: 确保所有文件都添加到Target中。选中文件 → File Inspector → Target Membership → ☑️ MarbleRogue

### Q: 画面显示不正常
A: 检查GameScene.swift中的`size`参数，确保与设备屏幕比例匹配

### Q: 物理效果不对
A: 在模拟器菜单 → Debug → 取消 "Slow Animations"

---

## 🎯 Day 1 任务

完成导入后，今天的目标：

- [ ] 项目能编译运行
- [ ] 弹珠能发射
- [ ] 弹珠能弹跳
- [ ] 能击中目标得分

完成后拍照/录屏发给我确认！

---

## 📱 真机测试

准备上架前需要在真机上测试：

1. 连接iPhone到Mac
2. Xcode → Window → Devices and Simulators
3. 选择你的iPhone作为目标
4. Cmd+R 运行

注意：需要Apple Developer账号（$99/年）才能真机调试

---

**有问题立即飞书我！**
