import 'package:flutter/material.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';

/// Small read-only tag used on cards and the detail page.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag, this.large = false});

  final EntryTag tag;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 7 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: large ? 15 : 12, color: AppColors.astroTealDark),
          SizedBox(width: large ? 6 : 4),
          Text(
            tag.label,
            style:
                (large ? AppTextStyles.label : AppTextStyles.caption).copyWith(
              color: AppColors.astroTealDark,
              fontSize: large ? 13 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Toggleable version for the editor.
class SelectableTagChip extends StatelessWidget {
  const SelectableTagChip({
    super.key,
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  final EntryTag tag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? Colors.white : AppColors.astroInkSoft;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.monthPillSelected : AppColors.monthPill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected
                ? AppColors.monthPillSelected
                : AppColors.monthPillBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tag.icon, size: 16, color: foreground),
            const SizedBox(width: 6),
            Text(
              tag.label,
              style: AppTextStyles.label.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
