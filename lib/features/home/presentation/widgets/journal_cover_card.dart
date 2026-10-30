import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';

/// Journal cover on home. Slide it to the left (or tap) and it swings open
/// on its spiral like a real notebook, then [onOpened] takes the user to the
/// journal tab.
class JournalCoverCard extends StatefulWidget {
  const JournalCoverCard({super.key, required this.onOpened});

  final VoidCallback onOpened;

  @override
  State<JournalCoverCard> createState() => _JournalCoverCardState();
}

class _JournalCoverCardState extends State<JournalCoverCard>
    with SingleTickerProviderStateMixin {
  // the cover art is 363x418 and a little wider than the content column
  static const _coverWidth = 363.0;
  static const _coverHeight = 418.0;
  static const _contentWidth = 348.0;

  // 0 = closed, 1 = fully open and transitioned to journal screen
  late final AnimationController _open = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );

  // 1. 3D Cover swings open (0.0 to 0.72) — gives the half-open glimpse
  late final Animation<double> _coverAngle = Tween<double>(
    begin: 0.0,
    end: math.pi * 0.58,
  ).animate(
    CurvedAnimation(
      parent: _open,
      curve: const Interval(0.0, 0.72, curve: Curves.easeOutCubic),
    ),
  );

  // 2. Dynamic cast shadow under the swinging cover
  late final Animation<double> _shadowCurve = CurvedAnimation(
    parent: _open,
    curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
  );

  // 3. Cinematic zoom forward into the viewport as the book completes opening
  late final Animation<double> _cardScale = Tween<double>(
    begin: 1.0,
    end: 1.28,
  ).animate(
    CurvedAnimation(
      parent: _open,
      curve: const Interval(0.48, 1.0, curve: Curves.easeInOutCubic),
    ),
  );

  // 4. Soft seamless blend into the journal screen's background gradient
  late final Animation<double> _screenBlend = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _open,
      curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
    ),
  );

  Timer? _hintTimer;
  double _width = _coverWidth;

  @override
  void initState() {
    super.initState();
    // small peek once, so people notice the cover can be slid open
    _hintTimer = Timer(const Duration(milliseconds: 1600), () async {
      if (!mounted || _open.value != 0) return;
      await _open.animateTo(
        0.14,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
      if (mounted) {
        await _open.animateBack(
          0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _open.dispose();
    super.dispose();
  }

  Future<void> _openFully() async {
    _hintTimer?.cancel();
    HapticFeedback.mediumImpact();
    await _open.forward();
    if (!mounted) return;
    widget.onOpened();
    // silent reset ready for when user navigates back to Home
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _open.reset();
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _hintTimer?.cancel();
    // dragging left opens the cover
    _open.value -= details.primaryDelta! / _width;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_open.value > 0.35 || velocity < -500) {
      _openFully();
    } else {
      _open.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth * _coverWidth / _contentWidth;
        final height = _width * _coverHeight / _coverWidth;

        return SizedBox(
          height: height,
          child: OverflowBox(
            maxWidth: _width,
            child: Semantics(
              button: true,
              label: 'Open your journal',
              hint: 'Slide left to open',
              child: GestureDetector(
                onTap: _openFully,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: AnimatedBuilder(
                  animation: _open,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _cardScale.value,
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Inside notebook page with top 10 recent entries
                      const Positioned.fill(
                        child: RepaintBoundary(child: _InsidePage()),
                      ),

                      // 2. Dynamic cast shadow on the inside page as the cover lifts
                      AnimatedBuilder(
                        animation: _shadowCurve,
                        builder: (context, _) {
                          final progress = _shadowCurve.value;
                          if (progress <= 0.01) return const SizedBox.shrink();

                          final shadowOpacity =
                              (0.35 * (1.0 - progress * 0.75)).clamp(0.0, 0.35);
                          final shadowWidth =
                              (_width * 0.85 * (1.0 - progress * 0.8))
                                  .clamp(0.0, _width);

                          return Positioned(
                            left: 28,
                            top: 10,
                            bottom: 10,
                            width: shadowWidth,
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(shadowOpacity),
                                      blurRadius: 12 + 16 * progress,
                                      offset: Offset(6 * (1.0 - progress), 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // 3. The 3D rotating cover with GPU-accelerated perspective
                      AnimatedBuilder(
                        animation: _coverAngle,
                        builder: (context, child) {
                          final angle = _coverAngle.value;
                          final t = (_open.value / 0.72).clamp(0.0, 1.0);

                          return Transform(
                            alignment: Alignment.centerLeft,
                            transform: Matrix4.identity()
                              ..setEntry(
                                3,
                                2,
                                0.0010,
                              )
                              ..rotateY(angle),
                            child: Stack(
                              children: [
                                child!,
                                // Dynamic 3D shading overlay on the cover surface
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                          right: Radius.circular(AppRadius.lg),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.black.withOpacity(0.15 * t),
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.28 * t),
                                          ],
                                          stops: const [0.0, 0.45, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: RepaintBoundary(
                          child: SvgPicture.asset(
                            AppAssets.journalCover,
                            width: _width,
                          ),
                        ),
                      ),

                      // 4. Smooth wash transition into Journal page on full open
                      AnimatedBuilder(
                        animation: _screenBlend,
                        builder: (context, _) {
                          final opacity = _screenBlend.value;
                          if (opacity <= 0.01) return const SizedBox.shrink();

                          return Positioned.fill(
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: opacity,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
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
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// First page of the notebook, seen while the cover swings open.
/// Displays the user's top recent entries (up to 10) dynamically from [JournalBloc].
class _InsidePage extends StatelessWidget {
  const _InsidePage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final sortedEntries = List<JournalEntry>.from(state.entries)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final topEntries = sortedEntries.take(10).toList();
        final totalCount = state.entries.length;

        final String countText;
        if (state.isLoading && totalCount == 0) {
          countText = 'Loading...';
        } else if (totalCount == 0) {
          countText = '0 entries';
        } else if (totalCount <= 10) {
          countText = '$totalCount ${totalCount == 1 ? 'entry' : 'entries'}';
        } else {
          countText = 'Top 10 of $totalCount';
        }

        return Padding(
          // keeps the page behind the cover, not under the spiral
          padding: const EdgeInsets.fromLTRB(28, 6, 8, 6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.monthPill,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.monthPillBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'RECENT ENTRIES',
                        style: AppTextStyles.sectionLabel.copyWith(
                          fontSize: 10.5,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.astroTealDark.withOpacity(0.75),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        countText,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.monthPillBorder,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: topEntries.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_stories_outlined,
                                    size: 26,
                                    color: AppColors.astroTealDark
                                        .withOpacity(0.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.isLoading
                                        ? 'Loading your thoughts...'
                                        : 'No entries yet',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.astroTealDark
                                          .withOpacity(0.75),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.isLoading
                                        ? 'Opening your journal'
                                        : 'Tap anywhere to write your first entry',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10.5,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            itemCount: topEntries.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 12,
                              thickness: 0.6,
                              color:
                                  AppColors.monthPillBorder.withOpacity(0.55),
                            ),
                            itemBuilder: (context, index) {
                              final entry = topEntries[index];
                              final title = entry.title.trim().isNotEmpty
                                  ? entry.title.trim()
                                  : 'Untitled entry';

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    child: Text(
                                      '${index + 1}.',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.astroTealDark,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.astroInk,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
