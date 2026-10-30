import 'package:ftastro/features/journal/domain/index.dart';

class DeleteJournalEntry {
  const DeleteJournalEntry(this._repository);

  final JournalRepository _repository;

  Future<void> call(String id) => _repository.deleteEntry(id);
}
