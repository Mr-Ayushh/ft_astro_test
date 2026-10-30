import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/insights/domain/index.dart';
import 'package:ftastro/features/insights/presentation/index.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = math.max(27.0, (width - AppSizes.maxContentWidth) / 2);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(0, 0.1),
          colors: [
            AppColors.journalBgTop,
            AppColors.journalBgWarm,
            Colors.white,
          ],
          stops: [0, 0.5, 1],
        ),
      ),
      child: Stack(
        children: [
          // faint concentric circles behind the header, like the design
          const Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _CirclesPatternPainter()),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: BlocBuilder<InsightsCubit, InsightsState>(
              builder: (context, state) {
                if (state.status == InsightsStatus.failure) {
                  return const Center(
                    child: EmptyState(
                      icon: Icons.insights_rounded,
                      title: 'Couldn\'t load insights',
                      message: 'Please try again in a moment.',
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.only(
                    top: AppSpacing.lg,
                    bottom: Responsive.scrollBottomPadding(context),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Text(
                        'Insights',
                        style: AppTextStyles.h3
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PeriodTabs(
                      selected: state.period,
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      onSelected: context.read<InsightsCubit>().periodSelected,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.chart != null)
                      FadeSlideIn(child: ZodiacProfile(chart: state.chart!)),
                    const SizedBox(height: AppSpacing.md),
                    const Center(child: SparkleCluster()),
                    const SizedBox(height: AppSpacing.xl),
                    if (state.insight != null)
                      AnimatedSwitcher(
                        duration: AppDurations.medium,
                        switchInCurve: Curves.easeOut,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.02),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: _InsightBody(
                          key: ValueKey(state.insight!.period),
                          insight: state.insight!,
                          horizontal: horizontal,
                        ),
                      )
                    else
                      const Center(child: CircularProgressIndicator()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBody extends StatelessWidget {
  const _InsightBody({
    super.key,
    required this.insight,
    required this.horizontal,
  });

  final AstroInsight insight;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    const label = TextStyle(fontSize: 13);
    const gap = SizedBox(height: AppSpacing.lg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ASTROLOGY', style: AppTextStyles.sectionLabel.merge(label)),
              const SizedBox(height: AppSpacing.md),
              FocusOfTheDayCard(area: insight.focusArea),
              gap,
              TodayHoroscopeCard(text: insight.horoscope),
              const SizedBox(height: AppSpacing.xl),
              LuckyRow(insight: insight),
              const SizedBox(height: AppSpacing.xl),
              FunFactsCard(text: insight.funFact),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'NUMEROLOGY',
                style: AppTextStyles.sectionLabel.merge(label),
              ),
              const SizedBox(height: AppSpacing.md),
              NumerologyCard(
                luckyNumber: insight.luckyNumber,
                guidance: insight.guidance,
                showNumber: true,
              ),
              gap,
            ],
          ),
        ),
        DestinyCard(number: insight.destinyNumber, title: insight.destinyTitle),
      ],
    );
  }
}

/// Faint concentric arcs in the top left corner, fading out towards the
/// middle of the screen like in the design.
class _CirclesPatternPainter extends CustomPainter {
  const _CirclesPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width * 0.12, 60);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width * 0.75, 330),
        const [Color(0x409DB9BD), Color(0x009DB9BD)],
      );
    for (var r = 90.0; r <= 420; r += 24) {
      canvas.drawCircle(centre, r, paint);
    }
  }

  @override
  bool shouldRepaint(_CirclesPatternPainter oldDelegate) => false;
}
