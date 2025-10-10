import 'package:intl/intl.dart';

enum DateFormatPattern {
  ddMMyyyy('dd/MM/yyyy', 'DD/MM/YYYY'),
  mmDDyyyy('MM/dd/yyyy', 'MM/DD/YYYY'),
  yyyyMMdd('yyyy-MM-dd', 'YYYY-MM-DD');

  final String pattern;
  final String displayName;

  const DateFormatPattern(this.pattern, this.displayName);

  static DateFormatPattern fromString(String? value) {
    switch (value) {
      case 'dd/MM/yyyy':
        return DateFormatPattern.ddMMyyyy;
      case 'MM/dd/yyyy':
        return DateFormatPattern.mmDDyyyy;
      case 'yyyy-MM-dd':
        return DateFormatPattern.yyyyMMdd;
      default:
        return DateFormatPattern.ddMMyyyy; // Default format
    }
  }
}

class DateFormatHelper {
  static String formatDate(DateTime date, DateFormatPattern format) {
    return DateFormat(format.pattern).format(date);
  }

  static String formatDateString(DateTime date, String? formatPattern) {
    final format = DateFormatPattern.fromString(formatPattern);
    return formatDate(date, format);
  }

  static List<DateFormatPattern> get allFormats => DateFormatPattern.values;
}
