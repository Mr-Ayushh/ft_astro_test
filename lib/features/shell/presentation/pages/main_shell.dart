import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/features/goals/presentation/index.dart';
import 'package:ftastro/features/home/domain/index.dart';
import 'package:ftastro/features/home/presentation/index.dart';
import 'package:ftastro/features/insights/domain/index.dart';
import 'package:ftastro/features/insights/presentation/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';
import 'package:ftastro/features/shell/presentation/index.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final homeRepository = context.read<HomeRepository>();
    final insightsRepository = context.read<InsightsRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) => HomeCubit(
            getUserProfile: GetUserProfile(homeRepository),
            getDailyHoroscope: GetDailyHoroscope(homeRepository),
            getNumerology: GetNumerology(homeRepository),
            getGoals: GetGoals(homeRepository),
          )..load(),
        ),
        BlocProvider(
          create: (_) => InsightsCubit(
            getBirthChart: GetBirthChart(insightsRepository),
            getAstroInsight: GetAstroInsight(insightsRepository),
          )..load(),
        ),
      ],
      child: const _ShellView(),
    );
  }
}

class _ShellView extends StatelessWidget {
  const _ShellView();

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationCubit>();

    return BlocBuilder<NavigationCubit, AppTab>(
      builder: (context, tab) {
        // Android back goes to Home first instead of closing the app
        return PopScope(
          canPop: tab == AppTab.home,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) navigation.selectTab(AppTab.home);
          },
          child: Scaffold(
            extendBody: true,
            body: IndexedStack(
              index: tab.index,
              // hidden tabs stay built (scroll position is kept) but their
              // animations pause, e.g. the insights wheel when not visible
              children: [
                for (final (i, page) in [
                  HomePage(
                    onCreateGoal: () => navigation.selectTab(AppTab.goals),
                    onReadHoroscope: () =>
                        navigation.selectTab(AppTab.insights),
                    onOpenJournal: () => navigation.selectTab(AppTab.journal),
                  ),
                  // home sets light status bar icons over its dark header,
                  // the other tabs need dark ones back
                  const AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle.dark,
                    child: GoalsPage(),
                  ),
                  const AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle.dark,
                    child: JournalPage(),
                  ),
                  const AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle.dark,
                    child: InsightsPage(),
                  ),
                ].indexed)
                  TickerMode(enabled: i == tab.index, child: page),
              ],
            ),
            bottomNavigationBar: AppBottomNavBar(
              current: tab,
              onSelected: navigation.selectTab,
            ),
          ),
        );
      },
    );
  }
}
