import 'dart:async';

import 'package:ftastro/features/journal/data/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';

class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(this._localDataSource);

  final JournalLocalDataSource _localDataSource;
  final _changes = StreamController<List<JournalEntry>>.broadcast();

  Future<List<JournalEntry>>? _initialLoad;
  List<JournalEntry> _entries = const [];

  Future<List<JournalEntry>> _ensureLoaded() {
    return _initialLoad ??= _localDataSource.getEntries().then((models) {
      _entries = _sorted(models.map((model) => model.toEntity()).toList());
      return _entries;
    });
  }

  @override
  Stream<List<JournalEntry>> watchEntries() async* {
    await _ensureLoaded();
    yield _entries;
    yield* _changes.stream;
  }

  @override
  Future<void> saveEntry(JournalEntry entry) async {
    await _ensureLoaded();
    await _localDataSource.saveEntry(JournalEntryModel.fromEntity(entry));

    final updated = [..._entries];
    final index = updated.indexWhere((e) => e.id == entry.id);
    if (index == -1) {
      updated.add(entry);
    } else {
      updated[index] = entry;
    }
    _publish(updated);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _ensureLoaded();
    await _localDataSource.deleteEntry(id);
    _publish(_entries.where((e) => e.id != id).toList());
  }

  void _publish(List<JournalEntry> entries) {
    _entries = _sorted(entries);
    _changes.add(_entries);
  }

  List<JournalEntry> _sorted(List<JournalEntry> entries) {
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(entries);
  }

  void dispose() => _changes.close();
}
