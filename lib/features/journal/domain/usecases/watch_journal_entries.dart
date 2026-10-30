import 'package:ftastro/features/journal/domain/index.dart';

class WatchJournalEntries {
  const WatchJournalEntries(this._repository);

  final JournalRepository _repository;

  Stream<List<JournalEntry>> call() => _repository.watchEntries();
}
