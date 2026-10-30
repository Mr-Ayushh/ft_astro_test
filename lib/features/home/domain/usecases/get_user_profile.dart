import 'package:ftastro/features/home/domain/index.dart';

class GetUserProfile {
  const GetUserProfile(this._repository);

  final HomeRepository _repository;

  Future<UserProfile> call() => _repository.getUserProfile();
}
