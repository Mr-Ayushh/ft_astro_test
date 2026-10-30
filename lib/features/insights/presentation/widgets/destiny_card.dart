import 'package:flutter/material.dart';
import 'package:ftastro/core/index.dart';

/// Destiny number scene from Figma (trees, path, figure and sun). The title
/// sits on the faded bottom of the scene, like in the design.
class DestinyCard extends StatelessWidget {
  const DestinyCard({super.key, required this.number, required this.title});

  final int number;
  final String title;

  // the exported scene is 400x243 (caption area cut off)
  static const _aspect = 400 / 243;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxWidth / _aspect;

        return SizedBox(
          height: imageHeight + 56,
          child: Stack(
            children: [
              Image.asset(
                AppAssets.destinyScene,
                width: constraints.maxWidth,
                fit: BoxFit.fitWidth,
                semanticLabel: 'Destiny number $number',
              ),
              // fade the path out into the page, the text sits on top of it
              Positioned(
                left: 0,
                right: 0,
                top: imageHeight - 70,
                height: 70,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00FFFFFF), Color(0xF2FFFFFF)],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: imageHeight - 34,
                child: Column(
                  children: [
                    Text(
                      'Destiny Number $number',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.astroTealDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
