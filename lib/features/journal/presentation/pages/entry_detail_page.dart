import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';
import 'package:intl/intl.dart';

class EntryDetailPage extends StatefulWidget {
  const EntryDetailPage({super.key, required this.entryId});

  final String entryId;

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  // Holds the last known entry so the page doesn't go blank while the
  // close animation runs after a delete.
  JournalEntry? _entry;

  Future<void> _confirmDelete(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are You sure? You want to'),
        content: const Text('Delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final bloc = context.read<JournalBloc>();
    Navigator.pop(context);
    bloc.add(JournalEntryDeleted(entry));
    showAppSnackBar(
      context,
      'Entry deleted',
      actionLabel: 'Undo',
      onAction: () => bloc.add(const JournalUndoDeleteRequested()),
    );
  }

  Future<void> _openEditor(JournalEntry entry) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EntryEditorPage(entry: entry),
      ),
    );
    if (saved == true && mounted) showAppSnackBar(context, 'Changes saved');
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<JournalBloc, JournalState, JournalEntry?>(
      selector: (state) => state.entryById(widget.entryId),
      builder: (context, selected) {
        _entry = selected ?? _entry;
        final entry = _entry;
        if (entry == null) return const Scaffold();

        return Scaffold(
          backgroundColor: AppColors.journalBgTop,
          body: DecoratedBox(
            // same background as the journal screen
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.6, 0.4),
                colors: [
                  AppColors.journalBgTop,
                  AppColors.journalBgWarm,
                  Colors.white,
                ],
                stops: [0, 0.35, 1],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _TopBar(
                    entry: entry,
                    onEdit: () => _openEditor(entry),
                    onDelete: () => _confirmDelete(entry),
                  ),
                  Expanded(child: _EntryBody(entry: entry)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final JournalEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          _RoundButton(
            tooltip: 'Back',
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          const Spacer(),
          _RoundButton(
            tooltip: 'Edit',
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          _RoundButton(
            tooltip: 'Delete',
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.child, this.onTap, this.tooltip});

  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surface,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.headerButtonBorder),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 42,
          child: IconTheme(
            data: const IconThemeData(color: AppColors.astroTealDark),
            child: Center(child: child),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

class _EntryBody extends StatelessWidget {
  const _EntryBody({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = math.max(27.0, (width - AppSizes.maxContentWidth) / 2);
    final date = entry.createdAt;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        AppSpacing.md,
        horizontal,
        MediaQuery.paddingOf(context).bottom + AppSpacing.xxxl,
      ),
      children: [
        FadeSlideIn(
          delay: const Duration(milliseconds: 150),
          child: Row(
            children: [
              _DateTile(date: date),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MoodChip(mood: entry.mood),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${DateFormat('EEEE, d MMMM').format(date)} · '
                      '${DateFormat('hh:mm a').format(date)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 220),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title.isEmpty ? 'Untitled entry' : entry.title,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md + 2),
                  border: Border.all(color: AppColors.entryTileBorder),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.entryTileTop, AppColors.entryTileBottom],
                  ),
                ),
                child: Text(
                  entry.body.isEmpty ? 'No notes for this one.' : entry.body,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: entry.body.isEmpty
                        ? AppColors.textTertiary
                        : AppColors.astroInk,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (entry.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          FadeSlideIn(
            delay: const Duration(milliseconds: 300),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final tag in entry.tags) TagChip(tag: tag, large: true),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Same date block as the journal list tiles.
class _DateTile extends StatelessWidget {
  const _DateTile({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        border: Border.all(color: AppColors.entryTileBorder),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.entryTileTop, AppColors.entryTileBottom],
        ),
      ),
      child: Column(
        children: [
          Text(
            '${date.day}',
            style: AppTextStyles.h1.copyWith(
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w500,
              color: AppColors.entryDay,
            ),
          ),
          Text(
            DateFormat('MMM').format(date),
            style: AppTextStyles.h3.copyWith(height: 1.2),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('EEE').format(date),
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.mood});

  final Mood mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      decoration: BoxDecoration(
        color: mood.softColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MoodFace(mood: mood, size: 24),
          const SizedBox(width: 6),
          Text(
            'Feeling ${mood.label.toLowerCase()}',
            style: AppTextStyles.label.copyWith(color: mood.textColor),
          ),
        ],
      ),
    );
  }
}
