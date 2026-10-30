part of 'entry_editor_cubit.dart';

enum EditorStatus { editing, saving, saved, failure }

final class EntryEditorState extends Equatable {
  const EntryEditorState({
    required this.createdAt,
    this.original,
    this.mood,
    this.title = '',
    this.body = '',
    this.tags = const [],
    this.status = EditorStatus.editing,
  });

  /// Null when creating a new entry.
  final JournalEntry? original;
  final DateTime createdAt;
  final Mood? mood;
  final String title;
  final String body;
  final List<EntryTag> tags;
  final EditorStatus status;

  bool get isEditing => original != null;

  bool get canSave =>
      mood != null &&
      (title.trim().isNotEmpty || body.trim().isNotEmpty) &&
      status != EditorStatus.saving;

  EntryEditorState copyWith({
    Mood? mood,
    String? title,
    String? body,
    List<EntryTag>? tags,
    EditorStatus? status,
  }) {
    return EntryEditorState(
      original: original,
      createdAt: createdAt,
      mood: mood ?? this.mood,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [original, createdAt, mood, title, body, tags, status];
}
