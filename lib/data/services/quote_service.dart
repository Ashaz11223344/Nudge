import 'package:flutter/services.dart';
import 'package:nudge/core/utils/quote_utils.dart';
import 'package:nudge/data/models/quote_model.dart';

class QuoteService {
  List<QuoteModel> _allQuotes = [];
  int _currentIndex = 0;

  List<QuoteModel> get allQuotes => _allQuotes;

  Future<void> loadQuotes() async {
    try {
      final String content =
          await rootBundle.loadString('assets/quotes/quotes.txt');
      final lines = content.split('\n');

      _allQuotes = [];
      int index = 0;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        final (category, text) = QuoteUtils.parseQuoteLine(trimmed);
        if (text.isNotEmpty) {
          _allQuotes.add(QuoteModel(
            text: text,
            category: category,
            index: index,
          ));
          index++;
        }
      }
      _allQuotes.shuffle();
      _currentIndex = 0;
    } catch (e) {
      _allQuotes = [
        QuoteModel(text: "Every day is a second chance.", category: "motivation", index: 0),
        QuoteModel(text: "Stay strong, stay focused.", category: "focus", index: 1),
      ];
      _currentIndex = 0;
    }
  }

  QuoteModel getRandomQuote(List<int> recentIndices, {List<String>? enabledCategories}) {
    if (_allQuotes.isEmpty) {
      return QuoteModel(text: "Stay positive.", category: "motivation", index: 0);
    }

    int startIndex = _currentIndex;

    while (true) {
      final q = _allQuotes[_currentIndex];
      _currentIndex = (_currentIndex + 1) % _allQuotes.length;

      bool matchesCategory = true;
      if (enabledCategories != null && enabledCategories.isNotEmpty) {
        matchesCategory = enabledCategories.contains(q.category);
      }

      bool isRecent = recentIndices.contains(q.index);

      if (matchesCategory && !isRecent) {
        return q;
      }

      if (_currentIndex == startIndex) {
        break;
      }
    }

    // Fallback if everything is filtered or recent
    if (enabledCategories != null && enabledCategories.isNotEmpty) {
      final pool = _allQuotes
          .where((q) => enabledCategories.contains(q.category))
          .toList();
      if (pool.isNotEmpty) {
        return pool.first;
      }
    }

    return _allQuotes.first;
  }

  List<QuoteModel> searchQuotes(String query) {
    final lowerQuery = query.toLowerCase();
    return _allQuotes
        .where((q) => q.text.toLowerCase().contains(lowerQuery))
        .toList();
  }

  List<QuoteModel> filterByCategory(String category) {
    return _allQuotes.where((q) => q.category == category).toList();
  }

  List<QuoteModel> searchAndFilter(String query, String? category) {
    var results = _allQuotes;

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results
          .where((q) => q.text.toLowerCase().contains(lowerQuery))
          .toList();
    }

    if (category != null && category.isNotEmpty) {
      results = results.where((q) => q.category == category).toList();
    }

    return results;
  }
}
