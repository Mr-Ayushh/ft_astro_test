import 'package:ftastro/features/home/domain/index.dart';

class GetGoals {
  const GetGoals(this._repository);

  final HomeRepository _repository;

  Future<List<Goal>> call() => _repository.getGoals();
}
