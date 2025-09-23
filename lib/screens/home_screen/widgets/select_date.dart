import 'package:flutter/material.dart';

class DatePicker {
  static Future<DateTime?>? selectDate(BuildContext context) async {
    final DateTime hoy = DateTime.now().toLocal();
    DateTime manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    return await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2021, 6),
      lastDate: manana,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
  }

  static Future<DateTimeRange<DateTime>?>? selectRange(
    BuildContext context,
  ) async {
    final DateTime hoy = DateTime.now().toLocal();
    return await showDateRangePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDateRange: DateTimeRange(
        start: DateTime(hoy.year, hoy.month, hoy.day - 7),
        end: DateTime.now(),
      ),
      firstDate: DateTime(2021, 6),
      lastDate: DateTime.now(),
      //initialEntryMode: DatePickerEntryMode.calendarOnly,
      fieldStartLabelText: 'Desde',
      fieldEndLabelText: 'Hasta',
      fieldStartHintText: 'dd/mm/aaaa',
      fieldEndHintText: 'dd/mm/aaaa',
      cancelText: 'CANCELAR',
      confirmText: 'ACEPTAR',
      saveText: 'ACEPTAR',
      errorFormatText: 'Formato no válido.',
      errorInvalidText: 'Fuera de rango.',
      errorInvalidRangeText: 'Período no válido.',
      /*builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: isDark ? AppColor.boxDark : AppColor.light,
            ),
          ),
          child: child ?? const Text(''),
        );
      },*/
    );
  }
}
