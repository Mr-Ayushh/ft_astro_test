import 'package:ftastro/features/home/domain/index.dart';

class GetNumerology {
  const GetNumerology(this._repository);

  final HomeRepository _repository;

  Future<NumerologyReading> call(DateTime date) =>
      _repository.getNumerology(date);
}
