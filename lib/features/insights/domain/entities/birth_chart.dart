import 'package:equatable/equatable.dart';

class BirthChart extends Equatable {
  const BirthChart({
    required this.name,
    required this.birthDate,
    required this.sunSign,
    required this.moonSign,
  });

  final String name;
  final DateTime birthDate;
  final String sunSign;
  final String moonSign;

  @override
  List<Object?> get props => [name, birthDate, sunSign, moonSign];
}
