import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/features/journal/domain/index.dart';

part 'entry_editor_state.dart';

class EntryEditorCubit extends Cubit<EntryEditorState> {
  EntryEditorCubit({
    required SaveJournalEntry saveEntry,
    JournalEntry? entry,
    Mood? initialMood,
    String? initialTitle,
  })  : _saveEntry = saveEntry,
        super(
          EntryEditorState(
            original: entry,
            createdAt: entry?.createdAt ?? DateTime.now(),
            mood: entry?.mood ?? initialMood,
            title: entry?.title ?? initialTitle ?? '',
            body: entry?.body ?? '',
            tags: entry?.tags ?? const [],
          ),
        );

  final SaveJournalEntry _saveEntry;

  void moodChanged(Mood mood) => emit(state.copyWith(mood: mood));

  void titleChanged(String value) => emit(state.copyWith(title: value));

  void bodyChanged(String value) => emit(state.copyWith(body: value));

  void tagToggled(EntryTag tag) {
    final tags = [...state.tags];
    tags.contains(tag) ? tags.remove(tag) : tags.add(tag);
    emit(state.copyWith(tags: tags));
  }

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(status: EditorStatus.saving));

    final entry = JournalEntry(
      id: state.original?.id ??
          'entry-${DateTime.now().microsecondsSinceEpoch}',
      title: state.title,
      body: state.body,
      mood: state.mood!,
      createdAt: state.createdAt,
      tags: state.tags,
    );

    try {
      await _saveEntry(entry);
      emit(state.copyWith(status: EditorStatus.saved));
    } catch (_) {
      emit(state.copyWith(status: EditorStatus.failure));
    }
  }
}
