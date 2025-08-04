import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_photo.dart';

class PhotoDetailScreen extends StatelessWidget {
  final DailyPhoto photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormat('yyyy年M月d日').format(photo.date)} 班味记录'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPhotoInfo(context),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: File(photo.filePath).existsSync()
              ? Image.file(File(photo.filePath), fit: BoxFit.contain)
              : Container(
                  color: Colors.grey[800],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey, size: 64),
                      SizedBox(height: 16),
                      Text('图片文件不存在', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _showPhotoInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('班味记录详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '检测日期: ${DateFormat('yyyy年M月d日 HH:mm:ss').format(photo.date)}',
            ),
            const SizedBox(height: 8),
            Text('文件路径: ${photo.filePath}'),
            const SizedBox(height: 8),
            FutureBuilder<FileStat>(
              future: File(photo.filePath).stat(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final size = snapshot.data!.size;
                  final sizeKB = (size / 1024).toStringAsFixed(2);
                  return Text('文件大小: $sizeKB KB');
                }
                return const Text('文件大小: 计算中...');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
