import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/launch_at_startup_service.dart';
import 'camera_preview_screen.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onPhotoTaken;
  const SettingsScreen({super.key, this.onPhotoTaken});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _launchAtStartup = false;
  bool _enableNotifications = true;
  double _imageQuality = 0.8;
  bool _isLoading = true;
  bool _isTakingPhoto = false;
  PermissionStatus _cameraPermissionStatus = PermissionStatus.denied;
  PermissionStatus _microphonePermissionStatus = PermissionStatus.denied;
  bool _isCheckingPermissions = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _loadSettings();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final startupEnabled = await LaunchAtStartupService.isEnabled();
      final cameraStatus = await Permission.camera.status;
      final microphoneStatus = await Permission.microphone.status;
      setState(() {
        _launchAtStartup = startupEnabled;
        _cameraPermissionStatus = cameraStatus;
        _microphonePermissionStatus = microphoneStatus;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleStartup(bool value) async {
    try {
      await LaunchAtStartupService.setEnabled(value);
      setState(() {
        _launchAtStartup = value;
      });
    } catch (e) {
      print('Error toggling startup: $e');
    }
  }

  Future<void> _takePhotoManually() async {
    if (_isTakingPhoto) return;

    setState(() {
      _isTakingPhoto = true;
    });

    try {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) =>
              CameraPreviewScreen(onPhotoTaken: widget.onPhotoTaken),
        ),
      );

      if (result == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('📸 手动拍照成功！已保存到画廊'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.white),
                  SizedBox(width: 8),
                  Text('📷 拍照失败或已取消'),
                ],
              ),
              backgroundColor: Color(0xFFF59E0B),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Manual photo error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('🚫 拍照出错: ${e.toString()}'),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPhoto = false;
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    if (_isCheckingPermissions) return;

    setState(() {
      _isCheckingPermissions = true;
    });

    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      setState(() {
        _cameraPermissionStatus =
            statuses[Permission.camera] ?? PermissionStatus.denied;
        _microphonePermissionStatus =
            statuses[Permission.microphone] ?? PermissionStatus.denied;
      });

      if (_cameraPermissionStatus.isGranted &&
          _microphonePermissionStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('✅ 权限已全部授予'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          _showPermissionDialog();
        }
      }
    } catch (e) {
      print('Permission request error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(child: Text('❌ 权限请求失败: ${e.toString()}')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPermissions = false;
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text('权限申请失败'),
            ],
          ),
          content: const Text(
            '班味检测仪需要同时拥有摄像头和麦克风权限才能正常工作。\n\n请在系统设置中手动开启所有权限。',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('打开系统设置'),
            ),
          ],
        );
      },
    );
  }

  String _getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '✅ 已授权';
      case PermissionStatus.denied:
        return '❌ 未授权';
      case PermissionStatus.permanentlyDenied:
        return '🚫 已永久拒绝';
      case PermissionStatus.restricted:
        return '⚠️ 受限制';
      case PermissionStatus.limited:
        return '⚠️ 受限';
      default:
        return '❓ 未知';
    }
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required PermissionStatus status,
  }) {
    final bool isGranted = status.isGranted;
    return ListTile(
      leading: Icon(
        icon,
        color: isGranted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        _getPermissionStatusText(status),
        style: TextStyle(
          color: isGranted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          fontSize: 13,
        ),
      ),
      trailing: isGranted
          ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
          : const Icon(Icons.error, color: Color(0xFFEF4444)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  '🔧 正在调试检测器参数...',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            '调音台',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部说明卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            '精密调节',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        '调整班味检测仪的灵敏度和工作模式\n让检测结果更加精准',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 手动拍照区域
                const Text(
                  '📸 手动操作',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            '立即捕捉',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '无需等待解锁，立即启动班味检测器\n手动记录当前的精神状态',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isTakingPhoto ? null : _takePhotoManually,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF10B981),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isTakingPhoto
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      '📷 正在拍照...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_enhance),
                                    SizedBox(width: 8),
                                    Text(
                                      '🎯 启动检测器',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 权限管理区域
                const Text(
                  '🔐 权限管理',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPermissionTile(
                        icon: Icons.camera_alt,
                        title: '摄像头权限',
                        status: _cameraPermissionStatus,
                      ),
                      const Divider(height: 1, indent: 50),
                      _buildPermissionTile(
                        icon: Icons.mic,
                        title: '麦克风权限',
                        status: _microphonePermissionStatus,
                      ),
                    ],
                  ),
                ),

                if (!_cameraPermissionStatus.isGranted ||
                    !_microphonePermissionStatus.isGranted)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _isCheckingPermissions
                            ? null
                            : _requestPermissions,
                        icon: _isCheckingPermissions
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.security),
                        label: Text(
                          _isCheckingPermissions ? '正在请求...' : '授予所需权限',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // 系统设置区域
                const Text(
                  '🔧 系统配置',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                        ),
                        child: SwitchListTile(
                          title: const Text(
                            '开机自启动',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: const Text(
                            '系统启动时自动激活检测器',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                          value: _launchAtStartup,
                          onChanged: _toggleStartup,
                          activeColor: const Color(0xFF6366F1),
                          secondary: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.rocket_launch,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      SwitchListTile(
                        title: const Text(
                          '检测提醒',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: const Text(
                          '完成检测后显示通知提醒',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        value: _enableNotifications,
                        onChanged: (value) {
                          setState(() {
                            _enableNotifications = value;
                          });
                        },
                        activeColor: const Color(0xFF6366F1),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 检测参数区域
                const Text(
                  '🎯 检测参数',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.high_quality,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '图像质量',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '${(_imageQuality * 100).round()}%',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF6366F1),
                          inactiveTrackColor: const Color(
                            0xFF6366F1,
                          ).withOpacity(0.2),
                          thumbColor: const Color(0xFF6366F1),
                          overlayColor: const Color(
                            0xFF6366F1,
                          ).withOpacity(0.2),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: _imageQuality,
                          onChanged: (value) {
                            setState(() {
                              _imageQuality = value;
                            });
                          },
                          divisions: 10,
                          min: 0.1,
                          max: 1.0,
                        ),
                      ),
                      const Text(
                        '更高的质量会占用更多存储空间',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 关于区域
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF6366F1),
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '关于',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        '班味检测仪 v1.0.0',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '基于量子级图像分析技术，精准捕获班瘾恢复过程中\n每日解锁瞬间的微妙变化，助力戒断之路。',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          height: 1.6,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
