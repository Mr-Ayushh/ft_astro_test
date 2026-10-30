enum InsightPeriod {
  yesterday('Yesterday'),
  today('Today'),
  tomorrow('Tomorrow'),
  week('Week'),
  month('Month'),
  year('Year');

  const InsightPeriod(this.label);

  final String label;
}
