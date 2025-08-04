import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_service.dart';
import 'storage_service.dart';

class SystemEventService {
  static Timer? _monitoringTimer;
  static bool _isMonitoring = false;
  static DateTime? _lastWakeTime;
  static const String _lastWakeTimeKey = 'last_wake_time';

  /// Start monitoring for system wake events
  static Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    
    print('Starting system event monitoring...');
    _isMonitoring = true;
    
    // Load last wake time
    await _loadLastWakeTime();
    
    // Check every 30 seconds for system wake
    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForSystemWake();
    });
    
    // Initial check
    _checkForSystemWake();
  }

  /// Stop monitoring
  static void stopMonitoring() {
    print('Stopping system event monitoring...');
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
  }

  /// Check if the system was recently unlocked/awakened
  static Future<void> _checkForSystemWake() async {
    try {
      final now = DateTime.now();
      
      // Check if we should take a photo
      if (await _shouldTakePhoto()) {
        print('System wake detected - taking daily photo...');
        await _takeAndSavePhoto();
        await _updateLastWakeTime(now);
      }
    } catch (e) {
      print('Error checking system wake: $e');
    }
  }

  /// Determine if we should take a photo
  static Future<bool> _shouldTakePhoto() async {
    // Check if we already took a photo today
    final hasPhotoToday = await StorageService.hasPhotoToday();
    if (hasPhotoToday) {
      return false;
    }

    // Check if this is the first significant activity today
    final now = DateTime.now();
    
    // If we haven't recorded any wake time today, consider this a wake event
    if (_lastWakeTime == null || !_isSameDay(_lastWakeTime!, now)) {
      return true;
    }

    // If the last wake was more than 4 hours ago, consider this a new wake event
    final timeSinceLastWake = now.difference(_lastWakeTime!);
    if (timeSinceLastWake.inHours >= 4) {
      return true;
    }

    return false;
  }

  /// Take and save a photo
  static Future<void> _takeAndSavePhoto() async {
    try {
      // Check camera permission
      final hasPermission = await CameraService.checkCameraPermission();
      if (!hasPermission) {
        print('Camera permission not granted');
        return;
      }

      // Take the photo
      final photo = await CameraService.takePhoto();
      if (photo != null) {
        final saved = await StorageService.savePhoto(photo);
        if (saved) {
          print('Daily photo saved successfully: ${photo.filePath}');
        } else {
          print('Failed to save daily photo');
        }
      } else {
        print('Failed to take daily photo');
      }
    } catch (e) {
      print('Error taking and saving photo: $e');
    }
  }

  /// Load the last wake time from storage
  static Future<void> _loadLastWakeTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastWakeString = prefs.getString(_lastWakeTimeKey);
      if (lastWakeString != null) {
        _lastWakeTime = DateTime.parse(lastWakeString);
      }
    } catch (e) {
      print('Error loading last wake time: $e');
    }
  }

  /// Update the last wake time
  static Future<void> _updateLastWakeTime(DateTime time) async {
    try {
      _lastWakeTime = time;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastWakeTimeKey, time.toIso8601String());
    } catch (e) {
      print('Error updating last wake time: $e');
    }
  }

  /// Check if two dates are on the same day
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Manually trigger a photo (for testing or user request)
  static Future<bool> takePhotoNow() async {
    try {
      await _takeAndSavePhoto();
      await _updateLastWakeTime(DateTime.now());
      return true;
    } catch (e) {
      print('Error taking manual photo: $e');
      return false;
    }
  }

  /// Get monitoring status
  static bool get isMonitoring => _isMonitoring;
  
  /// Get last wake time
  static DateTime? get lastWakeTime => _lastWakeTime;
}
