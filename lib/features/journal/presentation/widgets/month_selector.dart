import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ftastro/core/index.dart';
import 'package:intl/intl.dart';

/// Horizontal row of month pills. The selected one is kept centred, so the
/// neighbours peek in from both edges like in the design.
class MonthSelector extends StatefulWidget {
  const MonthSelector({
    super.key,
    required this.months,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> months;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  static const _pillWidth = 107.0;
  static const _gap = 10.0;

  ScrollController? _controller;

  int get _selectedIndex => widget.months.indexOf(widget.selected);

  double _offsetFor(int index, double viewport) =>
      index * (_pillWidth + _gap) - (viewport - _pillWidth) / 2;

  @override
  void didUpdateWidget(MonthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (oldWidget.selected != widget.selected &&
        controller != null &&
        controller.hasClients) {
      controller.animateTo(
        _offsetFor(_selectedIndex, controller.position.viewportDimension)
            .clamp(0, controller.position.maxScrollExtent),
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // created once we know the width, so the first frame is centred
          _controller ??= ScrollController(
            initialScrollOffset:
                _offsetFor(_selectedIndex, constraints.maxWidth)
                    .clamp(0, double.infinity),
          );
          return ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemCount: widget.months.length,
            separatorBuilder: (_, __) => const SizedBox(width: _gap),
            itemBuilder: (context, index) {
              final month = widget.months[index];
              return _MonthPill(
                label: DateFormat('MMM').format(month),
                isSelected: month == widget.selected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onSelected(month);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MonthPill extends StatelessWidget {
  const _MonthPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        curve: Curves.easeOutCubic,
        width: _MonthSelectorState._pillWidth,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.monthPillSelected : AppColors.monthPill,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected
                ? AppColors.monthPillSelected
                : AppColors.monthPillBorder,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: AppDurations.medium,
          style: AppTextStyles.label.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.astroInk,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
