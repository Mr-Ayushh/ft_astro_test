import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/features/home/domain/index.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetUserProfile getUserProfile,
    required GetDailyHoroscope getDailyHoroscope,
    required GetNumerology getNumerology,
    required GetGoals getGoals,
  })  : _getUserProfile = getUserProfile,
        _getDailyHoroscope = getDailyHoroscope,
        _getNumerology = getNumerology,
        _getGoals = getGoals,
        super(const HomeState());

  final GetUserProfile _getUserProfile;
  final GetDailyHoroscope _getDailyHoroscope;
  final GetNumerology _getNumerology;
  final GetGoals _getGoals;

  Future<void> load() async {
    emit(state.copyWith(status: HomeStatus.loading));
    final today = DateTime.now();

    try {
      final user = await _getUserProfile();
      final horoscope = await _getDailyHoroscope(today);
      final numerology = await _getNumerology(today);
      final goals = await _getGoals();

      emit(
        state.copyWith(
          status: HomeStatus.success,
          user: user,
          horoscope: horoscope,
          numerology: numerology,
          goals: goals,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }
}
