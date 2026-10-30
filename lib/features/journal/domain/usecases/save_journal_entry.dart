import 'package:ftastro/features/journal/domain/index.dart';

class SaveJournalEntry {
  const SaveJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<void> call(JournalEntry entry) {
    final cleaned = entry.copyWith(
      title: entry.title.trim(),
      body: entry.body.trim(),
    );
    return _repository.saveEntry(cleaned);
  }
}
