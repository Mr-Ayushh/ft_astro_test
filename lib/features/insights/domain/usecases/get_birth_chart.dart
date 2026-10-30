import 'package:ftastro/features/insights/domain/index.dart';

class GetBirthChart {
  const GetBirthChart(this._repository);

  final InsightsRepository _repository;

  Future<BirthChart> call() => _repository.getBirthChart();
}
