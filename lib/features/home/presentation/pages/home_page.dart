import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/home/presentation/index.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onCreateGoal,
    required this.onReadHoroscope,
    required this.onOpenJournal,
  });

  final VoidCallback onCreateGoal;
  final VoidCallback onReadHoroscope;
  final VoidCallback onOpenJournal;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.failure) {
          return const Center(
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Something went wrong',
              message: 'We couldn\'t load your home screen.',
            ),
          );
        }
        if (state.isLoading) {
          return const ColoredBox(color: AppColors.headerTop);
        }

        return BlocProvider(
          create: (_) =>
              AgeClockCubit(birthDate: state.user!.birthDate)..start(),
          child: _HomeView(
            state: state,
            onCreateGoal: onCreateGoal,
            onReadHoroscope: onReadHoroscope,
            onOpenJournal: onOpenJournal,
          ),
        );
      },
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({
    required this.state,
    required this.onCreateGoal,
    required this.onReadHoroscope,
    required this.onOpenJournal,
  });

  final HomeState state;
  final VoidCallback onCreateGoal;
  final VoidCallback onReadHoroscope;
  final VoidCallback onOpenJournal;

  static const _step = Duration(milliseconds: 80);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // 27pt in the design, centred column on tablets
    final horizontal = math.max(27.0, (width - AppSizes.maxContentWidth) / 2);

    return SingleChildScrollView(
      // clamping so pulling down doesn't reveal white above the dark header
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          HomeHeader(
            user: state.user!,
            onProfileTap: () => showAppSnackBar(
              context,
              "Feature isn't available at the movement, Coming Soon...",
            ),
            onNotificationsTap: () =>
                showAppSnackBar(context, 'You\'re all caught up'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: HomeHeader.visibleHeight),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  38,
                  horizontal,
                  Responsive.scrollBottomPadding(context),
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl - 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeSlideIn(
                      child: HomeSection(
                        title: 'Goal’s',
                        child: GoalsEmptyCard(onCreateGoal: onCreateGoal),
                      ),
                    ),
                    if (state.horoscope != null)
                      FadeSlideIn(
                        delay: _step,
                        child: HomeSection(
                          title: 'Today’s Horoscope',
                          child: HoroscopeCard(
                            horoscope: state.horoscope!,
                            onReadMore: onReadHoroscope,
                          ),
                        ),
                      ),
                    if (state.numerology != null)
                      FadeSlideIn(
                        delay: _step * 2,
                        child: HomeSection(
                          title: 'Today’s Numerology',
                          child: NumerologyCard(
                            luckyNumber: state.numerology!.luckyNumber,
                            guidance: state.numerology!.guidance,
                          ),
                        ),
                      ),
                    FadeSlideIn(
                      delay: _step * 3,
                      child: HomeSection(
                        title: 'Your Journal',
                        child: JournalCoverCard(onOpened: onOpenJournal),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
