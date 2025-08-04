import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/launch_at_startup_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await LaunchAtStartupService.initialize();

  bool isBackgroundLaunch = args.contains('--background-launch');

  if (isBackgroundLaunch) {
    print('🚀 后台启动模式，直接退出');
    exit(0);
  } else {
    runApp(const DailyPhotoApp());
  }
}

class DailyPhotoApp extends StatelessWidget {
  const DailyPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '班味检测仪',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'PingFang SC',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'PingFang SC',
      ),
      home: const HomeScreen(),
    );
  }
}
