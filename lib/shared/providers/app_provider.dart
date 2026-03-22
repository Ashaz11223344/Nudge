import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/core/utils/date_utils.dart';
import 'package:nudge/data/models/quote_model.dart';
import 'package:nudge/data/repositories/quote_repository.dart';
import 'package:nudge/data/repositories/user_repository.dart';
import 'package:nudge/data/services/file_service.dart';
import 'package:nudge/data/services/local_storage_service.dart';
import 'package:nudge/data/services/notification_service.dart';
import 'package:nudge/data/services/quote_service.dart';
import 'package:nudge/data/services/widget_service.dart';
import 'package:nudge/data/repositories/mood_repository.dart';
import 'package:nudge/routes/app_routes.dart';

class AppProvider extends ChangeNotifier {
  final LocalStorageService storageService;
  final QuoteService quoteService;
  final NotificationService notificationService;
  final FileService fileService;
  final QuoteRepository quoteRepository;
  final UserRepository userRepository;
  final MoodRepository moodRepository;

  // State
  QuoteModel? _currentQuote;
  bool _isFavorite = false;
  int _notificationFrequency = AppConfig.defaultNotificationFrequency;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = AppConfig.defaultQuietHoursStart;
  TimeOfDay _quietHoursEnd = AppConfig.defaultQuietHoursEnd;
  TimeOfDay _dailyRefreshTime = AppConfig.defaultDailyRefreshTime;
  List<String> _enabledCategories = List.from(AppConfig.quoteCategories);
  bool _streaksEnabled = true;
  int _streakCount = 0;
  String _userName = '';
  String? _profileImagePath;
  bool _isInitialized = false;

  // Getters
  QuoteModel? get currentQuote => _currentQuote;
  bool get isFavorite => _isFavorite;
  int get notificationFrequency => _notificationFrequency;
  bool get quietHoursEnabled => _quietHoursEnabled;
  TimeOfDay get quietHoursStart => _quietHoursStart;
  TimeOfDay get quietHoursEnd => _quietHoursEnd;
  TimeOfDay get dailyRefreshTime => _dailyRefreshTime;
  List<String> get enabledCategories => _enabledCategories;
  bool get streaksEnabled => _streaksEnabled;
  int get streakCount => _streakCount;
  String get userName => _userName;
  String? get profileImagePath => _profileImagePath;

  AppProvider({
    required this.storageService,
    required this.quoteService,
    required this.notificationService,
    required this.fileService,
    required this.quoteRepository,
    required this.userRepository,
    required this.moodRepository,
  });

  Future<void> init() async {
    try {
      if (_isInitialized) return;
      await quoteService.loadQuotes();
      _loadSettings();
      _loadUserData();
      await _loadDailyQuote();
      await userRepository.updateStreak();
      _streakCount = userRepository.getStreakCount();
      _isInitialized = true;
      notifyListeners();
      
      await _syncWidget();

      debugPrint('AppProvider initialized successfully');

      // Re-schedule notifications on every app start so they survive app kills
      // and device reboots. Run after notifyListeners to avoid blocking UI.
      debugPrint('[Notif] Rescheduling on app start (frequency: $_notificationFrequency)');
      await _rescheduleNotifications();
    } catch (e) {
      debugPrint('AppProvider Init Error: $e');
    }
  }

