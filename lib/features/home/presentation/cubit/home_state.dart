part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

final class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.user,
    this.horoscope,
    this.numerology,
    this.goals = const [],
  });

  final HomeStatus status;
  final UserProfile? user;
  final DailyHoroscope? horoscope;
  final NumerologyReading? numerology;
  final List<Goal> goals;

  bool get isLoading =>
      status == HomeStatus.initial || status == HomeStatus.loading;

  HomeState copyWith({
    HomeStatus? status,
    UserProfile? user,
    DailyHoroscope? horoscope,
    NumerologyReading? numerology,
    List<Goal>? goals,
  }) {
    return HomeState(
      status: status ?? this.status,
      user: user ?? this.user,
      horoscope: horoscope ?? this.horoscope,
      numerology: numerology ?? this.numerology,
      goals: goals ?? this.goals,
    );
  }

  @override
  List<Object?> get props => [status, user, horoscope, numerology, goals];
}
