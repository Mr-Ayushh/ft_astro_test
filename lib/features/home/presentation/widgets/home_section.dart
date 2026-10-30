import 'package:flutter/material.dart';
import 'package:ftastro/core/index.dart';

/// Grey uppercase label with its card below, as used down the home sheet.
class HomeSection extends StatelessWidget {
  const HomeSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: AppTextStyles.sectionLabel),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
