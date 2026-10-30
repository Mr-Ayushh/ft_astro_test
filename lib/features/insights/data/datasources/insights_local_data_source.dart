abstract class InsightsLocalDataSource {
  Future<Map<String, dynamic>> getBirthChart();

  /// [period] is the InsightPeriod name, e.g. "today".
  Future<Map<String, dynamic>> getInsight(String period);
}

/// Mock data. Today matches the Figma frame, the other periods just change
/// enough to show the tabs working.
class InsightsLocalDataSourceImpl implements InsightsLocalDataSource {
  const InsightsLocalDataSourceImpl();

  static const _base = {
    'focus_area': 'Career',
    'horoscope': 'Give yourself time to heal and focus on your well-being '
        'today. Avoid unhealthy habits and choose nourishing foods. Stay '
        'patient, positive career opportunities are on the way while love '
        'brings warmth and connection.',
    'direction': 'North',
    'colour_name': 'Pink',
    'colour': 0xFFF06C9B,
    'fun_fact': 'Leo is ruled by the Sun ☀️, which is why it\'s traditionally '
        'associated with confidence, creativity, warmth, and a natural desire '
        'to shine.',
    'lucky_number': 5,
    'guidance': 'Stay open to unexpected opportunities. Trust your instincts, '
        'explore something new, and avoid overthinking your next move.',
    'destiny_number': 7,
    'destiny_title': 'The Seeker',
  };

  static const _overrides = <String, Map<String, dynamic>>{
    'yesterday': {
      'focus_area': 'Health',
      'horoscope': 'A busy mind needed a quiet evening. Conversations went '
          'better than expected and a small worry turned out to be nothing.',
      'direction': 'East',
      'colour_name': 'Green',
      'colour': 0xFF4CAF7A,
      'lucky_number': 3,
    },
    'tomorrow': {
      'focus_area': 'Love',
      'horoscope': 'Confidence comes easily tomorrow. Share the idea you have '
          'been sitting on, people around you are ready to listen.',
      'direction': 'South',
      'colour_name': 'Gold',
      'colour': 0xFFE0B341,
      'lucky_number': 8,
    },
    'week': {
      'focus_area': 'Family',
      'horoscope': 'A good week to get organised. Finish what is half done '
          'before starting anything new, your future self will thank you.',
      'direction': 'West',
      'colour_name': 'Blue',
      'colour': 0xFF4A90C8,
      'lucky_number': 6,
    },
    'month': {
      'focus_area': 'Finance',
      'horoscope': 'Balance is the theme this month. Make time for the people '
          'who energise you and say no to plans that drain you.',
      'direction': 'North-East',
      'colour_name': 'Lavender',
      'colour': 0xFF9C8BD9,
      'lucky_number': 2,
    },
    'year': {
      'focus_area': 'Growth',
      'horoscope': 'A year for growth and travel. Say yes to learning '
          'something new, the bigger changes follow from there.',
      'direction': 'South-East',
      'colour_name': 'Orange',
      'colour': 0xFFF29A4A,
      'lucky_number': 9,
    },
  };

  @override
  Future<Map<String, dynamic>> getBirthChart() async {
    return {
      'name': 'Furation Tech',
      'birth_date': '2022-09-06',
      'sun_sign': 'Cancer',
      'moon_sign': 'Leo',
    };
  }

  @override
  Future<Map<String, dynamic>> getInsight(String period) async {
    return {..._base, ...?_overrides[period], 'period': period};
  }
}
