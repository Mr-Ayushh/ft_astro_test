import 'package:flutter/material.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/insights/domain/index.dart';

class FocusOfTheDayCard extends StatelessWidget {
  const FocusOfTheDayCard({super.key, required this.area});

  final String area;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2F4),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFD4E4E8)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _FocusDecorPainter()),
            ),
          ),
          Positioned(
            left: 22,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.title.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9B9B9B),
                  ),
                  children: [
                    const TextSpan(text: 'Focus of the day:  '),
                    TextSpan(
                      text: area,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2F6773),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blurred clouds, two hills and three stacked stones on the right of the
/// focus card. Coordinates follow the Figma card (352x62), anchored right.
class _FocusDecorPainter extends CustomPainter {
  const _FocusDecorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    canvas.translate(size.width - 352, 0);

    // soft clouds along the top
    final cloud = Paint()
      ..color = const Color(0xFFD2E4E9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawOval(const Rect.fromLTWH(180, -14, 90, 34), cloud);
    canvas.drawOval(const Rect.fromLTWH(300, -6, 80, 40), cloud);

    // hills, the lighter one in front
    canvas.drawPath(
      Path()
        ..moveTo(206, h)
        ..quadraticBezierTo(272, h * 0.58, 352, h * 0.6)
        ..lineTo(352, h)
        ..close(),
      Paint()..color = const Color(0xFFA9CDD5),
    );
    canvas.drawPath(
      Path()
        ..moveTo(258, h)
        ..quadraticBezierTo(300, h * 0.7, 352, h * 0.72)
        ..lineTo(352, h)
        ..close(),
      Paint()..color = const Color(0xFF8CAFB6),
    );

    // stones, bottom to top: fill, outline, centre, size
    _stone(
      canvas,
      const Color(0xFF5594A4),
      const Color(0xFF2E6672),
      const Offset(280, 56),
      const Size(42, 19),
    );
    _stone(
      canvas,
      const Color(0xFFEFF6F7),
      const Color(0xFF5E9AA8),
      const Offset(280, 40),
      const Size(36, 14),
    );
    _stone(
      canvas,
      const Color(0xFFC4DFE5),
      const Color(0xFF8CC0CB),
      const Offset(280, 26),
      const Size(24, 13),
    );
  }

  void _stone(Canvas canvas, Color fill, Color outline, Offset c, Size s) {
    final rect = Rect.fromCenter(center: c, width: s.width, height: s.height);
    canvas.drawOval(rect, Paint()..color = fill);
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = outline,
    );
    // small glossy highlight on the left
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(-s.width * 0.22, -s.height * 0.12),
        width: s.width * 0.3,
        height: s.height * 0.3,
      ),
      Paint()..color = Colors.white.withOpacity(0.55),
    );
  }

  @override
  bool shouldRepaint(_FocusDecorPainter oldDelegate) => false;
}

