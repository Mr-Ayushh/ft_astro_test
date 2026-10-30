import 'package:equatable/equatable.dart';

class ZodiacSign extends Equatable {
  const ZodiacSign({
    required this.name,
    required this.element,
    required this.modality,
    required this.rulingPlanet,
  });

  final String name;
  final String element;
  final String modality;
  final String rulingPlanet;

  @override
  List<Object?> get props => [name, element, modality, rulingPlanet];
}
