import 'package:equatable/equatable.dart';
import 'package:ftastro/features/journal/domain/index.dart';

class JournalEntry extends Equatable {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.createdAt,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String body;
  final Mood mood;
  final DateTime createdAt;
  final List<EntryTag> tags;

  JournalEntry copyWith({
    String? title,
    String? body,
    Mood? mood,
    DateTime? createdAt,
    List<EntryTag>? tags,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      mood: mood ?? this.mood,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [id, title, body, mood, createdAt, tags];
}
