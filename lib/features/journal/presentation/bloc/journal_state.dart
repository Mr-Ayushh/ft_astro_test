part of 'journal_bloc.dart';

enum JournalStatus { initial, loading, success, failure }

final class JournalState extends Equatable {
  const JournalState({
    required this.months,
    required this.selectedMonth,
    this.status = JournalStatus.initial,
    this.entries = const [],
    this.lastDeleted,
  });

  final JournalStatus status;

  /// Every entry, newest first. Use [visibleEntries] for the list.
  final List<JournalEntry> entries;

  /// Months shown in the selector, oldest first. Each is the 1st of a month.
  final List<DateTime> months;
  final DateTime selectedMonth;

  /// Kept around so the snackbar can undo a delete.
  final JournalEntry? lastDeleted;

  bool get isLoading =>
      status == JournalStatus.initial || status == JournalStatus.loading;

  List<JournalEntry> get visibleEntries => entries
      .where(
        (e) =>
            e.createdAt.year == selectedMonth.year &&
            e.createdAt.month == selectedMonth.month,
      )
      .toList();

  JournalEntry? entryById(String id) =>
      entries.where((entry) => entry.id == id).firstOrNull;

  JournalState copyWith({
    JournalStatus? status,
    List<JournalEntry>? entries,
    DateTime? selectedMonth,
    JournalEntry? Function()? lastDeleted,
  }) {
    return JournalState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      months: months,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      lastDeleted: lastDeleted != null ? lastDeleted() : this.lastDeleted,
    );
  }

  @override
  List<Object?> get props =>
      [status, entries, months, selectedMonth, lastDeleted];
}
