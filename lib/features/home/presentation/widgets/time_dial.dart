import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/home/domain/index.dart';

class TimeDial extends StatefulWidget {
  const TimeDial({
    super.key,
    required this.age,
    required this.center,
    this.scale = 1,
  });

  final AgeBreakdown age;
  final Offset center;
  final double scale;

  @override
  State<TimeDial> createState() => _TimeDialState();
}

class _TimeDialState extends State<TimeDial>
    with SingleTickerProviderStateMixin {
  static const _entranceDuration = Duration(milliseconds: 1400);
  static const _tickDuration = Duration(milliseconds: 450);

  // how many steps back each ring starts from for the entrance sweep
  static const _entranceSteps = 6.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _entranceDuration,
  );
  late final Animation<double> _progress =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  late List<double> _to = _positions(widget.age);
  late List<double> _from = [for (final v in _to) v + _entranceSteps];
  bool _entering = true;

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      _entering = false;
      _controller.duration = _tickDuration;
    });
  }

  static List<double> _positions(AgeBreakdown age) => [
        age.years,
        age.months,
        age.days,
        age.totalHours,
        age.totalMinutes,
        age.totalSeconds,
      ].map((v) => v.toDouble()).toList();

  List<double> _current() => [
        for (var i = 0; i < _to.length; i++)
          lerpDouble(_from[i], _to[i], _progress.value)!,
      ];

  @override
  void didUpdateWidget(TimeDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.age == widget.age) return;

    if (_entering) {
      // let the sweep finish, it just lands on the newer value
      _to = _positions(widget.age);
      return;
    }

    final current = _current();
    _to = _positions(widget.age);
    // after a long pause (app in background) jump instead of spinning
    _from = [
      for (var i = 0; i < _to.length; i++)
        (_to[i] - current[i]).abs() > 30 ? _to[i] : current[i],
    ];
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // rings + labels never move, so they sit on their own cached layer and only the numbers repaint while the rings turn
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _DialPainter(
              layer: _DialLayer.rings,
              positions: _current,
              center: widget.center,
              scale: widget.scale,
            ),
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: _DialPainter(
              layer: _DialLayer.numbers,
              positions: _current,
              center: widget.center,
              scale: widget.scale,
              repaint: _controller,
            ),
          ),
        ),
      ],
    );
  }
}

class _Ring {
  const _Ring({
    required this.label,
    required this.outerRadius,
    required this.numberRadius,
    required this.labelRadius,
    required this.color,
    required this.numberColor,
    required this.fontSize,
    required this.activeFontSize,
    this.cycle,
  });

  final String label;
  final double outerRadius;
  final double numberRadius;
  final double labelRadius;
  final Color color;
  final Color numberColor;
  final double fontSize;
  final double activeFontSize;

  final int? cycle;

  String format(int value) => cycle == null ? '$value' : '${value % cycle!}';
}

const _rings = [
  _Ring(
    label: 'Yrs',
    outerRadius: 325,
    numberRadius: 305,
    labelRadius: 298,
    color: AppColors.dialYears,
    numberColor: Color(0xFFDCD5C1),
    fontSize: 25,
    activeFontSize: 31,
  ),
  _Ring(
    label: 'Mm',
    outerRadius: 274,
    numberRadius: 258,
    labelRadius: 247,
    color: AppColors.dialMonths,
    numberColor: Color(0xFFC9BC93),
    fontSize: 21,
    activeFontSize: 27,
    cycle: 12,
  ),
  _Ring(
    label: 'Days',
    outerRadius: 219,
    numberRadius: 209,
    labelRadius: 201,
    color: AppColors.dialDays,
    numberColor: Color(0xFFB0A17A),
    fontSize: 18,
    activeFontSize: 24,
    cycle: 31,
  ),
  _Ring(
    label: 'Hrs',
    outerRadius: 181,
    numberRadius: 166,
    labelRadius: 158,
    color: AppColors.dialHours,
    numberColor: Color(0xFF3E7883),
    fontSize: 16,
    activeFontSize: 22,
    cycle: 24,
  ),
  _Ring(
    label: 'Mins',
    outerRadius: 136,
    numberRadius: 121,
    labelRadius: 112,
    color: AppColors.dialMinutes,
    numberColor: Color(0xFF5B95A1),
    fontSize: 13.5,
    activeFontSize: 19,
    cycle: 60,
  ),
  _Ring(
    label: 'Sec',
    outerRadius: 89,
    numberRadius: 81,
    labelRadius: 64,
    color: AppColors.dialSeconds,
    numberColor: Color(0xFF7EAEB9),
    fontSize: 10.5,
    activeFontSize: 15,
    cycle: 60,
  ),
];

enum _DialLayer { rings, numbers }

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.layer,
    required this.positions,
    required this.center,
    required this.scale,
    super.repaint,
  });

  final _DialLayer layer;

  final List<double> Function() positions;
  final Offset center;
  final double scale;

  static const _step = 12 * math.pi / 180;
  static const _handAngle = 228 * math.pi / 180;

  // the seconds ring repaints every second, so don't lay out text each time
  static final _textCache = <String, TextPainter>{};

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    if (layer == _DialLayer.numbers) {
      final values = positions();
      for (var i = 0; i < _rings.length; i++) {
        _paintNumbers(canvas, _rings[i], values[i]);
      }
      return;
    }

    // numbers sit inside their own band, so all fills can go first
    final shadow = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    for (final ring in _rings) {
      final radius = ring.outerRadius * scale;
      canvas.drawCircle(center, radius, shadow);
      canvas.drawCircle(center, radius, Paint()..color = ring.color);
      _paintLabel(canvas, ring);
    }
  }

  void _paintNumbers(Canvas canvas, _Ring ring, double position) {
    final base = position.floor();
    final radius = ring.numberRadius * scale;

    for (var k = base - 4; k <= base + 6; k++) {
      final angle = _handAngle + (k - position) * _step;
      // keep numbers above the label row, the rest is off screen anyway
      if (angle < math.pi * 1.04 || angle > math.pi * 1.62) continue;

      final active = (k - position).abs() < 0.5;
      final text = _text(
        ring.format(k),
        fontSize: active ? ring.activeFontSize : ring.fontSize,
        color: active ? AppColors.dialActive : ring.numberColor,
        weight: active ? FontWeight.w800 : FontWeight.w600,
      );

      canvas
        ..save()
        ..translate(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        )
        // digits face outwards, like the design
        ..rotate(angle + math.pi / 2);
      text.paint(canvas, Offset(-text.width / 2, -text.height / 2));
      canvas.restore();
    }
  }

  void _paintLabel(Canvas canvas, _Ring ring) {
    final text = _text(
      ring.label,
      fontSize: 16,
      color: AppColors.dialActive,
      weight: FontWeight.w700,
    );
    final x = center.dx - ring.labelRadius * scale;
    final y = center.dy - 5 * scale;
    text.paint(canvas, Offset(x - text.width / 2, y - text.height / 2));
  }

  TextPainter _text(
    String value, {
    required double fontSize,
    required Color color,
    required FontWeight weight,
  }) {
    final size = fontSize * scale;
    final key = '$value|$size|${color.value}|${weight.index}';
    return _textCache.putIfAbsent(
      key,
      () => TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: size,
            height: 1,
            fontWeight: weight,
            letterSpacing: -0.5,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) =>
      oldDelegate.layer != layer ||
      oldDelegate.center != center ||
      oldDelegate.scale != scale;
}
