import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';

/// Create a new entry, or edit [entry] when it's passed in.
/// Pops with `true` once saved.
class EntryEditorPage extends StatelessWidget {
  const EntryEditorPage({
    super.key,
    this.entry,
    this.initialMood,
    this.prompt,
  });

  final JournalEntry? entry;
  final Mood? initialMood;

  /// Daily prompt shown above the form when coming from the home screen.
  final String? prompt;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EntryEditorCubit(
        saveEntry: SaveJournalEntry(context.read<JournalRepository>()),
        entry: entry,
        initialMood: initialMood,
      ),
      child: _EditorView(prompt: prompt),
    );
  }
}

class _EditorView extends StatefulWidget {
  const _EditorView({this.prompt});

  final String? prompt;

  @override
  State<_EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<_EditorView> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    final state = context.read<EntryEditorCubit>().state;
    _titleController = TextEditingController(text: state.title);
    _bodyController = TextEditingController(text: state.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges(EntryEditorState state) {
    if (state.status == EditorStatus.saved) return false;
    final original = state.original;
    if (original == null) {
      return state.title.trim().isNotEmpty ||
          state.body.trim().isNotEmpty ||
          state.tags.isNotEmpty;
    }
    return state.title != original.title ||
        state.body != original.body ||
        state.mood != original.mood ||
        !listEquals(state.tags, original.tags);
  }

  Future<void> _onPopBlocked() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('What you wrote here will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep writing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  // close the keyboard first, otherwise it collapses at the same time as the
  // container transform and the close animation looks like a jump
  void _closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    final horizontal = Responsive.horizontalPadding(context);

    return BlocConsumer<EntryEditorCubit, EntryEditorState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == EditorStatus.saved) {
          _closeKeyboard();
          Navigator.pop(context, true);
        } else if (state.status == EditorStatus.failure) {
          showAppSnackBar(context, 'Couldn\'t save the entry, try again');
        }
      },
      builder: (context, state) {
        final cubit = context.read<EntryEditorCubit>();

        return PopScope(
          canPop: !_hasUnsavedChanges(state),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _onPopBlocked();
          },
          child: Scaffold(
            backgroundColor: AppColors.journalBgTop,
            body: DecoratedBox(
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
                    _EditorTopBar(
                      title: state.isEditing ? 'Edit entry' : 'New entry',
                      onClose: () {
                        _closeKeyboard();
                        Navigator.maybePop(context);
                      },
                      saveButton: _SaveButton(
                        enabled: state.canSave,
                        isSaving: state.status == EditorStatus.saving,
                        onPressed: cubit.save,
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          AppSpacing.sm,
                          horizontal,
                          MediaQuery.paddingOf(context).bottom +
                              AppSpacing.xxxl,
                        ),
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 15,
                                color: AppColors.astroTealDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${state.createdAt.fullDateLabel} · '
                                '${state.createdAt.timeLabel}',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (widget.prompt != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _PromptBanner(prompt: widget.prompt!),
                          ],
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'HOW ARE YOU FEELING?',
                            style: AppTextStyles.sectionLabel.copyWith(
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          MoodPicker(
                            selected: state.mood,
                            onChanged: cubit.moodChanged,
                            faceSize: 36,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'YOUR ENTRY',
                            style: AppTextStyles.sectionLabel.copyWith(
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _EntryCard(
                            titleField: TextField(
                              controller: _titleController,
                              onChanged: cubit.titleChanged,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.next,
                              style: AppTextStyles.cardTitle,
                              decoration: const InputDecoration(
                                hintText: 'Give it a title',
                                hintStyle:
                                    TextStyle(color: AppColors.textTertiary),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                            ),
                            bodyField: TextField(
                              controller: _bodyController,
                              onChanged: cubit.bodyChanged,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.multiline,
                              minLines: 6,
                              maxLines: null,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.astroInk,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'What\'s on your mind today?',
                                hintStyle:
                                    TextStyle(color: AppColors.textTertiary),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.sm,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'TAGS',
                            style: AppTextStyles.sectionLabel.copyWith(
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final tag in EntryTag.values)
                                SelectableTagChip(
                                  tag: tag,
                                  isSelected: state.tags.contains(tag),
                                  onTap: () => cubit.tagToggled(tag),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EditorTopBar extends StatelessWidget {
  const _EditorTopBar({
    required this.title,
    required this.onClose,
    required this.saveButton,
  });

  final String title;
  final VoidCallback onClose;
  final Widget saveButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Tooltip(
            message: 'Close',
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.headerButtonBorder),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onClose,
                child: const SizedBox.square(
                  dimension: 42,
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.astroTealDark,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          saveButton,
        ],
      ),
    );
  }
}

/// Title and text inside one card, styled like the journal entry tiles.
class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.titleField, required this.bodyField});

  final Widget titleField;
  final Widget bodyField;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
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
          titleField,
          const Divider(height: 1, color: AppColors.entryTileBorder),
          const SizedBox(height: AppSpacing.xs),
          bodyField,
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.isSaving,
    required this.onPressed,
  });

  final bool enabled;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.monthPillSelected : AppColors.monthPill,
          border: Border.all(
            color: enabled
                ? AppColors.monthPillSelected
                : AppColors.monthPillBorder,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: isSaving
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Save',
                style: AppTextStyles.label.copyWith(
                  color: enabled ? Colors.white : AppColors.textTertiary,
                ),
              ),
      ),
    );
  }
}

class _PromptBanner extends StatelessWidget {
  const _PromptBanner({required this.prompt});

  final String prompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.peachSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.peach,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              prompt,
              style: AppTextStyles.label.copyWith(fontSize: 14, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
