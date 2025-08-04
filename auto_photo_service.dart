import 'package:flutter/material.dart';
import 'package:camera_macos/camera_macos.dart';
import 'camera_service.dart';
import '../models/daily_photo.dart';

class AutoPhotoService {
  /// Create a temporary invisible camera widget to take a photo
  static Future<DailyPhoto?> takePhotoSilently(BuildContext context) async {
    try {
      // Show a minimal overlay while capturing
      return await showDialog<DailyPhoto?>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _AutoPhotoDialog(),
      );
    } catch (e) {
      print('Error in silent photo capture: $e');
      return null;
    }
  }
}

class _AutoPhotoDialog extends StatefulWidget {
  const _AutoPhotoDialog();

  @override
  State<_AutoPhotoDialog> createState() => _AutoPhotoDialogState();
}

class _AutoPhotoDialogState extends State<_AutoPhotoDialog> {
  CameraMacOSController? _controller;

  @override
  void initState() {
    super.initState();
    _capturePhoto();
  }

  Future<void> _capturePhoto() async {
    try {
      // Wait a moment for camera to initialize
      await Future.delayed(const Duration(milliseconds: 1500));

      if (_controller != null) {
        print('Taking photo with auto capture...');
        CameraService.setController(_controller!);
        final photo = await CameraService.takePhoto();

        // Force release camera after photo
        await _releaseCamera();

        if (mounted) {
          Navigator.of(context).pop(photo);
          return;
        }
      }

      // If we get here, capture failed
      await _releaseCamera();
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    } catch (e) {
      print('Auto capture error: $e');
      await _releaseCamera();
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  Future<void> _releaseCamera() async {
    try {
      if (_controller != null) {
        _controller!.stopImageStream();
        _controller = null;
      }
      // Also call the service dispose to ensure complete cleanup
      await CameraService.forceRelease();
      print('🔄 Auto photo service: 摄像头资源已完全释放');
    } catch (e) {
      print('Error releasing camera in auto service: $e');
    }
  }

  @override
  void dispose() {
    _releaseCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black87,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiny camera preview (almost invisible)
            SizedBox(
              width: 100,
              height: 75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CameraMacOSView(
                  fit: BoxFit.cover,
                  cameraMode: CameraMacOSMode.photo,
                  onCameraInizialized: (CameraMacOSController controller) {
                    _controller = controller;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 12),
            const Text(
              '📸 正在进行班味检测...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              '请稍等片刻',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