  void _loadSettings() {
    _notificationFrequency = storageService.getInt(AppConfig.keyNotificationFrequency) ??
        AppConfig.defaultNotificationFrequency;
    _quietHoursEnabled =
        storageService.getBool(AppConfig.keyQuietHoursEnabled) ?? false;

    final qhStart = storageService.getString(AppConfig.keyQuietHoursStart);
    if (qhStart != null) {
      final parts = qhStart.split(':');
      _quietHoursStart =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final qhEnd = storageService.getString(AppConfig.keyQuietHoursEnd);
    if (qhEnd != null) {
      final parts = qhEnd.split(':');
      _quietHoursEnd =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final refreshTime = storageService.getString(AppConfig.keyDailyRefreshTime);
    if (refreshTime != null) {
      final parts = refreshTime.split(':');
      _dailyRefreshTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final cats = storageService.getStringList(AppConfig.keyEnabledCategories);
    if (cats != null) {
      _enabledCategories = cats;
    }

    _streaksEnabled =
        storageService.getBool(AppConfig.keyStreaksEnabled) ?? true;
  }

  void _loadUserData() {
    _userName = userRepository.getUserName();
    _profileImagePath = userRepository.getProfileImagePath();
    _streakCount = userRepository.getStreakCount();
  }

  Future<void> _loadDailyQuote() async {
    try {
      final savedDate = quoteRepository.getCurrentQuoteDate();
      final savedText = quoteRepository.getCurrentQuoteText();

      if (savedDate != null && savedText != null) {
        final lastDate = DateTime.parse(savedDate);
        if (AppDateUtils.isToday(lastDate)) {
          // Use saved daily quote
          final match = quoteService.allQuotes.where((q) => q.text == savedText);
          if (match.isNotEmpty) {
            _currentQuote = match.first;
            _isFavorite = quoteRepository.isFavorite(_currentQuote!);
            return;
          }
        }
      }

      // Generate new daily quote
      await refreshQuote();
    } catch (e) {
      debugPrint('Load Daily Quote Error: $e');
      // Fallback to a random quote if everything fails
      _currentQuote = quoteService.getRandomQuote([], enabledCategories: _enabledCategories);
      notifyListeners();
    }
  }

  Future<void> refreshQuote() async {
    final recentIndices = quoteRepository.getRecentQuoteIndices();
    _currentQuote = quoteService.getRandomQuote(
      recentIndices,
      enabledCategories: _enabledCategories,
    );
    if (_currentQuote != null) {
      await quoteRepository.addRecentQuoteIndex(_currentQuote!.index);
      await quoteRepository.addToHistory(_currentQuote!);
      await quoteRepository.setCurrentQuote(_currentQuote!);
      _isFavorite = quoteRepository.isFavorite(_currentQuote!);
    }
    notifyListeners();
    await _syncWidget();
  }

  Future<void> toggleFavorite() async {
    if (_currentQuote == null) return;
    if (_isFavorite) {
      await quoteRepository.removeFavorite(_currentQuote!);
    } else {
      await quoteRepository.addFavorite(_currentQuote!);
    }
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  Future<void> setNotificationFrequency(int freq, {bool shouldReschedule = true}) async {
    _notificationFrequency = freq;
    notifyListeners();
    await storageService.setInt(AppConfig.keyNotificationFrequency, freq);
    
    if (shouldReschedule) {
      await _rescheduleNotifications();
      await notificationService.showInstantNotification(
        'Schedule Updated',
        'You will now receive $freq nudges per day.',
      );
    }
  }

  Future<void> setQuietHoursEnabled(bool enabled) async {
    _quietHoursEnabled = enabled;
    notifyListeners();
    await storageService.setBool(AppConfig.keyQuietHoursEnabled, enabled);
    await _rescheduleNotifications();
    
    await notificationService.showInstantNotification(
      'Quiet Mode',
      enabled ? 'Quiet hours enabled.' : 'Quiet hours disabled.',
    );
  }

  Future<void> setQuietHoursStart(TimeOfDay time) async {
    _quietHoursStart = time;
    await storageService.setString(
      AppConfig.keyQuietHoursStart,
      '${time.hour}:${time.minute}',
    );
    await _rescheduleNotifications();
    
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    await notificationService.showInstantNotification(
      'Quiet Hours Updated',
      'Quiet mode will now start at $timeStr.',
    );
    
    notifyListeners();
  }

  Future<void> setQuietHoursEnd(TimeOfDay time) async {
    _quietHoursEnd = time;
    await storageService.setString(
      AppConfig.keyQuietHoursEnd,
      '${time.hour}:${time.minute}',
    );
    await _rescheduleNotifications();
    
    final timeStr = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    await notificationService.showInstantNotification(
      'Quiet Hours Updated',
      'Quiet mode will now end at $timeStr.',
    );
    
    notifyListeners();
  }

  Future<void> setDailyRefreshTime(TimeOfDay time) async {
    _dailyRefreshTime = time;
    await storageService.setString(
      AppConfig.keyDailyRefreshTime,
      '${time.hour}:${time.minute}',
    );
    notifyListeners();
  }

  Future<void> setEnabledCategories(List<String> categories) async {
    _enabledCategories = categories;
    await storageService.setStringList(AppConfig.keyEnabledCategories, categories);
    await notificationService.showInstantNotification(
      'Preferences Updated',
      'Quote categories updated successfully.',
    );
    notifyListeners();
  }

  Future<void> toggleCategory(String category) async {
    if (_enabledCategories.contains(category)) {
      if (_enabledCategories.length > 1) {
        _enabledCategories.remove(category);
      }
    } else {
      _enabledCategories.add(category);
    }
    await storageService.setStringList(
      AppConfig.keyEnabledCategories,
      _enabledCategories,
    );
    
    await notificationService.showInstantNotification(
      'Categories Updated',
      'Topic preferences changed.',
    );
    
    notifyListeners();
  }

  Future<void> setStreaksEnabled(bool enabled) async {
    _streaksEnabled = enabled;
    await userRepository.setStreaksEnabled(enabled);
    notifyListeners();
    await _syncWidget();
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    await userRepository.setUserName(name);
    await notificationService.showInstantNotification(
      'Profile Updated',
      'Your name has been updated to $name.',
    );
    notifyListeners();
  }

  Future<void> updateProfileImage(String path) async {
    // Delete old image if exists
    if (_profileImagePath != null) {
      await fileService.deleteFile(_profileImagePath!);
    }
    final savedPath = await fileService.saveProfileImage(path);
    _profileImagePath = savedPath;
    await userRepository.setProfileImagePath(savedPath);
    
    await notificationService.showInstantNotification(
      'Profile Updated',
      'Profile photo updated successfully.',
    );
    
    notifyListeners();
  }

  ImageProvider? getProfileImage() {
    if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
      final file = File(_profileImagePath!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return null;
  }

  Future<void> sendTestNotification() async {
    final quote =
        _currentQuote ?? quoteService.getRandomQuote([], enabledCategories: _enabledCategories);
    await notificationService.showTestNotification(quote.text);
  }

  Future<void> _rescheduleNotifications() async {
    await notificationService.scheduleNotifications(
      frequency: _notificationFrequency,
      quietStart: _quietHoursStart,
      quietEnd: _quietHoursEnd,
      quietHoursEnabled: _quietHoursEnabled,
      quoteService: quoteService,
      enabledCategories: _enabledCategories,
    );
  }

  Future<String> exportData() async {
    return await fileService.exportData(storageService);
  }

  Future<void> importData(String filePath) async {
    final data = await fileService.importData(filePath);
    await storageService.restoreData(data);
    _loadSettings();
    _loadUserData();
    await _loadDailyQuote();
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    await quoteRepository.clearFavorites();
    if (_currentQuote != null) {
      _isFavorite = false;
    }
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await quoteRepository.clearHistory();
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await storageService.clearAll();
    _currentQuote = null;
    _isFavorite = false;
    _notificationFrequency = AppConfig.defaultNotificationFrequency;
    _quietHoursEnabled = false;
    _quietHoursStart = AppConfig.defaultQuietHoursStart;
    _quietHoursEnd = AppConfig.defaultQuietHoursEnd;
    _enabledCategories = List.from(AppConfig.quoteCategories);
    _streaksEnabled = true;
    _streakCount = 0;
    _userName = '';
    _profileImagePath = null;
    notifyListeners();
    await _syncWidget();
  }

  Future<void> _syncWidget() async {
    await WidgetService.syncAllData(
      userRepository,
      moodRepository,
      currentQuote: _currentQuote?.text,
    );
  }

  // New method for UI to call when mood changes
  Future<void> notifyMoodChanged() async {
    await _syncWidget();
    notifyListeners();
  }
}
