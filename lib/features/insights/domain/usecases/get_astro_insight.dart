import 'package:ftastro/features/insights/domain/index.dart';

class GetAstroInsight {
  const GetAstroInsight(this._repository);

  final InsightsRepository _repository;

  Future<AstroInsight> call(InsightPeriod period) =>
      _repository.getInsight(period);
}
