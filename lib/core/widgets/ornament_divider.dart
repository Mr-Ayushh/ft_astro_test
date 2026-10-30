import 'package:flutter/material.dart';
import 'package:ftastro/core/theme/index.dart';

/// custom stylish star lines pattern divider
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({
    super.key,
    this.width = 190,
    this.color = AppColors.astroTealDark,
    this.showLines = true,
    this.child,
  });

  final double width;
  final Color color;
  final bool showLines;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final center = child == null
        ? SparkleCluster(color: color)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(size: 5, color: color),
              const SizedBox(width: 4),
              _Dot(size: 3, color: color),
              const SizedBox(width: 8),
              // long labels shrink to fit instead of overflowing
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width - 90),
                child: FittedBox(fit: BoxFit.scaleDown, child: child),
              ),
              const SizedBox(width: 8),
              _Dot(size: 3, color: color),
              const SizedBox(width: 4),
              _Dot(size: 5, color: color),
            ],
          );

    if (!showLines) return center;

    return SizedBox(
      width: width,
      child: Row(
        children: [
          Expanded(
            child: _FadingLine(color: color, fadeFrom: Alignment.centerLeft),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: center,
          ),
          Expanded(
            child: _FadingLine(color: color, fadeFrom: Alignment.centerRight),
          ),
        ],
      ),
    );
  }
}

class SparkleCluster extends StatelessWidget {
  const SparkleCluster({super.key, this.color = AppColors.astroTealDark});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(size: 2.5, color: color.withOpacity(0.45)),
        const SizedBox(width: 5),
        _Dot(size: 4, color: color.withOpacity(0.7)),
        const SizedBox(width: 7),
        CustomPaint(
          size: const Size.square(15),
          painter: SparklePainter(color),
        ),
        const SizedBox(width: 7),
        _Dot(size: 4, color: color.withOpacity(0.7)),
        const SizedBox(width: 5),
        _Dot(size: 2.5, color: color.withOpacity(0.45)),
      ],
    );
  }
}

/// Four pointed star with curved sides.
class SparklePainter extends CustomPainter {
  const SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final k = w * 0.1; // how far the sides bow in

    final path = Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(cx + k, cy - k, w, cy)
      ..quadraticBezierTo(cx + k, cy + k, cx, h)
      ..quadraticBezierTo(cx - k, cy + k, 0, cy)
      ..quadraticBezierTo(cx - k, cy - k, cx, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) => oldDelegate.color != color;
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _FadingLine extends StatelessWidget {
  const _FadingLine({required this.color, required this.fadeFrom});

  final Color color;
  final Alignment fadeFrom;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: fadeFrom,
          end: -fadeFrom,
          colors: [color.withOpacity(0), color],
        ),
      ),
    );
  }
}
