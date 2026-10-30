import 'package:equatable/equatable.dart';

class Goal extends Equatable {
  const Goal({required this.id, required this.title});

  final String id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}
