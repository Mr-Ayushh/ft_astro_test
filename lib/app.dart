import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/home/data/index.dart';
import 'package:ftastro/features/home/domain/index.dart';
import 'package:ftastro/features/insights/data/index.dart';
import 'package:ftastro/features/insights/domain/index.dart';
import 'package:ftastro/features/journal/data/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';
import 'package:ftastro/features/journal/presentation/index.dart';
import 'package:ftastro/features/splash/presentation/index.dart';

class FTastroApp extends StatelessWidget {
  const FTastroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<JournalRepository>(
          create: (_) => JournalRepositoryImpl(JournalLocalDataSourceImpl()),
        ),
        RepositoryProvider<InsightsRepository>(
          create: (_) =>
              const InsightsRepositoryImpl(InsightsLocalDataSourceImpl()),
        ),
        RepositoryProvider<HomeRepository>(
          create: (_) => const HomeRepositoryImpl(HomeLocalDataSourceImpl()),
        ),
      ],
      // JournalBloc lives above MaterialApp because the detail and editor
      // routes need it too, not only the journal tab.
      child: BlocProvider(
        create: (context) {
          final repository = context.read<JournalRepository>();
          return JournalBloc(
            watchEntries: WatchJournalEntries(repository),
            deleteEntry: DeleteJournalEntry(repository),
            saveEntry: SaveJournalEntry(repository),
          )..add(const JournalSubscriptionRequested());
        },
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: child!,
          ),
          home: const SplashPage(),
        ),
      ),
    );
  }
}
