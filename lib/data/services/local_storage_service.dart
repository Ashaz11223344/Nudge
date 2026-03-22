import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      final version = _prefs.getInt('app_data_version') ?? 0;
      if (version < 1) {
        await _prefs.setInt('app_data_version', 1);
      }
    } catch (e) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // String
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (_) {}
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  // Bool
  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (_) {}
  }

  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (_) {
      return null;
    }
  }

  // Int
  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (_) {}
  }

  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (_) {
      return null;
    }
  }

  // StringList
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs.setStringList(key, value);
    } catch (_) {}
  }

  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (_) {
      return null;
    }
  }

  // JSON encoded data
  Future<void> setJsonData(String key, dynamic data) async {
    try {
      await _prefs.setString(key, jsonEncode(data));
    } catch (_) {}
  }

  dynamic getJsonData(String key) {
    try {
      final str = _prefs.getString(key);
      if (str == null) return null;
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  // Remove
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (_) {}
  }

  // Clear all
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
    } catch (_) {}
  }

  // Check if key exists
  bool containsKey(String key) {
    try {
      return _prefs.containsKey(key);
    } catch (_) {
      return false;
    }
  }

  // Get all data for backup
  Map<String, dynamic> getAllData() {
    final Map<String, dynamic> data = {};
    try {
      for (final key in _prefs.getKeys()) {
        data[key] = _prefs.get(key);
      }
    } catch (_) {}
    return data;
  }

  // Restore data from backup
  Future<void> restoreData(Map<String, dynamic> data) async {
    for (final entry in data.entries) {
      final value = entry.value;
      try {
        if (value is String) {
          await _prefs.setString(entry.key, value);
        } else if (value is bool) {
          await _prefs.setBool(entry.key, value);
        } else if (value is int) {
          await _prefs.setInt(entry.key, value);
        } else if (value is double) {
          await _prefs.setDouble(entry.key, value);
        } else if (value is List) {
          await _prefs.setStringList(
            entry.key,
            value.map((e) => e.toString()).toList(),
          );
        }
      } catch (_) {}
    }
  }
}
