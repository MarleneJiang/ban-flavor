import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/daily_photo.dart';

class StorageService {
  static const String _photosKey = 'daily_photos';
  static const String _lastPhotoDateKey = 'last_photo_date';

  /// Save a photo to the storage system
  static Future<bool> savePhoto(DailyPhoto photo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photos = await getAllPhotos();

      // Check if we already have a photo for this date
      final photoDate = DateTime(
        photo.date.year,
        photo.date.month,
        photo.date.day,
      );
      final existingIndex = photos.indexWhere((p) {
        final pDate = DateTime(p.date.year, p.date.month, p.date.day);
        return pDate.isAtSameMomentAs(photoDate);
      });

      if (existingIndex != -1) {
        // Replace existing photo for this date
        final oldPhoto = photos[existingIndex];

        // Delete old files if they exist and are different
        if (oldPhoto.filePath != photo.filePath) {
          try {
            final oldFile = File(oldPhoto.filePath);
            if (await oldFile.exists()) {
              await oldFile.delete();
            }
            final oldThumb = File(oldPhoto.thumbnailPath);
            if (await oldThumb.exists()) {
              await oldThumb.delete();
            }
          } catch (e) {
            print('Warning: Could not delete old photo files: $e');
          }
        }

        photos[existingIndex] = photo;
        print('📸 替换了今日已存在的照片');
      } else {
        // Add the new photo
        photos.add(photo);
        print('📸 添加了新的照片');
      }

      // Sort by date (newest first)
      photos.sort((a, b) => b.date.compareTo(a.date));

      // Save to SharedPreferences
      final photosJson = photos.map((p) => p.toJson()).toList();
      await prefs.setString(_photosKey, jsonEncode(photosJson));

      // Update last photo date
      await prefs.setString(_lastPhotoDateKey, photo.date.toIso8601String());

      return true;
    } catch (e) {
      print('Error saving photo: $e');
      return false;
    }
  }

  /// Get all stored photos
  static Future<List<DailyPhoto>> getAllPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosString = prefs.getString(_photosKey);

      if (photosString == null) return [];

      final List<dynamic> photosJson = jsonDecode(photosString);
      final photos = photosJson
          .map((json) => DailyPhoto.fromJson(json))
          .toList();

      // Filter out photos with missing files
      final validPhotos = <DailyPhoto>[];
      for (final photo in photos) {
        if (await File(photo.filePath).exists()) {
          validPhotos.add(photo);
        }
      }

      // Save cleaned list if any photos were removed
      if (validPhotos.length != photos.length) {
        final cleanPhotosJson = validPhotos.map((p) => p.toJson()).toList();
        await prefs.setString(_photosKey, jsonEncode(cleanPhotosJson));
      }

      return validPhotos;
    } catch (e) {
      print('Error getting photos: $e');
      return [];
    }
  }

  /// Check if a photo was already taken today
  static Future<bool> hasPhotoToday() async {
    try {
      final photos = await getAllPhotos();
      final now = DateTime.now();

      // Check if we have any photo for today
      for (final photo in photos) {
        if (photo.date.year == now.year &&
            photo.date.month == now.month &&
            photo.date.day == now.day) {
          // Double check that the file actually exists
          if (await File(photo.filePath).exists()) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking today\'s photo: $e');
      return false;
    }
  }

  /// Delete a photo
  static Future<bool> deletePhoto(DailyPhoto photo) async {
    try {
      // Delete files
      await File(photo.filePath).delete();
      await File(photo.thumbnailPath).delete();

      // Remove from storage
      final photos = await getAllPhotos();
      photos.removeWhere((p) => p.id == photo.id);

      final prefs = await SharedPreferences.getInstance();
      final photosJson = photos.map((p) => p.toJson()).toList();
      await prefs.setString(_photosKey, jsonEncode(photosJson));

      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  /// Get storage directory for photos
  static Future<Directory> getPhotosDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDir = Directory(path.join(directory.path, 'daily_photos'));

    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    return photosDir;
  }

  /// Get storage stats
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final photos = await getAllPhotos();
      final photosDir = await getPhotosDirectory();

      int totalSize = 0;
      for (final photo in photos) {
        final file = File(photo.filePath);
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }

      return {
        'totalPhotos': photos.length,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'photosDirectory': photosDir.path,
      };
    } catch (e) {
      print('Error getting storage stats: $e');
      return {
        'totalPhotos': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
        'photosDirectory': '',
      };
    }
  }
}
