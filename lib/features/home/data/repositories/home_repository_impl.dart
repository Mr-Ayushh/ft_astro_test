import 'package:ftastro/features/home/data/index.dart';
import 'package:ftastro/features/home/domain/index.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._localDataSource);

  final HomeLocalDataSource _localDataSource;

  @override
  Future<UserProfile> getUserProfile() async {
    final json = await _localDataSource.getUserProfile();
    final sign = json['sign'] as Map<String, dynamic>;
    return UserProfile(
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      sign: ZodiacSign(
        name: sign['name'] as String,
        element: sign['element'] as String,
        modality: sign['modality'] as String,
        rulingPlanet: sign['ruling_planet'] as String,
      ),
    );
  }

  @override
  Future<DailyHoroscope> getDailyHoroscope(DateTime date) async {
    final json = await _localDataSource.getDailyHoroscope(date);
    return DailyHoroscope(
      signName: json['sign'] as String,
      date: DateTime.parse(json['date'] as String),
      message: json['message'] as String,
    );
  }

  @override
  Future<NumerologyReading> getNumerology(DateTime date) async {
    final json = await _localDataSource.getNumerology(date);
    return NumerologyReading(
      luckyNumber: json['lucky_number'] as int,
      guidance: json['guidance'] as String,
    );
  }

  @override
  Future<List<Goal>> getGoals() async {
    final rows = await _localDataSource.getGoals();
    return rows
        .map(
          (row) => Goal(id: row['id'] as String, title: row['title'] as String),
        )
        .toList();
  }
}
