import 'package:ftastro/features/insights/data/index.dart';
import 'package:ftastro/features/insights/domain/index.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  const InsightsRepositoryImpl(this._localDataSource);

  final InsightsLocalDataSource _localDataSource;

  @override
  Future<BirthChart> getBirthChart() async {
    final json = await _localDataSource.getBirthChart();
    return BirthChart(
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      sunSign: json['sun_sign'] as String,
      moonSign: json['moon_sign'] as String,
    );
  }

  @override
  Future<AstroInsight> getInsight(InsightPeriod period) async {
    final json = await _localDataSource.getInsight(period.name);
    return AstroInsight(
      period: period,
      focusArea: json['focus_area'] as String,
      horoscope: json['horoscope'] as String,
      direction: json['direction'] as String,
      luckyColourName: json['colour_name'] as String,
      luckyColour: json['colour'] as int,
      funFact: json['fun_fact'] as String,
      luckyNumber: json['lucky_number'] as int,
      guidance: json['guidance'] as String,
      destinyNumber: json['destiny_number'] as int,
      destinyTitle: json['destiny_title'] as String,
    );
  }
}
