import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';
import 'package:intl/intl.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = math.max(27.0, (width - AppSizes.maxContentWidth) / 2);

    return DecoratedBox(
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
        child: BlocBuilder<JournalBloc, JournalState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 26, horizontal, 0),
                  sliver: SliverToBoxAdapter(
                    child: FadeSlideIn(child: _Header(maxWidth: width)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      children: [
                        const SizedBox(height: 22),
                        MonthSelector(
                          months: state.months,
                          selected: state.selectedMonth,
                          onSelected: (month) => context
                              .read<JournalBloc>()
                              .add(JournalMonthSelected(month)),
                        ),
                        const SizedBox(height: 18),
                        const OrnamentDivider(width: 204),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  sliver: SliverToBoxAdapter(child: _RecentEntriesHeader()),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    AppSpacing.lg,
                    horizontal,
                    Responsive.scrollBottomPadding(context),
                  ),
                  sliver: _EntriesList(state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.maxWidth});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // 340pt wide in the 402pt frame
    final coverWidth = math.min(340.0, maxWidth - 62);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Journal', style: AppTextStyles.cardTitle),
        const SizedBox(height: 4),
        Text(
          'A Space To Be You',
          style: AppTextStyles.body.copyWith(color: AppColors.astroInkSoft),
        ),
        const SizedBox(height: 26),
        Center(
          child: SvgPicture.asset(
            AppAssets.journalCover,
            width: coverWidth,
            semanticsLabel: 'Journal cover',
          ),
        ),
      ],
    );
  }
}

class _RecentEntriesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Entries',
            style: AppTextStyles.h3.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        OpenContainer<bool>(
          transitionDuration: AppDurations.container,
          transitionType: ContainerTransitionType.fade,
          closedElevation: 0,
          openElevation: 0,
          clipBehavior: Clip.antiAlias,
          closedColor: Colors.transparent,
          openColor: AppColors.journalBgTop,
          middleColor: AppColors.journalBgTop,
          closedShape: const StadiumBorder(),
          openShape: const RoundedRectangleBorder(),
          onClosed: (saved) {
            if (saved == true && context.mounted) {
              showAppSnackBar(context, 'Entry saved');
            }
          },
          openBuilder: (_, __) => const RepaintBoundary(
            child: EntryEditorPage(),
          ),
          closedBuilder: (_, __) => RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 22, color: AppColors.astroTeal),
                  const SizedBox(width: 4),
                  Text(
                    'Add Entry',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      color: AppColors.astroTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EntriesList extends StatelessWidget {
  const _EntriesList({required this.state});

  final JournalState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const SliverToBoxAdapter(
        child: SkeletonPulse(
          child: Column(
            children: [
              SkeletonBox(height: 100, radius: AppRadius.md),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 100, radius: AppRadius.md),
            ],
          ),
        ),
      );
    }

    final entries = state.visibleEntries;
    if (entries.isEmpty) {
      return SliverToBoxAdapter(
        child: FadeSlideIn(
          key: ValueKey(state.selectedMonth),
          child: EmptyState(
            icon: Icons.menu_book_rounded,
            title:
                'No entries in ${DateFormat('MMMM').format(state.selectedMonth)}',
            message: 'Tap Add Entry to write about your day.',
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md + 2),
        child: FadeSlideIn(
          // new key per month so the list animates in again when it changes
          key: ValueKey('${state.selectedMonth}-${entries[index].id}'),
          enabled: index < 6,
          delay: Duration(milliseconds: 60 * index.clamp(0, 6)),
          child: _DismissibleEntry(entry: entries[index]),
        ),
      ),
    );
  }
}

class _DismissibleEntry extends StatelessWidget {
  const _DismissibleEntry({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss-${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(AppRadius.md + 2),
        ),
        child:
            const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) {
        final bloc = context.read<JournalBloc>()
          ..add(JournalEntryDeleted(entry));
        showAppSnackBar(
          context,
          'Entry deleted',
          actionLabel: 'Undo',
          onAction: () => bloc.add(const JournalUndoDeleteRequested()),
        );
      },
      child: JournalEntryTile(entry: entry),
    );
  }
}
