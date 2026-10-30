import 'package:equatable/equatable.dart';

/// Time since birth, split the way the home dial shows it. The totals are
/// used to animate the faster rings without jumping on roll over (59 -> 0).
class AgeBreakdown extends Equatable {
  const AgeBreakdown({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.totalHours,
    required this.totalMinutes,
    required this.totalSeconds,
  });

  static const zero = AgeBreakdown(
    years: 0,
    months: 0,
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
    totalHours: 0,
    totalMinutes: 0,
    totalSeconds: 0,
  );

  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final int totalHours;
  final int totalMinutes;
  final int totalSeconds;

  @override
  List<Object?> get props => [years, months, days, totalSeconds];
}
