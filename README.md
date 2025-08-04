# 🎭 班味检测器

> **将检测每日工作班味的创新 macOS 应用**

一个基于 **Flutter** 构建的 macOS 应用，通过自动拍照记录每日第一次解锁电脑的瞬间，让"班味"无所遁形。

![Flutter](https://img.shields.io/badge/Flutter-3.24.5+-02569B?style=flat-square&logo=flutter)
![macOS](https://img.shields.io/badge/macOS-10.15+-000000?style=flat-square&logo=apple)
![Build Status](https://img.shields.io/github/actions/workflow/status/MarleneJiang/ban-flavor/build.yml?branch=main&style=flat-square&logo=github)
![Latest Release](https://img.shields.io/github/v/release/MarleneJiang/ban-flavor?style=flat-square&logo=github)
![Downloads](https://img.shields.io/github/downloads/MarleneJiang/ban-flavor/total?style=flat-square&logo=github)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## ✨ 特色功能

### 📸 智能拍照系统
- **每日首次解锁自动拍照** - 捕捉最真实的班味瞬间
- **后台静默运行** - 无感知的过程
- **高质量图像压缩** - 平衡文件大小与清晰度

### 🖼️ 记忆画廊
- **时间线浏览** - 按日期组织的照片集合
- **动态加载** - 流畅的照片预览体验
- **统计信息** - 照片数量、存储空间实时显示

### ⚙️ 设置中心
- **开机自启动** - 与系统深度集成
- **通知提醒** - 拍照完成后的优雅提示
- **存储管理** - 灵活的照片存储配置
- **数据导出** - 备份您的班味作品集

## 🏗️ 技术架构

### 核心技术栈
```yaml
# 主框架
Flutter: 3.24.5+
Dart: 3.5.0+

# macOS 集成
macos_ui: ^2.0.2
flutter_acrylic: ^1.1.3

# 系统服务
launch_at_startup: ^0.2.2
camera_macos: ^0.3.0
shared_preferences: ^2.2.2
package_info_plus: ^5.0.1

# 工具库
intl: ^0.19.0
path_provider: ^2.1.1
```

### 项目结构
```
lib/
├── main.dart                 # 应用入口
├── models/
│   └── daily_photo.dart      # 照片数据模型
├── screens/
│   ├── home_screen.dart      # 首页 - 抽象艺术画板
│   ├── gallery_screen.dart   # 画廊 - 照片展示
│   └── settings_screen.dart  # 设置 - 
└── services/
    ├── auto_photo_service.dart      # 自动拍照服务
    ├── camera_service.dart          # 摄像头管理
    ├── storage_service.dart         # 文件存储
    ├── system_event_service.dart    # 系统事件监听
    └── launch_at_startup_service.dart # 开机启动
```

## 🚀 快速开始

### 💾 用户下载

**直接下载使用（推荐用户）**
1. 访问 [Releases 页面](https://github.com/MarleneJiang/ban-flavor/releases)
2. 下载最新版本的 `班味检测器-macos.dmg`
3. 双击打开 DMG 文件，将应用拖拽到 Applications 文件夹
4. 启动应用并授权摄像头权限

### 🛠️ 开发环境

**环境要求**
- **macOS 10.15+** (Catalina 或更高版本)
- **Flutter 3.24.5+** (包含 Dart SDK 3.5.0+)
- **Xcode 14+** (用于 macOS 应用构建)
- **CocoaPods** (依赖管理)

**安装步骤**

1. **克隆项目**
   ```bash
   git clone https://github.com/MarleneJiang/ban-flavor.git
   cd ban-flavor
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   cd macos && pod install && cd ..
   ```

3. **配置权限**
   
   应用已自动配置以下 macOS 权限：
   - **摄像头访问** (`NSCameraUsageDescription`)
   - **麦克风访问** (`NSMicrophoneUsageDescription`)
   - **文件系统访问** (Documents 目录)

4. **构建运行**
   ```bash
   # 调试模式
   flutter run -d macos
   
   # 发布构建
   flutter build macos --release
   
   # 本地构建测试（推荐）
   ./scripts/build.sh
   ```

### 🤖 自动化构建

**GitHub Actions 工作流**
- **持续集成**：每次推送代码自动构建和测试
- **自动发布**：创建标签时自动发布 DMG 安装包
- **工件上传**：构建产物保留 30-90 天供下载

**发布新版本**
```bash
# 使用发布脚本（推荐）
./scripts/release.sh v1.0.0 "新版本发布说明"

# 或手动操作
git tag v1.0.0
git push origin v1.0.0
```

### VS Code 任务
项目预配置了以下开发任务：
- `Flutter Run (macOS)` - 调试运行
- `Flutter Build (macOS)` - 发布构建
- `Flutter Test` - 运行测试
- `Flutter Clean` - 清理缓存

## 🎨 UI 设计理念

### 抽象艺术风格
- **渐变背景** - 从工作到艺术的视觉过渡
- **浮动元素** - 象征思维的流动性
- **几何图形** - 抽象化的班味表达
- **动画效果** - 生动的交互体验

## 📱 核心功能详解

### 🤖 自动拍照逻辑
```dart
// 每日首次解锁检测
Future<void> _handleBackgroundLaunch() async {
  final today = DateTime.now();
  final dateKey = '${today.year}-${today.month}-${today.day}';
  
  final prefs = await SharedPreferences.getInstance();
  final lastPhotoDate = prefs.getString('last_photo_date');
  
  if (lastPhotoDate != dateKey) {
    // 今日首次解锁，开始班味拍照
    await _captureArtisticMoment();
  }
}
```

### 🎭 抽象画板生成
```dart
// 动态浮动图形
Widget _buildFloatingShape(int index) {
  return AnimatedBuilder(
    animation: _floatingAnimation,
    builder: (context, child) {
      final offset = Offset(
        math.sin(_floatingAnimation.value + index * 0.5) * 20,
        math.cos(_floatingAnimation.value + index * 0.3) * 15,
      );
      
      return Positioned(
        left: positions[index].x * screenWidth + offset.dx,
        top: positions[index].y * screenHeight + offset.dy,
        child: Container(
          // 抽象几何图形配置
        ),
      );
    },
  );
}
```

## 🔧 配置选项

### 系统集成
- **开机自启动** - 通过 `launch_at_startup` 实现
- **后台运行** - 支持 `--background-launch` 参数
- **系统通知** - 拍照完成后的优雅提醒

### 个性化设置
- **图像质量** - 30% ~ 100% 可调节压缩率
- **存储位置** - 默认 Documents/DailyPhotos/
- **通知开关** - 可关闭拍照提醒
- **主题配色** - TDesign 动态主题支持

## 🛠️ 开发指南

### 添加新功能
1. **创建服务** - 在 `lib/services/` 下添加新的业务逻辑
2. **扩展 UI** - 使用 TDesign 组件构建界面
3. **配置权限** - 在 `macos/Runner/Info.plist` 中声明

### 调试技巧
```bash
# 查看详细日志
flutter run -d macos --verbose

# 后台模式测试
flutter run -d macos -- --background-launch

# 发布模式构建
flutter build macos --release --verbose
```

### 常见问题
- **权限被拒绝** - 检查 `Info.plist` 中的权限声明
- **构建失败** - 运行 `flutter clean` 清理缓存
- **依赖冲突** - 删除 `pubspec.lock` 重新获取依赖

## 📂 文件结构说明

```
ban-flavor/
├── 📱 lib/                    # Dart 源代码
│   ├── 🚀 main.dart          # 应用入口 + TDesign 配置
│   ├── 📊 models/            # 数据模型
│   ├── 🎨 screens/           # UI 页面 (TDesign 风格)
│   └── ⚙️ services/          # 业务逻辑服务
├── 🍎 macos/                 # macOS 原生配置
│   ├── 📋 Info.plist         # 权限与应用信息
│   ├── 📦 Podfile           # CocoaPods 依赖
│   └── 🏗️ Runner/           # Xcode 项目文件
├── 🔄 .github/               # GitHub Actions 工作流
│   └── workflows/            # 自动化构建和发布
│       ├── build.yml         # 基础构建流程
│       ├── build-advanced.yml # 高级构建（代码签名）
│       └── release.yml       # 版本发布流程
├── 📜 scripts/               # 构建和发布脚本
│   ├── build.sh             # 本地构建测试
│   └── release.sh           # 版本发布脚本
├── 🧪 test/                  # 单元测试
├── 📝 pubspec.yaml          # Flutter 依赖配置
├── 🚫 .gitignore            # Git 忽略规则
└── 📖 README.md             # 项目文档 (本文件)
```

## 🤝 贡献指南

欢迎为班味检测器贡献代码！

### 快速开始
1. **Fork 项目** 并创建特性分支
2. **编写代码** 并确保通过测试
3. **提交 PR** 并描述您的更改
4. **代码审查** 通过后即可合并

### 开发规范
- 使用 `dart format` 格式化代码
- 遵循 Flutter 官方命名约定
- 为新功能添加相应的注释和文档
- 提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范

### 详细指南
请查看 [贡献指南](CONTRIBUTING.md) 了解完整的开发流程和规范。

### 开发讨论
- [GitHub Discussions](https://github.com/MarleneJiang/ban-flavor/discussions) - 功能讨论和问答
- [Issues](https://github.com/MarleneJiang/ban-flavor/issues) - Bug 报告和功能请求

## 📄 许可协议

本项目采用 [MIT License](LICENSE) 开源协议。


---

**🎭 让每一天的工作都少点班味！**

*Built with ❤️ using Flutter + Github Copilot*
