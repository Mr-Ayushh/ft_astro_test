part of 'journal_bloc.dart';

sealed class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

final class JournalSubscriptionRequested extends JournalEvent {
  const JournalSubscriptionRequested();
}

final class JournalMonthSelected extends JournalEvent {
  const JournalMonthSelected(this.month);

  final DateTime month;

  @override
  List<Object?> get props => [month];
}

final class JournalEntryDeleted extends JournalEvent {
  const JournalEntryDeleted(this.entry);

  final JournalEntry entry;

  @override
  List<Object?> get props => [entry];
}

final class JournalUndoDeleteRequested extends JournalEvent {
  const JournalUndoDeleteRequested();
}
