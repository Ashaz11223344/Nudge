import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/core/theme/light_theme.dart';
import 'package:nudge/core/theme/dark_theme.dart';

import 'package:nudge/data/services/notification_service.dart';

class ThemeProvider extends ChangeNotifier {
  final NotificationService? notificationService;
  bool _isDarkMode = false;
  String _fontSize = 'Medium'; // Small, Medium, Large

  ThemeProvider({this.notificationService});

  bool get isDarkMode => _isDarkMode;
  String get fontSize => _fontSize;

  double get baseFontSize {
    switch (_fontSize) {
      case 'Small':
        return AppConfig.fontSizeSmall;
      case 'Large':
        return AppConfig.fontSizeLarge;
      default:
        return AppConfig.fontSizeMedium;
    }
  }

  double get quoteFontSize {
    switch (_fontSize) {
      case 'Small':
        return AppConfig.quoteFontSizeSmall;
      case 'Large':
        return AppConfig.quoteFontSizeLarge;
      default:
        return AppConfig.quoteFontSizeMedium;
    }
  }

  ThemeData get currentTheme {
    return _isDarkMode ? darkTheme(baseFontSize) : lightTheme(baseFontSize);
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConfig.keyDarkMode) ?? false;
    _fontSize = prefs.getString(AppConfig.keyFontSize) ?? 'Medium';
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.keyDarkMode, _isDarkMode);
    
    await notificationService?.showInstantNotification(
      'Theme Updated',
      'App theme changed to ${_isDarkMode ? "Dark" : "Light"} mode.',
    );
    
    notifyListeners();
  }

  Future<void> setFontSize(String size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyFontSize, size);
    
    await notificationService?.showInstantNotification(
      'Font Size Updated',
      'Font size set to $size.',
    );
    
    notifyListeners();
  }
}
