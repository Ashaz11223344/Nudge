import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/data/models/quote_model.dart';
import 'package:nudge/data/services/local_storage_service.dart';

class QuoteRepository {
  final LocalStorageService _storage;

  QuoteRepository(this._storage);

  // --- Favorites ---
  List<QuoteModel> getFavorites() {
    final str = _storage.getString(AppConfig.keyFavorites);
    if (str == null || str.isEmpty) return [];
    return QuoteModel.decodeList(str);
  }

  Future<void> addFavorite(QuoteModel quote) async {
    final favorites = getFavorites();
    if (!favorites.any((f) => f.text == quote.text)) {
      favorites.insert(0, quote);
      await _storage.setString(AppConfig.keyFavorites, QuoteModel.encodeList(favorites));
    }
  }

  Future<void> removeFavorite(QuoteModel quote) async {
    final favorites = getFavorites();
    favorites.removeWhere((f) => f.text == quote.text);
    await _storage.setString(AppConfig.keyFavorites, QuoteModel.encodeList(favorites));
  }

  bool isFavorite(QuoteModel quote) {
    return getFavorites().any((f) => f.text == quote.text);
  }

  Future<void> clearFavorites() async {
    await _storage.remove(AppConfig.keyFavorites);
  }

  // --- History ---
  List<QuoteModel> getHistory() {
    final str = _storage.getString(AppConfig.keyHistory);
    if (str == null || str.isEmpty) return [];
    return QuoteModel.decodeList(str);
  }

  Future<void> addToHistory(QuoteModel quote) async {
    final history = getHistory();
    // Avoid duplicates - remove if exists, then add at top
    history.removeWhere((h) => h.text == quote.text);
    history.insert(0, quote);
    // Keep history to a reasonable size
    if (history.length > 200) {
      history.removeRange(200, history.length);
    }
    await _storage.setString(AppConfig.keyHistory, QuoteModel.encodeList(history));
  }

  Future<void> clearHistory() async {
    await _storage.remove(AppConfig.keyHistory);
  }

  // --- Recent quote indices (to avoid repeats) ---
  List<int> getRecentQuoteIndices() {
    final list = _storage.getStringList(AppConfig.keyRecentQuoteIndices);
    if (list == null) return [];
    return list.map((s) => int.parse(s)).toList();
  }

  Future<void> addRecentQuoteIndex(int index) async {
    final recent = getRecentQuoteIndices();
    recent.insert(0, index);
    if (recent.length > AppConfig.recentQuoteBufferSize) {
      recent.removeRange(AppConfig.recentQuoteBufferSize, recent.length);
    }
    await _storage.setStringList(
      AppConfig.keyRecentQuoteIndices,
      recent.map((i) => i.toString()).toList(),
    );
  }

  // --- Current daily quote ---
  Future<void> setCurrentQuote(QuoteModel quote) async {
    await _storage.setString(AppConfig.keyCurrentQuote, quote.text);
    await _storage.setString(
      AppConfig.keyCurrentQuoteDate,
      DateTime.now().toIso8601String(),
    );
  }

  String? getCurrentQuoteText() {
    return _storage.getString(AppConfig.keyCurrentQuote);
  }

  String? getCurrentQuoteDate() {
    return _storage.getString(AppConfig.keyCurrentQuoteDate);
  }
}
