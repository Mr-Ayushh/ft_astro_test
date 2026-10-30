import 'package:intl/intl.dart';

extension DateX on DateTime {
  String get timeLabel => DateFormat('h:mm a').format(this);

  String get fullDateLabel => DateFormat('EEEE, d MMMM').format(this);
}
