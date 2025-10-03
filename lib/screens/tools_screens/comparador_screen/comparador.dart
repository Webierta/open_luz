import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as httpdio;
import 'package:intl/intl.dart';

import '../../../models/tarifa.dart';
import '../../../utils/estados.dart';
import '../../../utils/file_util.dart';
import '../../../utils/horario_verano.dart';

typedef LineaCsv = ({String fecha, int hora, double consumo});

class Comparador {
  /// READ FILE CSV
  static Future<List<List>> readFile(File fileConsumos) async =>
      await FileUtil.loadCsvData(fileConsumos.path);

  /// READ HEAD CSV: KEYS AND INDEX FECHA Y CONSUMO
  static ({String keyFecha, String keyConsumo}) _getKeysHead(List head) {
    String keyFecha = '';
    String keyConsumo = '';
    for (var field in head) {
      if (field.toLowerCase().contains('fecha') ||
          field.toLowerCase().contains('data')) {
        keyFecha = field;
      }
      if (field.toLowerCase().contains('consumo') ||
          field.toLowerCase().contains('ae_kwh')) {
        keyConsumo = field;
      }
    }
    return (keyFecha: keyFecha, keyConsumo: keyConsumo);
  }

  static int? _getIndex(List encabezados, String keyHead) {
    int? index;
    for (var field in encabezados) {
      if (field is String && field.contains(keyHead)) {
        index = encabezados.indexOf(field);
      }
    }
    return index;
  }

  static ({String keyConsumo, String keyFecha}) readHeadCsv(
    List<List> csvData,
  ) => _getKeysHead(csvData.first);

  static int? getIndexConsumo(List<List> csvData, String keyConsumo) =>
      _getIndex(csvData.first, keyConsumo);

  static int? getIndexFecha(List<List> csvData, String keyFecha) =>
      _getIndex(csvData.first, keyFecha);

  /// GET DATOS CSV: FECHAS Y CONSUMOS
  static ({List<LineaCsv> datosCsv, int errorType}) getDatos({
    required List<List> csvData,
    required String keyConsumo,
    required int indexFecha,
    required int indexConsumo,
  }) {
    List<LineaCsv> datosCsv = [];
    try {
      for (int i = 0; i < csvData.length; i++) {
        if (i == 0) continue;
        // FECHA
        var fecha = csvData[i][indexFecha].toString();
        var fechaFormat = fecha.replaceAll('/', '-');
        // 13/02/2025 => 30-03-2025
        if (fecha.contains(' ')) {
          fechaFormat = fecha.substring(0, fecha.indexOf(' '));
        }
        if (DateFormat(
          'dd-MM-yyyy',
        ).parse(fechaFormat).isBefore(DateTime(2021, 6))) {
          return (datosCsv: <LineaCsv>[], errorType: 1);
        }
        // CONSUMO
        var consumo = csvData[i][indexConsumo].toString();
        consumo = consumo.replaceAll(',', '.');
        if (double.tryParse(consumo) == null) throw Error();
        double consumoDouble = double.tryParse(consumo)!;
        if (!keyConsumo.contains('kWh')) {
          consumoDouble = consumoDouble / 1000;
        }
        // DATOS
        datosCsv.add((fecha: fechaFormat, hora: i, consumo: consumoDouble));
      }
      return (datosCsv: datosCsv, errorType: 0);
    } catch (error) {
      return (datosCsv: <LineaCsv>[], errorType: 2);
    }
  }

  /// READ DATOS CSV: FECHAS Y CONSUMOS
  static ({List<String> fechas, List<DateTime> dates}) readFechas(
    List<LineaCsv> datosCsv,
  ) {
    List<String> fechasCsv = [];
    List<DateTime> datesCsv = [];
    for (var datoCsv in datosCsv) {
      fechasCsv.add(datoCsv.fecha);
      datesCsv.add(DateFormat('dd-MM-yyyy').parse(datoCsv.fecha));
    }
    fechasCsv = LinkedHashSet<String>.from(fechasCsv).toList();
    datesCsv = LinkedHashSet<DateTime>.from(datesCsv).toList();
    return (fechas: fechasCsv, dates: datesCsv);
  }

