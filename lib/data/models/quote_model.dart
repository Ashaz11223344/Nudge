import 'dart:convert';

class QuoteModel {
  final String text;
  final String category;
  final int index;

  const QuoteModel({
    required this.text,
    required this.category,
    required this.index,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'category': category,
        'index': index,
      };

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
        text: json['text'] as String,
        category: json['category'] as String,
        index: json['index'] as int,
      );

  static String encodeList(List<QuoteModel> quotes) {
    return jsonEncode(quotes.map((q) => q.toJson()).toList());
  }

  static List<QuoteModel> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => QuoteModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteModel &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          category == other.category;

  @override
  int get hashCode => text.hashCode ^ category.hashCode;
}
