import 'package:flutter/material.dart';
import 'package:ftastro/core/index.dart';
import 'package:ftastro/features/journal/domain/index.dart';

extension MoodStyle on Mood {
  Color get color => switch (this) {
        Mood.awful => AppColors.moodAwful,
        Mood.low => AppColors.moodLow,
        Mood.okay => AppColors.moodOkay,
        Mood.good => AppColors.moodGood,
        Mood.great => AppColors.moodGreat,
      };

  /// Light tint used behind faces and for chips.
  Color get softColor => Color.lerp(Colors.white, color, 0.22)!;

  /// Darker shade that stays readable as text on [softColor].
  Color get textColor => Color.lerp(color, Colors.black, 0.45)!;
}
