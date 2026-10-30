import 'package:flutter/material.dart';
import 'package:ftastro/core/index.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
          child: Text(
            'This screen wasn’t included in the Figma design, so it’s left '
            'as a placeholder.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontSize: 15),
          ),
        ),
      ),
    );
  }
}
