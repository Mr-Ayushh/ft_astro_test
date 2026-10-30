part of 'insights_cubit.dart';

enum InsightsStatus { initial, loading, success, failure }

final class InsightsState extends Equatable {
  const InsightsState({
    this.status = InsightsStatus.initial,
    this.period = InsightPeriod.today,
    this.chart,
    this.insight,
  });

  final InsightsStatus status;
  final InsightPeriod period;
  final BirthChart? chart;
  final AstroInsight? insight;

  InsightsState copyWith({
    InsightsStatus? status,
    InsightPeriod? period,
    BirthChart? chart,
    AstroInsight? insight,
  }) {
    return InsightsState(
      status: status ?? this.status,
      period: period ?? this.period,
      chart: chart ?? this.chart,
      insight: insight ?? this.insight,
    );
  }

  @override
  List<Object?> get props => [status, period, chart, insight];
}
