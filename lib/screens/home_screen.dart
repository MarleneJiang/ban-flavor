import 'package:flutter/material.dart';
import '../screens/gallery_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/camera_preview_screen.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<GalleryScreenState> _galleryKey =
      GlobalKey<GalleryScreenState>();

  @override
  void initState() {
    super.initState();
    // 延迟检查并自动拍照
    Future.delayed(const Duration(milliseconds: 800), () {
      _checkAndTakeAutoPhoto();
    });
  }

  Future<void> _checkAndTakeAutoPhoto() async {
    try {
      print('🔍 检查今日是否已拍照...');
      final hasPhoto = await StorageService.hasPhotoToday();
      print('📊 检查结果: ${hasPhoto ? "今日已拍照" : "今日未拍照"}');

      if (!hasPhoto && mounted) {
        print('📸 准备启动自动拍照流程...');
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: 400,
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CameraPreviewScreen(
                    onPhotoTaken: (success) {
                      Navigator.of(dialogContext).pop(success);
                    },
                  ),
                ),
              ),
            );
          },
        );

        // 处理拍照结果
        if (mounted && result == true) {
          print('✅ 自动拍照成功，准备切换到画廊页面');

          // 确保在主线程中更新状态
          if (mounted) {
            setState(() {
              _selectedIndex = 1;
            });
            print('📱 已切换到画廊页面 (index: $_selectedIndex)');

            // 等待页面切换完成后再刷新画廊
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted && _galleryKey.currentState != null) {
              print('🔄 开始刷新画廊...');
              _galleryKey.currentState!.loadPhotos();
            } else {
              print('⚠️ 画廊状态为空，无法刷新');
            }
          }
        } else if (result == false) {
          print('❌ 自动拍照失败');
        } else {
          print('⚠️ 对话框被取消或返回空结果');
        }
      } else if (hasPhoto) {
        print('✓ 今日已拍照，无需重复拍摄');
      }
    } catch (e) {
      print('❌ 自动拍照检测出错: $e');
    }
  }

  void _onPhotoTaken(bool success) {
    if (success) {
      // 切换到画廊页面并刷新
      setState(() {
        _selectedIndex = 1;
      });
      _galleryKey.currentState?.loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      GalleryScreen(key: _galleryKey),
      SettingsScreen(onPhotoTaken: _onPhotoTaken),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            selectedIcon: Icon(Icons.auto_awesome_outlined),
            label: '班味探测',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark),
            selectedIcon: Icon(Icons.collections_bookmark_outlined),
            label: '时光胶囊',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            selectedIcon: Icon(Icons.tune_outlined),
            label: '调音台',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 主要图标动画区域
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // 主标题
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: const Text(
                        '班味检测仪',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ban Flavor Detector',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 副标题描述
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Column(
                  children: [
                    Text(
                      '🔬 量子级班味识别技术',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '每日首次解锁瞬间，自动捕获你的班味强度\n记录班瘾恢复过程中的微妙变化',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 状态指示器
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Text(
                      '检测器已就绪，等待下次解锁...',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
