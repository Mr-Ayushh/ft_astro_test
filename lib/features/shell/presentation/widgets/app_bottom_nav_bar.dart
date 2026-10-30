import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/shell/presentation/index.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelected;

  static const _items = [
    (AppTab.home, 'Home', AppAssets.navHome),
    (AppTab.goals, 'Goals', AppAssets.navGoals),
    (AppTab.journal, 'Journal', AppAssets.navJournal),
    (AppTab.insights, 'Insights', AppAssets.navInsights),
  ];

  @override
  Widget build(BuildContext context) {
    final index = _items.indexWhere((item) => item.$1 == current);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Stack(
            children: [
              // indicator + glow slide to the selected tab
              AnimatedAlign(
                duration: AppDurations.medium,
                curve: Curves.easeOutCubic,
                alignment: Alignment(-1 + 2 * index / (_items.length - 1), -1),
                child: FractionallySizedBox(
                  widthFactor: 1 / _items.length,
                  child: const _ActiveIndicator(),
                ),
              ),
              Row(
                children: [
                  for (final (tab, label, icon) in _items)
                    Expanded(
                      child: _NavItem(
                        label: label,
                        icon: icon,
                        isSelected: tab == current,
                        onTap: () {
                          if (tab == current) return;
                          HapticFeedback.selectionClick();
                          onSelected(tab);
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.astroTeal : AppColors.navInactive;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            const SizedBox(height: 12),
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: color),
              duration: AppDurations.medium,
              builder: (context, value, _) => SvgPicture.asset(
                icon,
                height: 25,
                colorFilter: ColorFilter.mode(value ?? color, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: AppDurations.medium,
              style: AppTextStyles.label.copyWith(
                fontSize: 14,
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveIndicator extends StatelessWidget {
  const _ActiveIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 4,
            child: Container(
              width: 60,
              height: 44,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.navGlow.withOpacity(0.35),
                    AppColors.navGlow.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          const CustomPaint(size: Size(34, 9), painter: _IndicatorPainter()),
        ],
      ),
    );
  }
}

/// Short bar along the top edge with a small notch pointing at the icon.
class _IndicatorPainter extends CustomPainter {
  const _IndicatorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.astroTeal;
    const barHeight = 5.0;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, size.width, barHeight),
        bottomLeft: const Radius.circular(3),
        bottomRight: const Radius.circular(3),
      ),
      paint,
    );
    final mid = size.width / 2;
    canvas.drawPath(
      Path()
        ..moveTo(mid - 5, barHeight - 0.5)
        ..lineTo(mid, size.height)
        ..lineTo(mid + 5, barHeight - 0.5)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_IndicatorPainter oldDelegate) => false;
}
