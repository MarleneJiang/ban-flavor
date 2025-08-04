#!/bin/bash

# 本地构建脚本
# 用于测试 GitHub Actions 构建流程

set -e

echo "🛠️  开始本地构建测试..."

# 检查 Flutter 环境
echo "📋 检查 Flutter 环境..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装或不在 PATH 中"
    exit 1
fi

flutter --version

# 清理之前的构建
echo "🧹 清理构建缓存..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

# 安装 CocoaPods 依赖
echo "🍎 安装 macOS 依赖..."
cd macos
pod install
cd ..

# 运行测试
echo "🧪 运行测试..."
flutter test

# 构建应用
echo "🔨 构建 macOS 应用..."
flutter build macos --release

# 检查构建结果
APP_PATH="build/macos/Build/Products/Release/ban_flavor_detector.app"
if [ -d "$APP_PATH" ]; then
    echo "✅ 应用构建成功: $APP_PATH"
    
    # 显示应用信息
    echo "📱 应用信息:"
    ls -la "$APP_PATH"
    echo "   Bundle ID: $(defaults read "$(pwd)/$APP_PATH/Contents/Info.plist" CFBundleIdentifier)"
    echo "   Version: $(defaults read "$(pwd)/$APP_PATH/Contents/Info.plist" CFBundleShortVersionString)"
    
    # 创建 DMG
    echo "💽 创建 DMG 安装包..."
    mkdir -p dmg_temp
    cp -R "$APP_PATH" dmg_temp/
    ln -sf /Applications dmg_temp/Applications
    
    DMG_NAME="班味检测器-本地构建-$(date +%Y%m%d).dmg"
    hdiutil create -volname "班味检测器" \
      -srcfolder dmg_temp \
      -ov -format UDZO \
      "$DMG_NAME"
      
    if [ -f "$DMG_NAME" ]; then
        echo "✅ DMG 创建成功: $DMG_NAME"
        echo "📏 文件大小: $(ls -lh "$DMG_NAME" | awk '{print $5}')"
    fi
    
    # 清理临时文件
    rm -rf dmg_temp
    
else
    echo "❌ 应用构建失败"
    exit 1
fi

echo
echo "🎉 本地构建完成！"
echo "📦 可执行文件: $APP_PATH"
if [ -f "$DMG_NAME" ]; then
    echo "💽 安装包: $DMG_NAME"
fi
echo
echo "🚀 测试应用:"
echo "   open '$APP_PATH'"
echo
echo "🔧 调试模式运行:"
echo "   flutter run -d macos"