  static ({
    Map<String, List<double>> mapFechaConsumos,
    Map<DateTime, List<double>> mapDateConsumos,
  })
  readConsumos({
    required List<LineaCsv> datosCsv,
    required List<String> fechasCsv,
  }) {
    Map<String, List<double>> mapFechaConsumos = {};
    for (var fecha in fechasCsv) {
      mapFechaConsumos[fecha] = [];
    }
    for (var datoCsv in datosCsv) {
      for (var fechaKey in mapFechaConsumos.keys) {
        if (datoCsv.fecha == fechaKey) {
          mapFechaConsumos[fechaKey]?.add(datoCsv.consumo);
        }
      }
    }
    for (var k in mapFechaConsumos.keys) {
      var dateDT = DateFormat('dd-MM-yyyy').parse(k);
      var fechaString = DateFormat('yyyy-MM-dd').format(dateDT);
      if (HorarioVerano.check(fechaString)) {
        mapFechaConsumos[k]?.insert(2, 0);
      }
    }
    Map<DateTime, List<double>> mapDateConsumos = {};
    bool error24 = false;
    mapFechaConsumos.forEach((k, v) {
      if (v.length != 24) {
        error24 = true;
        return;
      }
      var date = DateFormat('dd-MM-yyyy').parse(k);
      mapDateConsumos[date] = v;
    });
    if (error24) {
      return (
        mapFechaConsumos: <String, List<double>>{},
        mapDateConsumos: <DateTime, List<double>>{},
      );
    }
    return (
      mapFechaConsumos: mapFechaConsumos,
      mapDateConsumos: mapDateConsumos,
    );
  }

  /// GET PRECIOS BY FECHAS

  /// GET FILES
  static ({String? fecha1, String? fecha2}) _getRangoDates(
    List<DateTime> dates,
  ) {
    if (dates.last.isBefore(dates.first)) {
      return (fecha1: null, fecha2: null);
    }
    String fecha1 = DateFormat('yyyy-MM-dd').format(dates.first);
    String fecha2 = DateFormat('yyyy-MM-dd').format(dates.last);
    return (fecha1: fecha1, fecha2: fecha2);
  }

  static ({String? fecha1, String? fecha2}) getFechas(List<DateTime> datesCsv) {
    var fechasLimite = _getRangoDates(datesCsv);
    return (fecha1: fechasLimite.fecha1, fecha2: fechasLimite.fecha2);
  }

  static Future<httpdio.Response> downloadFile(
    String fecha1,
    String fecha2,
  ) async => await FileUtil.downloadFilePVPC(fecha1: fecha1, fecha2: fecha2);

  static Future<bool> extractZip(String fileName) async =>
      await FileUtil.extractZipPVPC(fileName);

  static void deleteFile(String fileName) {
    FileUtil.deleteFile(fileName);
  }

  static Future<List<File>> getFilesPVPC() async =>
      await FileUtil.getFilesPVPC();

  /// READ FILES: GET PRECIOS BY FECHAS

  // PVPC
  static Future<Map<String, List<double>>> readFiles(
    List<File> archivos,
  ) async {
    Map<String, List<double>> mapFechaPrecios = {};
    try {
      for (var archivo in archivos) {
        String contents = await archivo.readAsString();
        final Map<String, dynamic> data = jsonDecode(contents);
        List<dynamic> pvpcList = data['PVPC'];
        List<String> listaDias = [];
        List<String> listaPrecios = [];
        for (var pvpc in pvpcList) {
          listaDias.add(pvpc['Dia']);
          listaPrecios.add(pvpc['PCB']);
          // List<String> listaHoras = pvpc['Hora'];
        }
        if (listaDias.isEmpty || listaPrecios.isEmpty) throw Error();
        String fecha = listaDias.first.replaceAll('/', '-'); // 30-03-2025
        mapFechaPrecios[fecha] = [];
        for (var precio in listaPrecios) {
          var precioDouble =
              double.tryParse(precio.replaceAll(',', '.'))! / 1000;
          mapFechaPrecios[fecha]?.add(precioDouble);
        }
      }
      return mapFechaPrecios;
    } catch (error) {
      return <String, List<double>>{};
    } finally {
      await FileUtil.deleteDir();
    }
  }

  static Map<String, List<double>> checkVerano(
    Map<String, List<double>> mapFechaPrecios,
  ) {
    Map<String, List<double>> mapFechaPrecios2 = Map.from(mapFechaPrecios);
    for (var k in mapFechaPrecios2.keys) {
      var dateDT = DateFormat('dd-MM-yyyy').parse(k);
      var fechaString = DateFormat('yyyy-MM-dd').format(dateDT);
      if (HorarioVerano.check(fechaString)) {
        mapFechaPrecios2[k]?.insert(2, 0);
      }
    }
    return mapFechaPrecios2;
  }

