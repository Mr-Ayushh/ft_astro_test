import 'package:flutter/widgets.dart';
import 'package:ftastro/core/theme/index.dart';

class Responsive {
  Responsive._();

  /// Horizontal padding that keeps content centred at [AppSizes.maxContentWidth]
  /// on wide screens, and falls back to the normal page padding on phones.
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final extra = (width - AppSizes.maxContentWidth) / 2;
    return extra > AppSpacing.page ? extra : AppSpacing.page;
  }

  /// Bottom padding for scrollables inside the shell. The shell scaffold uses
  /// extendBody, so padding.bottom already includes the floating nav bar.
  static double scrollBottomPadding(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + AppSpacing.xxl;
}
