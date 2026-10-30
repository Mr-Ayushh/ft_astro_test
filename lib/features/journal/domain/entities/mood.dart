enum Mood {
  awful(1, 'Awful'),
  low(2, 'Low'),
  okay(3, 'Okay'),
  good(4, 'Good'),
  great(5, 'Great');

  const Mood(this.score, this.label);

  final int score;
  final String label;

  static Mood fromScore(num score) {
    final rounded = score.round().clamp(1, 5);
    return Mood.values.firstWhere((mood) => mood.score == rounded);
  }
}
