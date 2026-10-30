import 'package:ftastro/features/journal/domain/index.dart';

class JournalEntryModel {
  const JournalEntryModel({
    required this.id,
    required this.title,
    required this.body,
    required this.moodScore,
    required this.createdAt,
    required this.tags,
  });

  final String id;
  final String title;
  final String body;
  final int moodScore;
  final DateTime createdAt;
  final List<String> tags;

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      moodScore: json['mood'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  factory JournalEntryModel.fromEntity(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      title: entry.title,
      body: entry.body,
      moodScore: entry.mood.score,
      createdAt: entry.createdAt,
      tags: entry.tags.map((tag) => tag.name).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'mood': moodScore,
        'created_at': createdAt.toIso8601String(),
        'tags': tags,
      };

  JournalEntry toEntity() {
    return JournalEntry(
      id: id,
      title: title,
      body: body,
      mood: Mood.fromScore(moodScore),
      createdAt: createdAt,
      // ignore unknown tags instead of crashing on old data
      tags: tags
          .map((name) => EntryTag.values.where((tag) => tag.name == name))
          .expand((match) => match)
          .toList(),
    );
  }
}
