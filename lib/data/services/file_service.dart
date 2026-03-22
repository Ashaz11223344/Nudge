import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:nudge/data/services/local_storage_service.dart';

class FileService {
  /// Get the app's documents directory
  Future<String> get _documentsPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Save profile image to app directory
  Future<String> saveProfileImage(String sourcePath) async {
    final docsPath = await _documentsPath;
    final fileName = 'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = '$docsPath/$fileName';
    
    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);
    
    return destPath;
  }

  /// Delete a file
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Export all data as a JSON file
  Future<String> exportData(LocalStorageService storageService) async {
    final data = storageService.getAllData();
    final jsonStr = jsonEncode(data);
    
    final docsPath = await _documentsPath;
    final fileName = 'nudge_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final filePath = '$docsPath/$fileName';
    
    final file = File(filePath);
    await file.writeAsString(jsonStr);
    
    return filePath;
  }

  /// Import data from a JSON file
  Future<Map<String, dynamic>> importData(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found');
    }
    
    final jsonStr = await file.readAsString();
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  /// Check if profile image exists
  Future<bool> profileImageExists(String? path) async {
    if (path == null || path.isEmpty) return false;
    return File(path).exists();
  }
}
