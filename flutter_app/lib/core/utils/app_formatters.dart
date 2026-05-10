import 'package:intl/intl.dart';

class AppFormatters {
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static String percent(double value) => '${(value * 100).toStringAsFixed(1)}%';
  static String dateTime(DateTime value) => _dateTime.format(value);
}
