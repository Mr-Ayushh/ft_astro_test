abstract class HomeLocalDataSource {
  Future<Map<String, dynamic>> getUserProfile();

  Future<Map<String, dynamic>> getDailyHoroscope(DateTime date);

  Future<Map<String, dynamic>> getNumerology(DateTime date);

  Future<List<Map<String, dynamic>>> getGoals();
}

/// Mock data, shaped like an API response would be.
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  const HomeLocalDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    return {
      'name': 'Team',
      'birth_date': '2017-09-01T00:00:00',
      'sign': {
        'name': 'Gemini',
        'element': 'Air',
        'modality': 'Mutable',
        'ruling_planet': 'Mercury',
      },
    };
  }

  @override
  Future<Map<String, dynamic>> getDailyHoroscope(DateTime date) async {
    return {
      'sign': 'Gemini',
      'date': date.toIso8601String(),
      'message': 'Your natural curiosity is your strength today. Stay open to '
          'new ideas, but give yourself time to focus before making decisions.',
    };
  }

  @override
  Future<Map<String, dynamic>> getNumerology(DateTime date) async {
    return {
      'lucky_number': 5,
      'guidance': 'Stay open to unexpected opportunities. Trust your '
          'instincts, explore something new, and avoid overthinking your '
          'next move.',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getGoals() async => const [];
}
