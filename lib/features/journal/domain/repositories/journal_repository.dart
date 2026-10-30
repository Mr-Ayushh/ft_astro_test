import 'package:ftastro/features/journal/domain/index.dart';

abstract class JournalRepository {
  /// Emits the full list (newest first) on listen and after every change.
  Stream<List<JournalEntry>> watchEntries();

  /// Inserts the entry, or replaces it if one with the same id exists.
  Future<void> saveEntry(JournalEntry entry);

  Future<void> deleteEntry(String id);
}
