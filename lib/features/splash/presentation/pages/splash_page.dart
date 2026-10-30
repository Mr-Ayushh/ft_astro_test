import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/shell/presentation/index.dart';

/// Shown for [AppConstants.splashDuration], then fades into the main shell.
/// The journal data starts loading in the background meanwhile, so home is
/// usually ready by the time this closes.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  // zodiac wheel behind the logo turns slowly the whole time
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  late final Animation<double> _decorOpacity = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
  );
  late final Animation<double> _footerOpacity = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.5, 1, curve: Curves.easeOut),
  );

  Timer? _timer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppConstants.splashDuration, _openHome);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // Defer heavy asset precaching to post-frame so the splash UI renders immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final asset in AppAssets.heavySvgs) {
        final loader = SvgAssetLoader(asset);
        svg.cache
            .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
      }
      for (final image in AppAssets.images) {
        precacheImage(AssetImage(image), context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _spin.dispose();
    super.dispose();
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: AppDurations.slow,
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // logo size in the native launch screen (android/.../splash_logo.png), the
  // flutter splash starts at this size so there's no jump between them
  static const _nativeLogoWidth = 136.0;

  @override
  Widget build(BuildContext context) {
    final logoWidth = math.min(MediaQuery.sizeOf(context).width * 0.62, 280.0);
    // the glass circle in the logo isn't centred in the svg (244x234, circle
    // centre at y=105), so the wheel and glow are moved up to match it
    final circleOffset = Offset(0, -logoWidth * (117 - 105) / 244);
    final logoScale = Tween<double>(
      begin: _nativeLogoWidth / logoWidth,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    return Scaffold(
      // same gradient as the native launch screen, so there's no jump
      backgroundColor: AppColors.splashBackground,
      body: Stack(
        children: [
          // same soft teal to cream wash as the journal and insights screens
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.journalBgTop,
                    AppColors.splashBackground,
                    AppColors.journalBgWarm,
                  ],
                ),
              ),
            ),
          ),
          // centred on the whole screen like the native splash icon
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FadeTransition(
                  opacity: _decorOpacity,
                  child: Transform.translate(
                    offset: circleOffset,
                    child: Container(
                      width: logoWidth * 1.5,
                      height: logoWidth * 1.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.navGlow.withOpacity(0.28),
                            AppColors.navGlow.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                FadeTransition(
                  opacity: _decorOpacity,
                  child: Transform.translate(
                    offset: circleOffset,
                    child: RotationTransition(
                      turns: _spin,
                      // sits inside the glass circle of the logo
                      child: Image.asset(
                        AppAssets.zodiacWheel,
                        width: logoWidth * 0.82,
                      ),
                    ),
                  ),
                ),
                ScaleTransition(
                  scale: logoScale,
                  child: Image.asset(
                    AppAssets.logo,
                    width: logoWidth,
                    semanticLabel: '${AppConstants.appName} logo',
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: FadeTransition(
                opacity: _footerOpacity,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    0,
                    AppSpacing.page,
                    AppSpacing.lg,
                  ),
                  child: _DeveloperCredit(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperCredit extends StatelessWidget {
  const _DeveloperCredit();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.caption.copyWith(
      fontSize: 11,
      color: AppColors.textSecondary,
    );

    return Semantics(
      label: 'Design & Developed with love by ${AppConstants.developerName}',
      excludeSemantics: true,
      // one rich text instead of a Row, so it wraps on very narrow screens
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            const TextSpan(text: 'Design & Developed with '),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.favorite_rounded,
                size: 12,
                color: AppColors.favourite,
              ),
            ),
            const TextSpan(text: ' by '),
            TextSpan(
              text: AppConstants.developerName,
              style: style.copyWith(
                color: AppColors.astroTealDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
