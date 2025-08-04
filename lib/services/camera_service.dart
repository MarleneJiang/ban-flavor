import 'dart:io';
import 'package:camera_macos/camera_macos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_photo.dart';
import 'storage_service.dart';

class CameraService {
  static CameraMacOSController? _controller;
  static bool _isInitialized = false;

  /// Initialize the camera service
  static Future<bool> initialize() async {
    try {
      // Check if cameras are available
      final videoDevices = await CameraMacOS.instance.listDevices(
        deviceType: CameraMacOSDeviceType.video,
      );

      if (videoDevices.isEmpty) {
        print('No camera devices found');
        return false;
      }

      print('Camera service ready, ${videoDevices.length} cameras available');
      return true;
    } catch (e) {
      print('Error initializing camera: $e');
      return false;
    }
  }

  /// Take a photo automatically without manual UI interaction
  static Future<DailyPhoto?> takePhotoAutomatically() async {
    try {
      // Check if we have permission
      final hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        print('Camera permission not granted');
        return null;
      }

      print('Starting automatic photo capture...');

      // We need to create a temporary, invisible camera widget
      // This is a workaround for the camera_macos limitation
      return await _takePhotoWithController();
    } catch (e) {
      print('Error in automatic photo capture: $e');
      return null;
    }
  }

  /// Internal method to take photo with current controller
  static Future<DailyPhoto?> _takePhotoWithController() async {
    // If we don't have a controller yet, we can't take a photo
    if (!_isInitialized || _controller == null) {
      print('No camera controller available for automatic capture');
      print('User will need to use manual capture through camera preview');
      return null;
    }

    return await takePhoto();
  }

  /// Set controller when camera is initialized
  static void setController(CameraMacOSController controller) {
    _controller = controller;
    _isInitialized = true;
  }

  /// Take a photo and save it
  static Future<DailyPhoto?> takePhoto() async {
    if (!_isInitialized || _controller == null) {
      print('Camera not initialized');
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final photosDir = Directory(path.join(directory.path, 'daily_photos'));
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      // Take photo with camera_macos
      final CameraMacOSFile? photo = await _controller!.takePicture();
      if (photo == null || photo.bytes == null) {
        print('Failed to take photo');
        return null;
      }

      final now = DateTime.now();
      final timestamp =
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final fileName =
          'photo_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_$timestamp.jpg';
      final filePath = path.join(photosDir.path, fileName);

      // Save original photo
      final originalFile = File(filePath);
      await originalFile.writeAsBytes(photo.bytes!);

      // Create thumbnail
      final image = img.decodeImage(photo.bytes!);
      if (image != null) {
        final thumbnail = img.copyResize(image, width: 200);
        final thumbnailBytes = img.encodeJpg(thumbnail);

        final thumbnailPath = path.join(photosDir.path, 'thumb_$fileName');
        final thumbnailFile = File(thumbnailPath);
        await thumbnailFile.writeAsBytes(thumbnailBytes);

        // Record that we took a photo today
        final prefs = await SharedPreferences.getInstance();
        final dateKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        await prefs.setString('last_photo_date', dateKey);

        final dailyPhoto = DailyPhoto(
          id: fileName,
          filePath: filePath,
          thumbnailPath: thumbnailPath,
          date: now,
        );

        // Save photo to storage system
        await StorageService.savePhoto(dailyPhoto);
        print('📸 照片已保存到存储系统: $filePath');

        return dailyPhoto;
      }

      // Record that we took a photo today
      final prefs = await SharedPreferences.getInstance();
      final dateKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await prefs.setString('last_photo_date', dateKey);

      final dailyPhoto = DailyPhoto(
        id: fileName,
        filePath: filePath,
        thumbnailPath:
            filePath, // Use original as thumbnail if thumbnail creation fails
        date: now,
      );

      // Save photo to storage system
      await StorageService.savePhoto(dailyPhoto);
      print('📸 照片已保存到存储系统: $filePath');

      return dailyPhoto;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    } finally {
      // Ensure camera is released after taking photo
      try {
        if (_controller != null) {
          _controller!.stopImageStream();
          print('📸 拍照完成，摄像头资源已释放');
        }
      } catch (e) {
        print('Error releasing camera: $e');
      }
    }
  }

  /// Dispose camera resources
  static Future<void> dispose() async {
    try {
      if (_controller != null) {
        _controller!.stopImageStream();
        _controller = null;
      }
      _isInitialized = false;
      print('Camera resources fully disposed');
    } catch (e) {
      print('Error disposing camera: $e');
    }
  }

  /// Force release camera resources
  static Future<void> forceRelease() async {
    await dispose();
  }

  /// Check if camera permission is granted
  static Future<bool> checkCameraPermission() async {
    try {
      // With camera_macos, permission is handled automatically when the camera is used
      // We can try to list devices to check if cameras are available
      final videoDevices = await CameraMacOS.instance.listDevices(
        deviceType: CameraMacOSDeviceType.video,
      );
      return videoDevices.isNotEmpty;
    } catch (e) {
      print('Camera permission error: $e');
      return false;
    }
  }

  /// Request camera permission by trying to initialize
  static Future<bool> requestCameraPermission() async {
    try {
      return await checkCameraPermission();
    } catch (e) {
      print('Camera permission request error: $e');
      return false;
    }
  }
}
