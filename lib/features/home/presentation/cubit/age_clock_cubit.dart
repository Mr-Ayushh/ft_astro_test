import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ftastro/features/home/domain/index.dart';

/// Recalculates the user's age every second for the home dial.
class AgeClockCubit extends Cubit<AgeBreakdown> {
  AgeClockCubit({
    required DateTime birthDate,
    CalculateAge calculateAge = const CalculateAge(),
  })  : _birthDate = birthDate,
        _calculateAge = calculateAge,
        super(calculateAge(birthDate, DateTime.now()));

  final DateTime _birthDate;
  final CalculateAge _calculateAge;

  StreamSubscription<void>? _subscription;

  void start() {
    _subscription ??= Stream<void>.periodic(const Duration(seconds: 1)).listen(
      (_) => emit(_calculateAge(_birthDate, DateTime.now())),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
