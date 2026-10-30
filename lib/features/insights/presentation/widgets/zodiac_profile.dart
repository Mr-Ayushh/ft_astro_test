import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/insights/domain/index.dart';
import 'package:intl/intl.dart';

/// Name, birth date and the zodiac circle with sun and moon signs.
class ZodiacProfile extends StatefulWidget {
  const ZodiacProfile({super.key, required this.chart});

  final BirthChart chart;

  @override
  State<ZodiacProfile> createState() => _ZodiacProfileState();
}

class _ZodiacProfileState extends State<ZodiacProfile>
    with SingleTickerProviderStateMixin {
  // constellation wheel inside the circle turns slowly, like on the splash
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  // zodiac_ring.svg is 244x234, ring centre at (122, 105)
  static const _ringWidth = 250.0;
  static const _ringScale = _ringWidth / 244;

  // the design spells September "Sept"
  String _birthLabel(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date).replaceFirst('Sep ', 'Sept ');

  @override
  Widget build(BuildContext context) {
    const ringHeight = 234 * _ringScale;
    const circleCentre = 105 * _ringScale;
    // big faint circle around the glass ring, 312pt across in the design
    const outerRadius = 156.0;

    return Column(
      children: [
        Text(
          widget.chart.name,
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          'You  •  ${_birthLabel(widget.chart.birthDate)}',
          style: AppTextStyles.caption.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: ringHeight + 40,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              const Positioned(
                top: circleCentre - outerRadius,
                child: SizedBox.square(
                  dimension: outerRadius * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Color(0x33A9A58A)),
                      ),
                    ),
                  ),
                ),
              ),
              SvgPicture.asset(AppAssets.zodiacRing, width: _ringWidth),
              // faint constellation wheel inside the circle (Figma)
              Positioned(
                top: circleCentre - 98,
                child: RotationTransition(
                  turns: _spin,
                  child: Image.asset(AppAssets.zodiacWheel, width: 200),
                ),
              ),
              Positioned(
                top: circleCentre - 63,
                child: Image.asset(AppAssets.lion, width: 115),
              ),
              Positioned(
                left: 27,
                top: 14,
                child:
                    _SignLabel(sign: widget.chart.sunSign, caption: 'Sun sign'),
              ),
              Positioned(
                right: 27,
                top: 14,
                child: _SignLabel(
                  sign: widget.chart.moonSign,
                  caption: 'Moon sign',
                  alignEnd: true,
                ),
              ),
              Positioned(
                top: ringHeight + 6,
                child: Text(
                  widget.chart.moonSign,
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.astroInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignLabel extends StatelessWidget {
  const _SignLabel({
    required this.sign,
    required this.caption,
    this.alignEnd = false,
  });

  final String sign;
  final String caption;
  final bool alignEnd;

  // only the signs used in the design were exported
  static const _icons = {
    'Cancer': AppAssets.zodiacCancer,
    'Leo': AppAssets.zodiacLeo,
  };

  @override
  Widget build(BuildContext context) {
    final asset = _icons[sign];
    final Widget icon = asset != null
        ? SvgPicture.asset(asset, width: 26)
        : Icon(
            caption == 'Sun sign'
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_outlined,
            size: 20,
            color: AppColors.astroTealDark,
          );
    final text = Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          sign,
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w500),
        ),
        Text(
          caption,
          style: AppTextStyles.caption.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: alignEnd
          ? [text, const SizedBox(width: 6), icon]
          : [icon, const SizedBox(width: 6), text],
    );
  }
}
