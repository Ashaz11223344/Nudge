import 'dart:convert';
import 'package:uuid/uuid.dart';

class JournalModel {
  final String id;
  String text;
  final DateTime date;
  DateTime lastEdited;

  JournalModel({
    String? id,
    required this.text,
    required this.date,
    DateTime? lastEdited,
  })  : id = id ?? const Uuid().v4(),
        lastEdited = lastEdited ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'date': date.toIso8601String(),
        'lastEdited': lastEdited.toIso8601String(),
      };

  factory JournalModel.fromJson(Map<String, dynamic> json) => JournalModel(
        id: json['id'] as String,
        text: json['text'] as String,
        date: DateTime.parse(json['date'] as String),
        lastEdited: DateTime.parse(json['lastEdited'] as String),
      );

  static String encodeList(List<JournalModel> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }

  static List<JournalModel> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => JournalModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
