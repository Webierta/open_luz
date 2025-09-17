import 'package:intl/intl.dart' show DateFormat;

class FechaUtil {
  static String dateToString({
    required DateTime date,
    String formato = 'd/MM/yyyy',
  }) {
    return DateFormat(formato, 'es').format(date);
  }

  static DateTime dateToDateHms(DateTime date) {
    return DateTime(date.year, date.month, date.day, 2, 0, 0, 0, 0);
  }

  static DateTime dateToDate000(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0, 0);
  }

  static DateTime stringToDate(String fecha) {
    return DateFormat('d/M/yyyy').parse(fecha);
  }

  static DateTime stringToDateHms(String fecha) {
    DateTime date = DateFormat('d/M/yyyy').parse(fecha);
    return dateToDateHms(date);
    //return DateFormat('d/M/yyyy').parse(fecha);
  }

  static bool checkHorarioVerano(String fecha) {
    if (fecha == '2022-03-27' ||
        fecha == '2023-03-26' ||
        fecha == '2024-03-31' ||
        fecha == '2025-03-30' ||
        fecha == '2026-03-29' ||
        fecha == '2027-03-28') {
      // 2028-03-26
      return true;
    }
    return false;
  }
}
