#!/bin/bash

# 版本发布脚本
# 使用方法: ./scripts/release.sh v1.0.0 "发布说明"

set -e

# 检查参数
if [ $# -lt 1 ]; then
    echo "❌ 使用方法: $0 <version> [release_notes]"
    echo "   示例: $0 v1.0.0 \"新版本发布\""
    exit 1
fi

VERSION=$1
RELEASE_NOTES=${2:-"## 🎭 新版本发布\n\n### ✨ 更新内容\n- 修复已知问题\n- 性能优化\n- 用户体验改进"}

echo "🚀 准备发布版本: $VERSION"

# 检查是否有未提交的更改
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  有未提交的更改，请先提交："
    git status --short
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查当前分支
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  当前不在 main 分支 (当前: $CURRENT_BRANCH)"
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 更新版本号
echo "📝 更新 pubspec.yaml 版本号..."
VERSION_NO_V="${VERSION#v}"
BUILD_NUMBER=$(date +%Y%m%d%H%M)

# 备份原文件
cp pubspec.yaml pubspec.yaml.bak

# 更新版本
sed -i '' "s/^version: .*/version: ${VERSION_NO_V}+${BUILD_NUMBER}/" pubspec.yaml

echo "✅ 版本已更新为: ${VERSION_NO_V}+${BUILD_NUMBER}"

# 显示更改
echo "📋 版本更改预览:"
diff pubspec.yaml.bak pubspec.yaml || true

# 确认发布
echo
read -p "🤔 确认发布版本 $VERSION 吗？(y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 发布已取消，恢复原版本"
    mv pubspec.yaml.bak pubspec.yaml
    exit 1
fi

# 删除备份文件
rm pubspec.yaml.bak

# 运行测试
echo "🧪 运行测试..."
if ! flutter test; then
    echo "❌ 测试失败，发布中止"
    exit 1
fi

# 提交版本更改
echo "💾 提交版本更改..."
git add pubspec.yaml
git commit -m "chore: bump version to $VERSION"

# 创建标签
echo "🏷️  创建标签 $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

# 推送到远程
echo "📤 推送到 GitHub..."
git push origin main
git push origin "$VERSION"

echo
echo "🎉 版本 $VERSION 发布成功！"
echo "📦 GitHub Actions 将自动构建并发布安装包"
echo "🔗 查看发布状态: https://github.com/MarleneJiang/ban-flavor/actions"
echo "📱 发布页面: https://github.com/MarleneJiang/ban-flavor/releases/tag/$VERSION"
