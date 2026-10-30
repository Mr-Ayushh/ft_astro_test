import 'package:equatable/equatable.dart';

class NumerologyReading extends Equatable {
  const NumerologyReading({required this.luckyNumber, required this.guidance});

  final int luckyNumber;
  final String guidance;

  @override
  List<Object?> get props => [luckyNumber, guidance];
}
