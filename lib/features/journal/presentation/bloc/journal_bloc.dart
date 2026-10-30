import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/features/journal/domain/index.dart';

part 'journal_event.dart';
part 'journal_state.dart';

/// Using a Bloc here (not a Cubit) because the journal has quite a few
/// independent user events and it's easier to trace them in logs.
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc({
    required WatchJournalEntries watchEntries,
    required DeleteJournalEntry deleteEntry,
    required SaveJournalEntry saveEntry,
  })  : _watchEntries = watchEntries,
        _deleteEntry = deleteEntry,
        _saveEntry = saveEntry,
        super(_initialState(DateTime.now())) {
    on<JournalSubscriptionRequested>(_onSubscriptionRequested);
    on<JournalMonthSelected>(_onMonthSelected);
    on<JournalEntryDeleted>(_onEntryDeleted);
    on<JournalUndoDeleteRequested>(_onUndoDeleteRequested);
  }

  final WatchJournalEntries _watchEntries;
  final DeleteJournalEntry _deleteEntry;
  final SaveJournalEntry _saveEntry;

  /// Last 12 months plus next month, current month selected.
  static JournalState _initialState(DateTime now) {
    final current = DateTime(now.year, now.month);
    return JournalState(
      months: [
        for (var i = -11; i <= 1; i++) DateTime(now.year, now.month + i),
      ],
      selectedMonth: current,
    );
  }

  Future<void> _onSubscriptionRequested(
    JournalSubscriptionRequested event,
    Emitter<JournalState> emit,
  ) async {
    emit(state.copyWith(status: JournalStatus.loading));

    await emit.forEach<List<JournalEntry>>(
      _watchEntries(),
      onData: (entries) => state.copyWith(
        status: JournalStatus.success,
        entries: entries,
      ),
      onError: (_, __) => state.copyWith(status: JournalStatus.failure),
    );
  }

  void _onMonthSelected(
    JournalMonthSelected event,
    Emitter<JournalState> emit,
  ) {
    emit(state.copyWith(selectedMonth: event.month));
  }

  Future<void> _onEntryDeleted(
    JournalEntryDeleted event,
    Emitter<JournalState> emit,
  ) async {
    // remove synchronously, Dismissible complains if the item is still
    // in the tree on the next frame
    emit(
      state.copyWith(
        entries: state.entries.where((e) => e.id != event.entry.id).toList(),
        lastDeleted: () => event.entry,
      ),
    );

    await _deleteEntry(event.entry.id);
  }

  Future<void> _onUndoDeleteRequested(
    JournalUndoDeleteRequested event,
    Emitter<JournalState> emit,
  ) async {
    final entry = state.lastDeleted;
    if (entry == null) return;

    emit(state.copyWith(lastDeleted: () => null));
    await _saveEntry(entry);
  }
}
