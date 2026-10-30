import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/home/domain/index.dart';
import 'package:ftastro/features/home/presentation/index.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.user,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  final UserProfile user;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  /// Where the white sheet starts, and how far the header runs under it.
  static const double visibleHeight = 405;
  static const double sheetOverlap = 24;

  // faint zodiac signs behind the greeting: asset, left, top, width
  static const _glyphs = [
    (AppAssets.glyphLibra, 135.0, 62.0, 30.0),
    (AppAssets.glyphVirgo, 202.0, 57.0, 43.0),
    (AppAssets.glyphGemini, 94.0, 145.0, 26.0),
    (AppAssets.glyphTaurus, 26.0, 160.0, 29.0),
    (AppAssets.glyphLeo, 52.0, 215.0, 30.0),
    (AppAssets.glyphSagittarius, 27.0, 272.0, 25.0),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final scale = (width / 402).clamp(0.82, 1.12);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SizedBox(
        height: visibleHeight + sheetOverlap,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.headerTop,
                      AppColors.headerMid,
                      AppColors.headerBottom,
                    ],
                  ),
                ),
              ),
            ),
            for (final (asset, left, top, size) in _glyphs)
              Positioned(
                left: left,
                top: top,
                child: Opacity(
                  opacity: 0.1,
                  child: SvgPicture.asset(asset, width: size),
                ),
              ),
            Positioned.fill(
              child: BlocBuilder<AgeClockCubit, AgeBreakdown>(
                builder: (context, age) => TimeDial(
                  age: age,
                  center: Offset(width + 3, 396),
                  scale: scale,
                ),
              ),
            ),
            Positioned(
              left: 27,
              right: 150,
              top: topInset + 11,
              child: _Greeting(user: user),
            ),
            Positioned(
              right: 25,
              top: topInset + 10,
              child: Row(
                children: [
                  _CircleButton(
                    icon: AppAssets.icProfile,
                    tooltip: 'Profile',
                    onTap: onProfileTap,
                  ),
                  const SizedBox(width: 14),
                  _CircleButton(
                    icon: AppAssets.icBell,
                    tooltip: 'Notifications',
                    onTap: onNotificationsTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final UserProfile user;

  String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good Morning,';
    if (now.hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final sign = user.sign;
    const white = TextStyle(color: Colors.white);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(DateTime.now()),
          style: AppTextStyles.body.merge(white),
        ),
        const SizedBox(height: 2),
        Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h1.copyWith(fontSize: 26, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          '${sign.element}  •  ${sign.modality}  •  ${sign.rulingPlanet}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(
            color: AppColors.zodiacTraits,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final String icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.headerButtonBorder),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 46,
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.astroTealDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
