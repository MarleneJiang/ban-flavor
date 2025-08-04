import 'dart:async';
import 'dart:io';
import 'package:camera_macos/camera_macos.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/daily_photo.dart';
import '../services/storage_service.dart';

class CameraPreviewScreen extends StatefulWidget {
  final Function(bool)? onPhotoTaken;

  const CameraPreviewScreen({super.key, this.onPhotoTaken});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

enum CameraStatus {
  initializing,
  ready,
  takingPhoto,
  processing,
  success,
  error,
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  CameraMacOSController? _macOSController;
  CameraStatus _status = CameraStatus.initializing;
  String _errorMessage = '';

  @override
  void dispose() {
    _macOSController?.destroy();
    super.dispose();
  }

  Future<void> _takePictureAndClose() async {
    if (_macOSController == null || _status != CameraStatus.ready) return;

    setState(() {
      _status = CameraStatus.takingPhoto;
    });

    try {
      final picture = await _macOSController!.takePicture();
      if (picture == null || picture.bytes == null) {
        throw Exception('拍照失败，未能获取图像数据');
      }

      setState(() {
        _status = CameraStatus.processing;
      });

      final image = img.decodeImage(picture.bytes!);
      if (image == null) {
        throw Exception('图像解码失败');
      }

      final now = DateTime.now();
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(appDir.path, 'photos'));
      await photosDir.create(recursive: true);

      // 生成包含日期的文件名格式：ban_flavor_YYYYMMDD_timestamp.jpg
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final fileName =
          'ban_flavor_${dateStr}_${now.millisecondsSinceEpoch}.jpg';
      final filePath = path.join(photosDir.path, fileName);
      await File(filePath).writeAsBytes(img.encodeJpg(image));

      final thumbnail = img.copyResize(image, width: 200);
      final thumbFileName = 'thumb_$fileName';
      final thumbPath = path.join(photosDir.path, thumbFileName);
      await File(thumbPath).writeAsBytes(img.encodeJpg(thumbnail));

      final dailyPhoto = DailyPhoto(
        id: now.toIso8601String(),
        date: now,
        filePath: filePath,
        thumbnailPath: thumbPath,
      );

      final saved = await StorageService.savePhoto(dailyPhoto);
      if (!saved) {
        throw Exception('照片保存失败');
      }

      setState(() {
        _status = CameraStatus.success;
      });

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        widget.onPhotoTaken?.call(true);
      }
    } catch (e) {
      setState(() {
        _status = CameraStatus.error;
        _errorMessage = e.toString();
      });
      print('拍照或处理失败: $e');
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        widget.onPhotoTaken?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            children: [
              CameraMacOSView(
                fit: BoxFit.cover,
                cameraMode: CameraMacOSMode.photo,
                onCameraInizialized: (CameraMacOSController controller) {
                  setState(() {
                    _macOSController = controller;
                    _status = CameraStatus.ready;
                  });
                  // 延迟一小段时间后自动拍照, 给予摄像头充分的准备时间
                  Future.delayed(const Duration(milliseconds: 2000), () {
                    if (mounted) {
                      _takePictureAndClose();
                    }
                  });
                },
              ),
              _buildOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_status == CameraStatus.initializing) ...[
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              const Text('正在启动班味检测器...', style: TextStyle(color: Colors.white)),
            ] else if (_status == CameraStatus.takingPhoto) ...[
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              const Text('正在捕捉瞬间...', style: TextStyle(color: Colors.white)),
            ] else if (_status == CameraStatus.processing) ...[
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              const Text('正在分析班味成分...', style: TextStyle(color: Colors.white)),
            ] else if (_status == CameraStatus.success) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              const Text(
                '检测完成！',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ] else if (_status == CameraStatus.error) ...[
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                '检测失败',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
