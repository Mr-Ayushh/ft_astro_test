import 'package:equatable/equatable.dart';
import 'package:ftastro/features/home/domain/index.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.birthDate,
    required this.sign,
  });

  final String name;
  final DateTime birthDate;
  final ZodiacSign sign;

  @override
  List<Object?> get props => [name, birthDate, sign];
}
