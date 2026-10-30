import 'package:ftastro/features/home/domain/index.dart';

class GetDailyHoroscope {
  const GetDailyHoroscope(this._repository);

  final HomeRepository _repository;

  Future<DailyHoroscope> call(DateTime date) =>
      _repository.getDailyHoroscope(date);
}
