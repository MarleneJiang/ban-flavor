import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LaunchAtStartupService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      LaunchAtStartup.instance.setup(
        appName: packageInfo.appName,
        appPath: packageInfo.appName,
      );
      _initialized = true;
    } catch (e) {
      print('LaunchAtStartup initialization failed: $e');
      // 暂时忽略错误，因为平台代码还未完全配置
    }
  }

  static Future<bool> isEnabled() async {
    if (!_initialized) await initialize();
    try {
      return await LaunchAtStartup.instance.isEnabled();
    } catch (e) {
      print('LaunchAtStartup isEnabled failed: $e');
      return false; // 默认返回 false
    }
  }

  static Future<void> setEnabled(bool enabled) async {
    if (!_initialized) await initialize();
    try {
      if (enabled) {
        await LaunchAtStartup.instance.enable();
      } else {
        await LaunchAtStartup.instance.disable();
      }
    } catch (e) {
      print('LaunchAtStartup setEnabled failed: $e');
      // 暂时忽略错误
    }
  }
}