  static ({Map<DateTime, List<double>> mapDatePrecios, bool error24})
  getDatePrecios(Map<String, List<double>> mapFechaPrecios) {
    Map<DateTime, List<double>> mapDatePrecios = {};
    bool error24 = false;
    mapFechaPrecios.forEach((k, v) {
      if (v.length != 24) {
        error24 = true;
        return;
      }
      var date = DateFormat('dd-MM-yyyy').parse(k);
      mapDatePrecios[date] = v;
    });
    if (error24) {
      return (mapDatePrecios: <DateTime, List<double>>{}, error24: error24);
    }
    return (mapDatePrecios: mapDatePrecios, error24: error24);
  }

  // MERCADO LIBRE
  static ({Map<String, List<double>> mapFechaPreciosLibre, bool error})
  getPreciosLibre(
    Map<String, List<double>> mapFechaPrecios,
    double precioPunta,
    double precioLlano,
    double precioValle,
  ) {
    Map<String, List<double>> mapFechaPreciosLibre = {};
    try {
      for (var fecha in mapFechaPrecios.keys) {
        // fecha 30-03-2025
        List<double> preciosHoraLibre = <double>[];
        for (var h = 0; h < 24; h++) {
          DateTime date = DateFormat('dd-MM-yyyy').parse(fecha);
          date = DateTime(date.year, date.month, date.day, h);
          var periodo = Tarifa.getPeriodo(date);
          double precioHora = switch (periodo) {
            Periodo.punta => precioPunta,
            Periodo.llano => precioLlano,
            Periodo.valle => precioValle,
          };
          preciosHoraLibre.add(precioHora);
        }
        mapFechaPreciosLibre[fecha] = preciosHoraLibre;
      }
      return (mapFechaPreciosLibre: mapFechaPreciosLibre, error: false);
    } catch (e) {
      return (mapFechaPreciosLibre: <String, List<double>>{}, error: true);
    }
  }

  static ({Map<DateTime, List<double>> mapDatePreciosLibre, bool error})
  getDatePreciosLibre(Map<String, List<double>> mapFechaPreciosLibre) {
    Map<DateTime, List<double>> mapDatePreciosLibre = {};
    bool error24 = false;
    mapFechaPreciosLibre.forEach((k, v) {
      if (v.length != 24) {
        error24 = true;
        return;
      }
      var date = DateFormat('dd-MM-yyyy').parse(k);
      mapDatePreciosLibre[date] = v;
    });
    if (error24) {
      return (mapDatePreciosLibre: <DateTime, List<double>>{}, error: true);
    }
    return (mapDatePreciosLibre: mapDatePreciosLibre, error: false);
  }

  /// PRECIOS PVPC Y LIBRES
  static List<List<double>> getListasConsumoXPrecio({
    required List<List<double>> listasPrecios,
    required List<List<double>> listasConsumos,
  }) {
    List<List<double>> listasConsumoXPrecio = [];
    try {
      for (var i = 0; i < listasConsumos.length; i++) {
        List<double> listaConsumoXPrecio = [];
        var listaPrecio = listasPrecios[i];
        var listaConsumo = listasConsumos[i];
        for (var j = 0; j < listaConsumo.length; j++) {
          double precioXConsumo = listaPrecio[j] * listaConsumo[j];
          listaConsumoXPrecio.add(precioXConsumo);
        }
        listasConsumoXPrecio.add(listaConsumoXPrecio);
      }
    } catch (e) {
      return [];
    }
    return listasConsumoXPrecio;
  }

  static double getFacturaConsumos(List<List<double>> listasConsumoXPrecio) {
    double facturaConsumos = 0;
    for (var lista in listasConsumoXPrecio) {
      var sumaLista = lista.reduce((v, e) => v + e);
      facturaConsumos = facturaConsumos + sumaLista;
    }
    return facturaConsumos;
  }

  static double facturaPotencia(
    int dias,
    double potenciaPunta,
    double potenciaPuntaPrecio,
    double potenciaValle,
    double potenciaVallePrecio,
  ) =>
      (potenciaPunta * potenciaPuntaPrecio * dias) +
      (potenciaValle * potenciaVallePrecio * dias);
}
