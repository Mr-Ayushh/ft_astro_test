import 'package:ftastro/features/home/domain/index.dart';

abstract class HomeRepository {
  Future<UserProfile> getUserProfile();

  Future<DailyHoroscope> getDailyHoroscope(DateTime date);

  Future<NumerologyReading> getNumerology(DateTime date);

  Future<List<Goal>> getGoals();
}
