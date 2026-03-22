import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/core/utils/date_utils.dart';
import 'package:nudge/data/services/local_storage_service.dart';

class UserRepository {
  final LocalStorageService _storage;

  UserRepository(this._storage);

  // --- Onboarding ---
  bool isOnboardingComplete() {
    return _storage.getBool(AppConfig.keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _storage.setBool(AppConfig.keyOnboardingComplete, true);
  }

  // --- User Info ---
  String getUserName() {
    return _storage.getString(AppConfig.keyUserName) ?? '';
  }

  Future<void> setUserName(String name) async {
    await _storage.setString(AppConfig.keyUserName, name);
  }

  String? getProfileImagePath() {
    return _storage.getString(AppConfig.keyProfileImagePath);
  }

  Future<void> setProfileImagePath(String path) async {
    await _storage.setString(AppConfig.keyProfileImagePath, path);
  }

  // --- Streaks ---
  bool isStreaksEnabled() {
    return _storage.getBool(AppConfig.keyStreaksEnabled) ?? true;
  }

  Future<void> setStreaksEnabled(bool enabled) async {
    await _storage.setBool(AppConfig.keyStreaksEnabled, enabled);
  }

  int getStreakCount() {
    return _storage.getInt(AppConfig.keyStreakCount) ?? 0;
  }

  Future<void> updateStreak() async {
    final lastDateStr = _storage.getString(AppConfig.keyLastActiveDate);
    final now = DateTime.now();
    int streak = getStreakCount();

    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      if (AppDateUtils.isToday(lastDate)) {
        // Already counted today
        return;
      } else if (AppDateUtils.isYesterday(lastDate)) {
        // Continue streak
        streak++;
      } else {
        // Streak broken, reset
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await _storage.setInt(AppConfig.keyStreakCount, streak);
    await _storage.setString(AppConfig.keyLastActiveDate, now.toIso8601String());
  }

  Future<void> resetStreak() async {
    await _storage.setInt(AppConfig.keyStreakCount, 0);
    await _storage.remove(AppConfig.keyLastActiveDate);
  }
}
