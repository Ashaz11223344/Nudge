import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/data/models/journal_model.dart';
import 'package:nudge/data/services/local_storage_service.dart';

class JournalRepository {
  final LocalStorageService _storage;

  JournalRepository(this._storage);

  List<JournalModel> getAllEntries() {
    final str = _storage.getString(AppConfig.keyJournalEntries);
    if (str == null || str.isEmpty) return [];
    return JournalModel.decodeList(str);
  }

  Future<void> addEntry(JournalModel entry) async {
    final entries = getAllEntries();
    entries.insert(0, entry);
    await _storage.setString(
      AppConfig.keyJournalEntries,
      JournalModel.encodeList(entries),
    );
  }

  Future<void> updateEntry(JournalModel updatedEntry) async {
    final entries = getAllEntries();
    final index = entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      entries[index] = updatedEntry;
      await _storage.setString(
        AppConfig.keyJournalEntries,
        JournalModel.encodeList(entries),
      );
    }
  }

  Future<void> deleteEntry(String id) async {
    final entries = getAllEntries();
    entries.removeWhere((e) => e.id == id);
    await _storage.setString(
      AppConfig.keyJournalEntries,
      JournalModel.encodeList(entries),
    );
  }

  Future<void> clearAll() async {
    await _storage.remove(AppConfig.keyJournalEntries);
  }
}