class TodayHoroscopeCard extends StatelessWidget {
  const TodayHoroscopeCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.horoscopeCream,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.horoscopeCreamBorder),
      ),
      child: Stack(
        children: [
          // faint zodiac wheel corner from Figma
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(AppAssets.constellationCorner, width: 161),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your today’s horoscope',
                  style: AppTextStyles.label.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Favourable direction (compass) and lucky colour (clover) side by side.
class LuckyRow extends StatelessWidget {
  const LuckyRow({super.key, required this.insight});

  final AstroInsight insight;

  // the clover art is pink, other colours are tinted from it
  static const _artColourName = 'Pink';

  @override
  Widget build(BuildContext context) {
    final clover = Image.asset(AppAssets.luckyClover, height: 150);

    return Row(
      children: [
        Expanded(
          child: _LuckyItem(
            title: 'Favourable Direction',
            label: insight.direction,
            child: Image.asset(AppAssets.compass, height: 150),
          ),
        ),
        Expanded(
          child: _LuckyItem(
            title: 'Lucky Colour',
            label: insight.luckyColourName,
            child: AnimatedSwitcher(
              duration: AppDurations.medium,
              child: insight.luckyColourName == _artColourName
                  ? clover
                  : ColorFiltered(
                      key: ValueKey(insight.luckyColour),
                      colorFilter: ColorFilter.mode(
                        Color(insight.luckyColour),
                        BlendMode.srcATop,
                      ),
                      child: clover,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LuckyItem extends StatelessWidget {
  const _LuckyItem({
    required this.title,
    required this.label,
    required this.child,
  });

  final String title;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          maxLines: 1,
          style: AppTextStyles.title.copyWith(fontSize: 16),
        ),
        SizedBox(height: 150, child: child),
        OrnamentDivider(
          width: 170,
          child: Text(
            label,
            style: AppTextStyles.title.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.astroTealDark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Dark card with soft, hand torn edges and a thin gold outline. Clouds are
/// the Figma PNGs: outlines behind the text, soft clouds over the edges.
class FunFactsCard extends StatelessWidget {
  const FunFactsCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        Widget outline(double left, double top) => Positioned(
              left: w * left,
              top: top,
              child: Image.asset(AppAssets.cloudOutline, width: w * 0.21),
            );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              foregroundPainter: const _TornEdgeBorderPainter(),
              child: ClipPath(
                clipper: const _TornEdgeClipper(),
                child: ColoredBox(
                  color: AppColors.funFacts,
                  child: Stack(
                    children: [
                      outline(0.49, 4),
                      outline(0.18, 72),
                      outline(0.77, 92),
                      Positioned(
                        left: w * 0.21,
                        bottom: 10,
                        child: const CustomPaint(
                          size: Size.square(12),
                          painter: SparklePainter(Color(0xFF3F7882)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fun Facts',
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              text,
                              style: AppTextStyles.body.copyWith(
                                height: 1.9,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // soft clouds spill over the card edges, so they sit outside the clip
            Positioned(
              right: -w * 0.05,
              top: -18,
              child: IgnorePointer(
                child: Image.asset(AppAssets.softCloud, width: w * 0.3),
              ),
            ),
            Positioned(
              left: -w * 0.02,
              bottom: -26,
              child: IgnorePointer(
                child: Image.asset(AppAssets.softCloud, width: w * 0.37),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Gently wobbling edge, like torn paper. Fixed points so it never changes.
Path _tornEdgePath(Size size) {
  final w = size.width;
  final h = size.height;
  return Path()
    ..moveTo(0, 4)
    ..quadraticBezierTo(w * 0.15, 0, w * 0.32, 3)
    ..quadraticBezierTo(w * 0.5, 7, w * 0.68, 2)
    ..quadraticBezierTo(w * 0.85, -1, w, 4)
    ..quadraticBezierTo(w - 4, h * 0.3, w - 1, h * 0.55)
    ..quadraticBezierTo(w + 2, h * 0.8, w - 2, h - 3)
    ..quadraticBezierTo(w * 0.78, h + 1, w * 0.55, h - 3)
    ..quadraticBezierTo(w * 0.3, h - 7, w * 0.12, h - 2)
    ..quadraticBezierTo(w * 0.04, h, 0, h - 5)
    ..quadraticBezierTo(3, h * 0.6, 1, h * 0.35)
    ..quadraticBezierTo(-1, h * 0.15, 0, 4)
    ..close();
}

class _TornEdgeClipper extends CustomClipper<Path> {
  const _TornEdgeClipper();

  @override
  Path getClip(Size size) => _tornEdgePath(size);

  @override
  bool shouldReclip(_TornEdgeClipper oldClipper) => false;
}

class _TornEdgeBorderPainter extends CustomPainter {
  const _TornEdgeBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _tornEdgePath(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = const Color(0xFFD9C9A0),
    );
  }

  @override
  bool shouldRepaint(_TornEdgeBorderPainter oldDelegate) => false;
}
