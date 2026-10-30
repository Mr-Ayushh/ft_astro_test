import 'package:equatable/equatable.dart';

class DailyHoroscope extends Equatable {
  const DailyHoroscope({
    required this.signName,
    required this.date,
    required this.message,
  });

  final String signName;
  final DateTime date;
  final String message;

  @override
  List<Object?> get props => [signName, date, message];
}
