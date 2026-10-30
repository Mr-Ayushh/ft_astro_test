import 'package:ftastro/features/home/domain/index.dart';

class CalculateAge {
  const CalculateAge();

  AgeBreakdown call(DateTime birth, DateTime now) {
    if (!now.isAfter(birth)) return AgeBreakdown.zero;

    var years = now.year - birth.year;
    var months = now.month - birth.month;
    var days = now.day - birth.day;
    var time = _timeOfDay(now) - _timeOfDay(birth);

    // borrow from the bigger unit when a smaller one goes negative
    if (time.isNegative) {
      days -= 1;
      time += const Duration(days: 1);
    }
    if (days < 0) {
      months -= 1;
      days += DateTime(now.year, now.month, 0).day; // days in previous month
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final total = now.difference(birth);
    return AgeBreakdown(
      years: years,
      months: months,
      days: days,
      hours: time.inHours,
      minutes: time.inMinutes % 60,
      seconds: time.inSeconds % 60,
      totalHours: total.inHours,
      totalMinutes: total.inMinutes,
      totalSeconds: total.inSeconds,
    );
  }

  Duration _timeOfDay(DateTime d) =>
      Duration(hours: d.hour, minutes: d.minute, seconds: d.second);
}
