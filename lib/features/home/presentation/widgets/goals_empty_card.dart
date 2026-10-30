import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';

class GoalsEmptyCard extends StatelessWidget {
  const GoalsEmptyCard({super.key, required this.onCreateGoal});

  final VoidCallback onCreateGoal;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: 176,
        child: Stack(
          children: [
            // card background and mountains, exported from Figma
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.goalCard,
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
              ),
            ),
            const Positioned(
              left: 21,
              top: 20,
              child: SizedBox(
                width: 205,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No Goals Yet', style: AppTextStyles.cardTitle),
                    SizedBox(height: 6),
                    Text(
                      'Let your intentions guide your journey.',
                      maxLines: 2,
                      style: AppTextStyles.cardBody,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 36,
              right: 36,
              bottom: 15,
              child: Center(child: _CreateGoalButton(onTap: onCreateGoal)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateGoalButton extends StatelessWidget {
  const _CreateGoalButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const shape = StadiumBorder(
      side: BorderSide(color: Colors.white, width: 1.5),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 271, minHeight: 35),
      child: Material(
        color: Colors.transparent,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Create Your Goal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
