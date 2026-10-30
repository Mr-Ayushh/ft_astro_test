import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/insights/domain/index.dart';

/// "YESTERDAY ·•· TODAY ·•· TOMORROW ..." strip. The selected period is teal
/// with an underline that has a small dot in the middle.
class PeriodTabs extends StatelessWidget {
  const PeriodTabs({
    super.key,
    required this.selected,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  final InsightPeriod selected;
  final ValueChanged<InsightPeriod> onSelected;
  final EdgeInsetsGeometry padding;

  static const _inactive = Color(0xFF6E7C7F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: InsightPeriod.values.length,
        separatorBuilder: (_, __) => const _Separator(),
        itemBuilder: (context, index) {
          final period = InsightPeriod.values[index];
          final isSelected = period == selected;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isSelected) return;
              HapticFeedback.selectionClick();
              onSelected(period);
            },
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: AppDurations.medium,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.astroTealDark : _inactive,
                    ),
                    child: Text(period.label.toUpperCase()),
                  ),
                  const SizedBox(height: 3),
                  AnimatedOpacity(
                    duration: AppDurations.medium,
                    opacity: isSelected ? 1 : 0,
                    child: const _Underline(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Underline extends StatelessWidget {
  const _Underline();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // left line segment
          Expanded(
            child: Container(height: 1.5, color: AppColors.astroTealDark),
          ),

          const SizedBox(width: 4),
          // center dot
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.astroTealDark,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          // right line segment
          Expanded(
            child: Container(height: 1.5, color: AppColors.astroTealDark),
          ),
        ],
      ),
    );
  }
}

/// `·•·` between the periods.
class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    Widget dot(double size) => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: PeriodTabs._inactive,
            shape: BoxShape.circle,
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot(2.5),
          const SizedBox(width: 4),
          dot(4.5),
          const SizedBox(width: 4),
          dot(2.5),
        ],
      ),
    );
  }
}
