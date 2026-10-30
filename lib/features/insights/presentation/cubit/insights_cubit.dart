import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/features/insights/domain/index.dart';

part 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({
    required GetBirthChart getBirthChart,
    required GetAstroInsight getAstroInsight,
  })  : _getBirthChart = getBirthChart,
        _getAstroInsight = getAstroInsight,
        super(const InsightsState());

  final GetBirthChart _getBirthChart;
  final GetAstroInsight _getAstroInsight;

  Future<void> load() async {
    emit(state.copyWith(status: InsightsStatus.loading));
    try {
      final chart = await _getBirthChart();
      final insight = await _getAstroInsight(state.period);
      emit(
        state.copyWith(
          status: InsightsStatus.success,
          chart: chart,
          insight: insight,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: InsightsStatus.failure));
    }
  }

  Future<void> periodSelected(InsightPeriod period) async {
    if (period == state.period) return;
    // switch the tab right away, the content follows once loaded
    emit(state.copyWith(period: period));
    try {
      final insight = await _getAstroInsight(period);
      if (state.period == period) emit(state.copyWith(insight: insight));
    } catch (_) {
      emit(state.copyWith(status: InsightsStatus.failure));
    }
  }
}
