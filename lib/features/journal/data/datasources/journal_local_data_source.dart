import 'package:ftastro/features/journal/data/index.dart';

abstract class JournalLocalDataSource {
  Future<List<JournalEntryModel>> getEntries();

  Future<void> saveEntry(JournalEntryModel entry);

  Future<void> deleteEntry(String id);
}

/// Keeps entries in memory as json maps, like a local db would.
/// Data is seeded from [JournalMockData] and resets on app restart.
class JournalLocalDataSourceImpl implements JournalLocalDataSource {
  JournalLocalDataSourceImpl() : _rows = JournalMockData.generate();

  final List<Map<String, dynamic>> _rows;

  // fake delay so the loading states are actually visible
  static const _latency = Duration(milliseconds: 600);

  @override
  Future<List<JournalEntryModel>> getEntries() async {
    await Future<void>.delayed(_latency);
    return _rows.map(JournalEntryModel.fromJson).toList();
  }

  @override
  Future<void> saveEntry(JournalEntryModel entry) async {
    final index = _rows.indexWhere((row) => row['id'] == entry.id);
    if (index == -1) {
      _rows.add(entry.toJson());
    } else {
      _rows[index] = entry.toJson();
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    _rows.removeWhere((row) => row['id'] == id);
  }
}
