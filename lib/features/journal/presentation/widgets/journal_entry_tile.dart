import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';
import 'package:intl/intl.dart';

/// Entry row from the Figma journal screen: date on the left, title and
/// preview on the right. Opens the detail page with a container transform.
class JournalEntryTile extends StatelessWidget {
  const JournalEntryTile({super.key, required this.entry});

  final JournalEntry entry;

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.md + 2),
    side: const BorderSide(color: AppColors.entryTileBorder),
  );

  @override
  Widget build(BuildContext context) {
    return OpenContainer<void>(
      transitionDuration: AppDurations.container,
      transitionType: ContainerTransitionType.fade,
      closedElevation: 0,
      openElevation: 0,
      clipBehavior: Clip.antiAlias,
      closedShape: _shape,
      openShape: const RoundedRectangleBorder(),
      closedColor: AppColors.entryTileTop,
      openColor: AppColors.journalBgTop,
      middleColor: AppColors.journalBgTop,
      openBuilder: (_, __) => RepaintBoundary(
        child: EntryDetailPage(entryId: entry.id),
      ),
      closedBuilder: (_, __) => RepaintBoundary(
        child: _TileContent(entry: entry),
      ),
    );
  }
}

class _TileContent extends StatelessWidget {
  const _TileContent({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final date = entry.createdAt;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.entryTileTop, AppColors.entryTileBottom],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: 76,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 26,
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
              ),
              Container(width: 1, color: AppColors.entryTileBorder),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title.isEmpty ? 'Untitled entry' : entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.5,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('hh:mm a').format(date),
                      style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SvgPicture.asset(
                  AppAssets.icChevronRight,
                  height: 12,
                  colorFilter: const ColorFilter.mode(
                    AppColors.astroInk,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
