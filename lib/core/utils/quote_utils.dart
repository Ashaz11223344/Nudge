import 'dart:math';

class QuoteUtils {
  QuoteUtils._();

  static final Random _random = Random();

  /// Picks a random index from [total] excluding indices in [recentIndices]
  static int getRandomIndex(int total, List<int> recentIndices) {
    if (total <= 0) return 0;

    // If all indices are in recent, clear recent and pick any
    final available = List.generate(total, (i) => i)
        .where((i) => !recentIndices.contains(i))
        .toList();

    if (available.isEmpty) {
      return _random.nextInt(total);
    }

    return available[_random.nextInt(available.length)];
  }

  /// Parses a quote line in the format "[category] Quote text"
  /// Returns a tuple of (category, quoteText)
  static (String, String) parseQuoteLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return ('', '');

    final categoryMatch = RegExp(r'^\[(\w+)\]\s*(.+)$').firstMatch(trimmed);
    if (categoryMatch != null) {
      return (categoryMatch.group(1)!.toLowerCase(), categoryMatch.group(2)!);
    }

    return ('motivation', trimmed); // Default category
  }
}
