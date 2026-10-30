import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';

/// Row of five faces. [onDark] switches colours for use on the purple
/// check-in card.
class MoodPicker extends StatelessWidget {
  const MoodPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.onDark = false,
    this.faceSize = 40,
  });

  final Mood? selected;
  final ValueChanged<Mood> onChanged;
  final bool onDark;
  final double faceSize;

  @override
  Widget build(BuildContext context) {
    // great first, reads more naturally left to right in this app
    final moods = Mood.values.reversed.toList();

    return Row(
      children: [
        for (final mood in moods)
          Expanded(
            child: _MoodOption(
              mood: mood,
              isSelected: mood == selected,
              isDimmed: selected != null && mood != selected,
              onDark: onDark,
              faceSize: faceSize,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(mood);
              },
            ),
          ),
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.mood,
    required this.isSelected,
    required this.isDimmed,
    required this.onDark,
    required this.faceSize,
    required this.onTap,
  });

  final Mood mood;
  final bool isSelected;
  final bool isDimmed;
  final bool onDark;
  final double faceSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ringColor = onDark ? Colors.white : mood.color;
    final idleBg =
        onDark ? Colors.white.withOpacity(0.12) : AppColors.monthPill;
    final selectedBg = onDark ? Colors.white : mood.softColor;
    final labelColor = onDark
        ? Colors.white.withOpacity(isSelected ? 1 : 0.75)
        : (isSelected ? AppColors.textPrimary : AppColors.textSecondary);

    return Semantics(
      button: true,
      selected: isSelected,
      label: mood.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedOpacity(
          duration: AppDurations.medium,
          opacity: isDimmed ? 0.55 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.12 : (isDimmed ? 0.92 : 1),
                duration: AppDurations.medium,
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: AppDurations.medium,
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? selectedBg : idleBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? ringColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: MoodFace(mood: mood, size: faceSize),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AnimatedDefaultTextStyle(
                duration: AppDurations.fast,
                style: AppTextStyles.caption.copyWith(
                  color: labelColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(mood.label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
