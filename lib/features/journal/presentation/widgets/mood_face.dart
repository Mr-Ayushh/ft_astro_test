import 'package:flutter/material.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';

/// Little face drawn with a painter instead of emoji, so it looks the same
/// on every platform and can be any size without blurring.
class MoodFace extends StatelessWidget {
  const MoodFace({
    super.key,
    required this.mood,
    this.size = 40,
  });

  final Mood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: mood.label,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _MoodFacePainter(mood)),
      ),
    );
  }
}

class _MoodFacePainter extends CustomPainter {
  _MoodFacePainter(this.mood);

  final Mood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;

    canvas.drawCircle(Offset(cx, s / 2), s / 2, Paint()..color = mood.color);

    final stroke = Paint()
      ..color = AppColors.moodFace
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.065
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = AppColors.moodFace;

    _drawEyes(canvas, s, cx, stroke, fill);
    _drawMouth(canvas, s, cx, stroke, fill);
  }

  void _drawEyes(Canvas canvas, double s, double cx, Paint stroke, Paint fill) {
    final eyeY = s * 0.41;
    final eyeDx = s * 0.17;

    for (final x in [cx - eyeDx, cx + eyeDx]) {
      if (mood == Mood.great) {
        // closed happy eyes
        final path = Path()
          ..moveTo(x - s * 0.07, eyeY + s * 0.02)
          ..quadraticBezierTo(
            x,
            eyeY - s * 0.07,
            x + s * 0.07,
            eyeY + s * 0.02,
          );
        canvas.drawPath(path, stroke);
      } else {
        canvas.drawCircle(Offset(x, eyeY), s * 0.055, fill);
      }
    }

    if (mood == Mood.awful) {
      canvas.drawLine(
        Offset(cx - s * 0.26, s * 0.30),
        Offset(cx - s * 0.11, s * 0.25),
        stroke,
      );
      canvas.drawLine(
        Offset(cx + s * 0.26, s * 0.30),
        Offset(cx + s * 0.11, s * 0.25),
        stroke,
      );
    }
  }

  void _drawMouth(
    Canvas canvas,
    double s,
    double cx,
    Paint stroke,
    Paint fill,
  ) {
    switch (mood) {
      case Mood.great:
        final path = Path()
          ..moveTo(cx - s * 0.19, s * 0.58)
          ..quadraticBezierTo(cx, s * 0.86, cx + s * 0.19, s * 0.58)
          ..close();
        canvas.drawPath(path, fill);
      case Mood.good:
        _curve(canvas, cx, s * 0.18, s * 0.61, s * 0.75, stroke);
      case Mood.okay:
        canvas.drawLine(
          Offset(cx - s * 0.14, s * 0.66),
          Offset(cx + s * 0.14, s * 0.66),
          stroke,
        );
      case Mood.low:
        _curve(canvas, cx, s * 0.15, s * 0.70, s * 0.62, stroke);
      case Mood.awful:
        _curve(canvas, cx, s * 0.17, s * 0.73, s * 0.58, stroke);
    }
  }

  void _curve(
    Canvas canvas,
    double cx,
    double halfWidth,
    double y,
    double controlY,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(cx - halfWidth, y)
      ..quadraticBezierTo(cx, controlY, cx + halfWidth, y);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MoodFacePainter oldDelegate) => oldDelegate.mood != mood;
}
