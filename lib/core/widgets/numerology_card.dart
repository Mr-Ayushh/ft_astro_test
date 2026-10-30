import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/constants/index.dart';
import 'package:ftastro/core/theme/index.dart';

/// Card art comes from Figma (globe, pedestal, faded numbers). The texts are
/// real widgets on top so they can change with the reading. Used on home and
/// insights, insights also shows the number on the globe.
class NumerologyCard extends StatelessWidget {
  const NumerologyCard({
    super.key,
    required this.luckyNumber,
    required this.guidance,
    this.showNumber = false,
  });

  final int luckyNumber;
  final String guidance;
  final bool showNumber;

  static const _artSize = Size(349, 330);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Lucky number $luckyNumber',
      child: AspectRatio(
        aspectRatio: _artSize.width / _artSize.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final k = constraints.maxWidth / _artSize.width;

            return Stack(
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    AppAssets.numerologyCard,
                    fit: BoxFit.fill,
                  ),
                ),
                if (showNumber)
                  Positioned(
                    left: 132 * k,
                    top: 66 * k,
                    width: 86 * k,
                    height: 76 * k,
                    child: Center(
                      child: Text(
                        '$luckyNumber',
                        style: AppTextStyles.display.copyWith(
                          fontSize: 40 * k,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12 * k,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Lucky Number',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.numerologyTitle,
                    ),
                  ),
                ),
                Positioned(
                  left: 21 * k,
                  right: 21 * k,
                  top: 220 * k,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today’s guidance:',
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.numerologyHeading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guidance,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardBody.copyWith(
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.astroInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
