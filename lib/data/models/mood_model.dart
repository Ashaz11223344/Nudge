import 'dart:convert';

class MoodModel {
  final String emoji;
  final String label;
  final DateTime date;
  final String? note;

  const MoodModel({
    required this.emoji,
    required this.label,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'label': label,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory MoodModel.fromJson(Map<String, dynamic> json) => MoodModel(
        emoji: json['emoji'] as String,
        label: json['label'] as String,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
      );

  static String encodeList(List<MoodModel> moods) {
    return jsonEncode(moods.map((m) => m.toJson()).toList());
  }

  static List<MoodModel> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => MoodModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static const List<Map<String, String>> availableMoods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😤', 'label': 'Angry'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '🥰', 'label': 'Loved'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '🤔', 'label': 'Thoughtful'},
    {'emoji': '💪', 'label': 'Strong'},
  ];
}
