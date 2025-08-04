# 🤝 贡献指南

欢迎为班味检测器贡献代码！本文档将帮助您了解如何参与项目开发。

## 📋 开发环境设置

### 系统要求
- macOS 10.15+ (Catalina 或更高版本)
- Flutter 3.24.5+ (包含 Dart SDK 3.5.0+)
- Xcode 14+
- Git

### 环境配置
1. **Fork 和克隆项目**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ban-flavor.git
   cd ban-flavor
   git remote add upstream https://github.com/MarleneJiang/ban-flavor.git
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   cd macos && pod install && cd ..
   ```

3. **运行测试**
   ```bash
   flutter test
   ```

4. **本地构建**
   ```bash
   ./scripts/build.sh
   ```

## 🔄 开发流程

### 创建功能分支
```bash
git checkout main
git pull upstream main
git checkout -b feature/your-feature-name
```

### 提交代码
```bash
# 遵循 Conventional Commits 规范
git commit -m "feat: 添加新功能描述"
git commit -m "fix: 修复某个bug"
git commit -m "docs: 更新文档"
git commit -m "chore: 更新依赖"
```

### 提交 Pull Request
1. 推送分支到您的 Fork
2. 在 GitHub 上创建 Pull Request
3. 填写详细的 PR 描述
4. 等待代码审查

## 📝 代码规范

### Dart 代码风格
- 使用 `dart format` 格式化代码
- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南
- 为公共 API 添加文档注释

### 文件命名
- 使用 snake_case 命名文件
- 服务类以 `_service.dart` 结尾
- 屏幕类以 `_screen.dart` 结尾
- 模型类以 `.dart` 结尾

### 目录结构
```
lib/
├── models/          # 数据模型
├── screens/         # UI 屏幕
├── services/        # 业务逻辑服务
└── utils/           # 工具类
```

## 🧪 测试指南

### 单元测试
- 为新功能编写对应的单元测试
- 测试文件命名: `xxx_test.dart`
- 使用 `flutter test` 运行测试

### 集成测试
- 在 `test/` 目录下添加集成测试
- 测试关键用户流程

## 🚀 构建和发布

### 本地构建
```bash
# 快速构建测试
./scripts/build.sh

# 手动构建
flutter build macos --release
```

### 版本发布
```bash
# 使用发布脚本
./scripts/release.sh v1.1.0 "新版本功能说明"
```

## 🐛 Bug 报告

### 报告 Bug
1. 在 [Issues](https://github.com/MarleneJiang/ban-flavor/issues) 页面创建新 issue
2. 使用 Bug Report 模板
3. 提供详细的复现步骤
4. 附上系统信息和截图

### Bug 修复流程
1. 创建 `fix/bug-description` 分支
2. 修复问题并添加测试
3. 提交 PR 并引用对应的 issue

## ✨ 功能请求

### 提交功能建议
1. 在 Issues 页面创建 Feature Request
2. 详细描述功能需求和使用场景
3. 讨论实现方案

### 实现新功能
1. 确保功能请求已被接受
2. 创建 `feature/feature-name` 分支
3. 实现功能并添加相应的测试和文档
4. 提交 PR

## 🏷️ 提交消息规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 提交类型
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码风格调整（不影响功能）
- `refactor`: 重构代码
- `test`: 添加或修改测试
- `chore`: 构建过程或辅助工具的变动

### 示例
```
feat(camera): 添加照片质量设置选项

允许用户在设置中调整照片压缩质量，范围从 30% 到 100%。

Closes #123
```

## 🔍 代码审查

### 审查清单
- [ ] 代码符合项目风格指南
- [ ] 包含适当的测试
- [ ] 文档已更新
- [ ] 无明显的性能问题
- [ ] 兼容目标 macOS 版本

### 审查流程
1. 提交者自查代码
2. 维护者进行代码审查
3. 根据反馈修改代码
4. 审查通过后合并

## 📚 开发资源

### 相关文档
- [Flutter 官方文档](https://flutter.dev/docs)
- [macOS 开发指南](https://developer.apple.com/macos/)
- [Dart 语言规范](https://dart.dev/guides)

### 有用的工具
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools)
- [Dart Code (VS Code 扩展)](https://dartcode.org/)
- [Flutter Inspector](https://flutter.dev/docs/development/tools/devtools/inspector)

## 🎯 路线图

### 计划中的功能
- [ ] 云同步支持
- [ ] 多用户配置
- [ ] 高级图像滤镜
- [ ] 数据分析仪表板
- [ ] 跨平台支持 (Windows/Linux)

### 长期目标
- [ ] AI 驱动的"班味"分析
- [ ] 团队协作功能
- [ ] 插件系统

## 💬 社区

### 讨论平台
- [GitHub Discussions](https://github.com/MarleneJiang/ban-flavor/discussions) - 功能讨论和问答
- [Issues](https://github.com/MarleneJiang/ban-flavor/issues) - Bug 报告和功能请求

### 贡献者认证
感谢所有贡献者的努力！您的贡献将被记录在项目的 Contributors 页面。

---

**感谢您的贡献！让我们一起让班味检测器变得更好！** 🎭
