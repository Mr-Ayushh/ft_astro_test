import 'package:ftastro/features/insights/domain/index.dart';

abstract class InsightsRepository {
  Future<BirthChart> getBirthChart();

  Future<AstroInsight> getInsight(InsightPeriod period);
}
