/// A handful of entries in the style of the Figma journal screen. Dates are
/// relative to [now] so the current month always has the three entries from
/// the design, with a few older ones to browse with the month selector.
class JournalMockData {
  JournalMockData._();

  static List<Map<String, dynamic>> generate({DateTime? now}) {
    final today = now ?? DateTime.now();
    final rows = <Map<String, dynamic>>[];

    // monthsAgo = 0 keeps the entry in the current month, even early on
    void add(
      int monthsAgo,
      int daysAgo,
      String title,
      String body, {
      int mood = 4,
      List<String> tags = const [],
    }) {
      final day = monthsAgo == 0
          ? (today.day - daysAgo).clamp(1, today.day)
          : 28 - daysAgo;
      final date = DateTime(today.year, today.month - monthsAgo, day, 20, 20);
      rows.add({
        'id': 'seed-${rows.length}',
        'title': title,
        'body': body,
        'mood': mood,
        'created_at': date.toIso8601String(),
        'tags': tags,
      });
    }

    // same texts as the Figma screen
    add(
      0,
      1,
      'A Day To Remember',
      'Today felt like a good day to slow down. I finally took time for '
          'something I had been putting off.',
      mood: 5,
      tags: ['selfCare'],
    );
    add(
      0,
      3,
      'A Thought To Keep',
      'Embracing the idea that I can trust my own pace and enjoy the journey.',
      tags: ['reading'],
    );
    add(
      0,
      4,
      'Something I Realized',
      'Small steps can still move me closer to where I want to be.',
      tags: ['study'],
    );

    return rows;
  }
}
