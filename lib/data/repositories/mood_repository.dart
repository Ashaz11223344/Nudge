import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/data/models/mood_model.dart';
import 'package:nudge/data/services/local_storage_service.dart';

class MoodRepository {
  final LocalStorageService _storage;

  MoodRepository(this._storage);

  List<MoodModel> getAllMoods() {
    final str = _storage.getString(AppConfig.keyMoodEntries);
    if (str == null || str.isEmpty) return [];
    return MoodModel.decodeList(str);
  }

  Future<void> addMood(MoodModel mood) async {
    final moods = getAllMoods();
    // Remove existing mood for today if any
    moods.removeWhere((m) =>
        m.date.year == mood.date.year &&
        m.date.month == mood.date.month &&
        m.date.day == mood.date.day);
    moods.insert(0, mood);
    await _storage.setString(AppConfig.keyMoodEntries, MoodModel.encodeList(moods));
  }

  MoodModel? getTodaysMood() {
    final moods = getAllMoods();
    final now = DateTime.now();
    try {
      return moods.firstWhere((m) =>
          m.date.year == now.year &&
          m.date.month == now.month &&
          m.date.day == now.day);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _storage.remove(AppConfig.keyMoodEntries);
  }
}
