import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/home/domain/index.dart';
import 'package:intl/intl.dart';

class HoroscopeCard extends StatelessWidget {
  const HoroscopeCard({
    super.key,
    required this.horoscope,
    required this.onReadMore,
  });

  final DailyHoroscope horoscope;
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    // the coin sticks out above the card, so the card itself does the clipping
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 190),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              children: [
                // gradient, light glow and stars exported from Figma
                Positioned.fill(
                  child:
                      Image.asset(AppAssets.horoscopeCardBg, fit: BoxFit.fill),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(21, 22, 21, 18),
                  child: _Content(horoscope: horoscope, onReadMore: onReadMore),
                ),
              ],
            ),
          ),
        ),
        // coin position from the Figma layer ("sign", 97x79)
        Positioned(
          top: -27,
          right: 4,
          child: Image.asset(AppAssets.geminiCoin, width: 97),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.horoscope, required this.onReadMore});

  final DailyHoroscope horoscope;
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          horoscope.signName,
          style: AppTextStyles.cardTitle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('d MMMM yyyy').format(horoscope.date),
          style: AppTextStyles.body.copyWith(color: AppColors.horoscopeDate),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.only(right: 60),
          child: Text(
            horoscope.message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onReadMore,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Read more',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.readMore,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    AppAssets.icChevronRight,
                    height: 10,
                    colorFilter: const ColorFilter.mode(
                      AppColors.readMore,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
