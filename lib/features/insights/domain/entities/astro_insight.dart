import 'package:equatable/equatable.dart';
import 'package:ftastro/features/insights/domain/index.dart';

class AstroInsight extends Equatable {
  const AstroInsight({
    required this.period,
    required this.focusArea,
    required this.horoscope,
    required this.direction,
    required this.luckyColourName,
    required this.luckyColour,
    required this.funFact,
    required this.luckyNumber,
    required this.guidance,
    required this.destinyNumber,
    required this.destinyTitle,
  });

  final InsightPeriod period;
  final String focusArea;
  final String horoscope;
  final String direction;
  final String luckyColourName;

  /// ARGB value, the domain layer doesn't know about Flutter's Color.
  final int luckyColour;
  final String funFact;
  final int luckyNumber;
  final String guidance;
  final int destinyNumber;
  final String destinyTitle;

  @override
  List<Object?> get props =>
      [period, focusArea, horoscope, direction, luckyNumber];
}
