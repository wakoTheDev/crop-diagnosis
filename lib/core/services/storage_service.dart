import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';

class StorageService {
  // Get application documents directory
  Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
  
  // Save image to local storage
  Future<String> saveImage(File imageFile, {bool compress = true}) async {
    try {
      final appDir = await getAppDirectory();
      final imagesDir = Directory('${appDir.path}/${AppConstants.imagesPath}');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${imagesDir.path}/$fileName';
      
      if (compress) {
        // Compress image
        final imageBytes = await imageFile.readAsBytes();
        final image = img.decodeImage(imageBytes);
        
        if (image != null) {
          // Resize if too large
          img.Image resized = image;
          if (image.width > 1920 || image.height > 1920) {
            resized = img.copyResize(image, width: 1920);
          }
          
          // Compress and save
          final compressedBytes = img.encodeJpg(resized, quality: 85);
          await File(savedPath).writeAsBytes(compressedBytes);
        } else {
          await imageFile.copy(savedPath);
        }
      } else {
        await imageFile.copy(savedPath);
      }
      
      return savedPath;
    } catch (e) {
      rethrow;
    }
  }
  
  // Save voice recording
  Future<String> saveVoiceRecording(File voiceFile) async {
    try {
      final appDir = await getAppDirectory();
      final voicesDir = Directory('${appDir.path}/${AppConstants.voicesPath}');
      
      if (!await voicesDir.exists()) {
        await voicesDir.create(recursive: true);
      }
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      final savedPath = '${voicesDir.path}/$fileName';
      
      await voiceFile.copy(savedPath);
      return savedPath;
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Get file size
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  // Cache data using Hive
  Future<void> cacheData(String key, dynamic data) async {
    final box = await Hive.openBox(AppConstants.cacheBox);
    await box.put(key, data);
  }
  
  // Get cached data
  Future<dynamic> getCachedData(String key) async {
    final box = await Hive.openBox(AppConstants.cacheBox);
    return box.get(key);
  }
  
  // Clear cache
  Future<void> clearCache() async {
    final box = await Hive.openBox(AppConstants.cacheBox);
    await box.clear();
  }
  
  // Get storage usage
  Future<Map<String, dynamic>> getStorageUsage() async {
    try {
      final appDir = await getAppDirectory();
      
      int imagesSize = 0;
      int voicesSize = 0;
      int totalSize = 0;
      
      // Calculate images size
      final imagesDir = Directory('${appDir.path}/${AppConstants.imagesPath}');
      if (await imagesDir.exists()) {
        await for (var file in imagesDir.list(recursive: true)) {
          if (file is File) {
            imagesSize += await file.length();
          }
        }
      }
      
      // Calculate voices size
      final voicesDir = Directory('${appDir.path}/${AppConstants.voicesPath}');
      if (await voicesDir.exists()) {
        await for (var file in voicesDir.list(recursive: true)) {
          if (file is File) {
            voicesSize += await file.length();
          }
        }
      }
      
      totalSize = imagesSize + voicesSize;
      
      return {
        'images_size': imagesSize,
        'voices_size': voicesSize,
        'total_size': totalSize,
        'images_size_mb': (imagesSize / (1024 * 1024)).toStringAsFixed(2),
        'voices_size_mb': (voicesSize / (1024 * 1024)).toStringAsFixed(2),
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      return {
        'images_size': 0,
        'voices_size': 0,
        'total_size': 0,
        'images_size_mb': '0.00',
        'voices_size_mb': '0.00',
        'total_size_mb': '0.00',
      };
    }
  }
  
  // Clean old files (older than specified days)
  Future<void> cleanOldFiles(int days) async {
    try {
      final appDir = await getAppDirectory();
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      // Clean old images
      final imagesDir = Directory('${appDir.path}/${AppConstants.imagesPath}');
      if (await imagesDir.exists()) {
        await for (var file in imagesDir.list()) {
          if (file is File) {
            final stat = await file.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await file.delete();
            }
          }
        }
      }
      
      // Clean old voice recordings
      final voicesDir = Directory('${appDir.path}/${AppConstants.voicesPath}');
      if (await voicesDir.exists()) {
        await for (var file in voicesDir.list()) {
          if (file is File) {
            final stat = await file.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
