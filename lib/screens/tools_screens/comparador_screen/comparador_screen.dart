import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../database/box_data.dart';
import '../../../database/storage.dart';
import '../../../models/tarifa.dart';
import '../../../theme/style_app.dart';
import '../../../utils/estados.dart';
import '../../../utils/file_util.dart';
import '../../../utils/horario_verano.dart';
import '../../../utils/shared_prefs.dart';
import '../../home_screen/home_screen.dart';
import 'widgets/comparador_aviso.dart';
import 'widgets/resultado.dart';

typedef LineaCsv = ({String fecha, int hora, double consumo});

class Comparador extends StatefulWidget {
  const Comparador({super.key});
  @override
  State<Comparador> createState() => _ComparadorState();
}

class _ComparadorState extends State<Comparador> {
  TextEditingController controllerFile = TextEditingController();
  TextEditingController controllerPotenciaPVPCPunta = TextEditingController();
  TextEditingController controllerPotenciaPVPCValle = TextEditingController();
  TextEditingController controllerPotenciaPVPCPuntaPrecio =
      TextEditingController();
  TextEditingController controllerPotenciaPVPCVallePrecio =
      TextEditingController();
  TextEditingController controllerPotenciaLibrePunta = TextEditingController();
  TextEditingController controllerPotenciaLibreValle = TextEditingController();
  TextEditingController controllerPotenciaLibrePuntaPrecio =
      TextEditingController();
  TextEditingController controllerPotenciaLibreVallePrecio =
      TextEditingController();
  TextEditingController controllerPrecioValle = TextEditingController();
  TextEditingController controllerPrecioLlano = TextEditingController();
  TextEditingController controllerPrecioPunta = TextEditingController();

  bool franjaHorariaUnica = false;
  File? fileConsumos;
  bool downloadOnProgress = false;
  final FilteringTextInputFormatter filterInput =
      FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d*)?'));

  final SharedPrefs sharedPrefs = SharedPrefs();
  Storage storage = Storage();

  @override
  void initState() {
    loadSharedPrefs();
    controllerPotenciaPVPCPuntaPrecio.text = '0.069376';
    controllerPotenciaPVPCVallePrecio.text = '0.002647';
    super.initState();
  }

  void loadSharedPrefs() async => await sharedPrefs.init();

  @override
  void dispose() {
    controllerFile.dispose();
    controllerPotenciaPVPCPunta.dispose();
    controllerPotenciaPVPCValle.dispose();
    controllerPotenciaPVPCPuntaPrecio.dispose();
    controllerPotenciaPVPCVallePrecio.dispose();
    controllerPotenciaLibrePunta.dispose();
    controllerPotenciaLibreValle.dispose();
    controllerPotenciaLibrePuntaPrecio.dispose();
    controllerPotenciaLibreVallePrecio.dispose();
    controllerPrecioValle.dispose();
    controllerPrecioLlano.dispose();
    controllerPrecioPunta.dispose();
    super.dispose();
  }

  Future<void> selectFileConsumos() async {
    controllerFile.clear();
    ({File? fileCsv, bool isSelect}) resultCsv = await FileUtil.selectFile();
    if (resultCsv.isSelect == false) return;
    if (resultCsv.isSelect && resultCsv.fileCsv == null) {
      if (!mounted) return;
      const snackBar = SnackBar(content: Text('Archivo no válido.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      controllerFile.text = path.basename(resultCsv.fileCsv!.path);
      setState(() => fileConsumos = resultCsv.fileCsv);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(isFirstLaunch: false),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Comparador'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog.fullscreen(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: const ComparadorAviso(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.warning_amber, color: Colors.red),
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            decoration: StyleApp.mainDecoration,
            padding: const EdgeInsets.all(20),
            height: double.infinity,
            child: downloadOnProgress
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text('Calculando tarifas...'),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comparador de Tarifas',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        // CONSUMOS
                        ListTile(
                          leading: Icon(Icons.attach_file),
                          title: TextField(
                            controller: controllerFile,
                            decoration: InputDecoration(
                              labelText: 'Archivo csv de consumos',
                            ),
                            keyboardType: TextInputType.none,
                            onTap: selectFileConsumos,
                          ),
                          /*trailing: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.Csv),
                          ),*/
                        ),
                        const SizedBox(height: 10),
                        // PVPC
                        Text(
                          '💡 PVPC',
                          style: TextStyle(
                            color: StyleApp.onBackgroundColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipPath(
                          clipper: StyleApp.kBorderClipper,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 14,
                            ),
                            width: double.infinity,
                            decoration: StyleApp.kBoxDeco,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Potencia contratada',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Text('P1 PUNTA')),
                                    Expanded(
                                      child: TextField(
                                        controller: controllerPotenciaPVPCPunta,
                                        decoration: InputDecoration(
                                          labelText: 'kW',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                        onChanged: (value) {
                                          controllerPotenciaLibrePunta.text =
                                              controllerPotenciaPVPCPunta.text;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            controllerPotenciaPVPCPuntaPrecio,
                                        decoration: InputDecoration(
                                          labelText: '€/kW día',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Text('P2 VALLE')),
                                    Expanded(
                                      child: TextField(
                                        controller: controllerPotenciaPVPCValle,
                                        decoration: InputDecoration(
                                          labelText: 'kW',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                        onChanged: (value) {
                                          controllerPotenciaLibreValle.text =
                                              controllerPotenciaPVPCValle.text;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            controllerPotenciaPVPCVallePrecio,
                                        decoration: InputDecoration(
                                          labelText: '€/kW día',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '🛒 MERCADO LIBRE',
                          style: TextStyle(
                            color: StyleApp.onBackgroundColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipPath(
                          clipper: StyleApp.kBorderClipper,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 14,
                            ),
                            width: double.infinity,
                            decoration: StyleApp.kBoxDeco,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Potencia',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Text('P1 PUNTA')),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            controllerPotenciaLibrePunta,
                                        decoration: InputDecoration(
                                          labelText: 'kW',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            controllerPotenciaLibrePuntaPrecio,
                                        decoration: InputDecoration(
                                          labelText: '€/kW día',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Text('P2 VALLE')),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            controllerPotenciaLibreValle,
                                        decoration: InputDecoration(
                                          labelText: 'kW',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            controllerPotenciaLibreVallePrecio,
                                        decoration: InputDecoration(
                                          labelText: '€/kW día',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Precios (€/kWh)',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Row(
                                  children: [
                                    Text('Tarifa sin franjas horarias'),
                                    Checkbox(
                                      value: franjaHorariaUnica,
                                      onChanged: (value) {
                                        setState(() {
                                          franjaHorariaUnica = value!;
                                          if (value) {
                                            controllerPrecioLlano.text =
                                                controllerPrecioPunta.text;
                                            controllerPrecioValle.text =
                                                controllerPrecioPunta.text;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: controllerPrecioPunta,
                                        decoration: InputDecoration(
                                          labelText: 'Punta',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                        onChanged: (value) {
                                          if (franjaHorariaUnica) {
                                            controllerPrecioLlano.text =
                                                controllerPrecioPunta.text;
                                            controllerPrecioValle.text =
                                                controllerPrecioPunta.text;
                                          }
                                        },
                                      ),
                                    ),
                                    const Spacer(),
                                    Expanded(
                                      child: TextField(
                                        controller: controllerPrecioLlano,
                                        decoration: InputDecoration(
                                          labelText: 'Llano',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                        enabled: !franjaHorariaUnica,
                                      ),
                                    ),
                                    const Spacer(),
                                    Expanded(
                                      child: TextField(
                                        controller: controllerPrecioValle,
                                        decoration: InputDecoration(
                                          labelText: 'Valle',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [filterInput],
                                        enabled: !franjaHorariaUnica,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: calcular,
                          child: const Center(child: Text('CALCULAR')),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> calcular() async {
    if (fileConsumos == null ||
        controllerFile.text.isEmpty ||
        controllerPotenciaPVPCPunta.text.isEmpty ||
        controllerPotenciaPVPCPuntaPrecio.text.isEmpty ||
        controllerPotenciaPVPCValle.text.isEmpty ||
        controllerPotenciaPVPCVallePrecio.text.isEmpty ||
        controllerPotenciaLibrePunta.text.isEmpty ||
        controllerPotenciaLibrePuntaPrecio.text.isEmpty ||
        controllerPotenciaLibreValle.text.isEmpty ||
        controllerPotenciaLibreVallePrecio.text.isEmpty ||
        controllerPrecioPunta.text.isEmpty ||
        controllerPrecioLlano.text.isEmpty ||
        controllerPrecioValle.text.isEmpty ||
        double.tryParse(controllerPotenciaPVPCPunta.text) == null ||
        double.tryParse(controllerPotenciaPVPCValle.text) == null ||
        double.tryParse(controllerPotenciaPVPCPuntaPrecio.text) == null ||
        double.tryParse(controllerPotenciaPVPCVallePrecio.text) == null ||
        double.tryParse(controllerPotenciaLibrePunta.text) == null ||
        double.tryParse(controllerPotenciaLibreValle.text) == null ||
        double.tryParse(controllerPotenciaLibrePuntaPrecio.text) == null ||
        double.tryParse(controllerPotenciaLibreVallePrecio.text) == null ||
        double.tryParse(controllerPrecioPunta.text) == null ||
        double.tryParse(controllerPrecioLlano.text) == null ||
        double.tryParse(controllerPrecioValle.text) == null) {
      showSnackBar('Datos incorrectos o insuficientes.');
      return;
    }

    // READ FILE CSV
    List<List> csvData = await FileUtil.loadCsvData(fileConsumos!.path);
    if (csvData.isEmpty) {
      showSnackBar('Imposible lectura de archivo de consumos.');
      return;
    }

    // READ HEAD CSV: KEYS AND INDEX FECHA Y CONSUMO
    var keysHead = getKeysHead(csvData.first);
    String keyFecha = keysHead.keyFecha;
    String keyConsumo = keysHead.keyConsumo;
    if (keyFecha.isEmpty || keyConsumo.isEmpty) {
      showSnackBar('Error en la lectura del archivo de consumos.');
      return;
    }
    int? indexConsumo = getIndex(csvData.first, keyConsumo);
    int? indexFecha = getIndex(csvData.first, keyFecha);
    if (indexConsumo == null || indexFecha == null) {
      showSnackBar('Error en la lectura del archivo de consumos.');
      return;
    }

    // GET DATOS CSV: FECHAS Y CONSUMOS
    List<LineaCsv> datosCsv = [];
    try {
      for (int i = 0; i < csvData.length; i++) {
        if (i == 0) continue;
        // FECHA
        var fecha = csvData[i][indexFecha].toString();
        var fechaFormat = fecha.replaceAll(
          '/',
          '-',
        ); // 13/02/2025 => 30-03-2025
        if (fecha.contains(' ')) {
          // 2023/06/09 01:00
          fechaFormat = fecha.substring(0, fecha.indexOf(' '));
        }
        if (DateFormat(
          'dd-MM-yyyy',
        ).parse(fechaFormat).isBefore(DateTime(2021, 6))) {
          showSnackBar(
            'Error: La fecha mínima es el 1 de junio de 2021, '
            'cuando se aplica el vigente sistema de la tarifa eléctrica.',
          );
          return;
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
    } catch (e) {
      showSnackBar('Error en la captura de datos del archivo de consumos.');
      return;
    }

    if (datosCsv.isEmpty) {
      showSnackBar('Error: archivo de consumos vacío.');
      return;
    }

    // READ DATOS CSV: FECHAS Y CONSUMOS
    Map<String, List<double>> mapFechaConsumos = {};
    Map<DateTime, List<double>> mapDateConsumos = {};
    List<String> fechasCsv = [];
    List<DateTime> datesCsv = [];
    for (var datoCsv in datosCsv) {
      fechasCsv.add(datoCsv.fecha);
      datesCsv.add(DateFormat('dd-MM-yyyy').parse(datoCsv.fecha));
    }
    fechasCsv = LinkedHashSet<String>.from(fechasCsv).toList();
    datesCsv = LinkedHashSet<DateTime>.from(datesCsv).toList();

    if (fechasCsv.isEmpty || datesCsv.isEmpty) {
      showSnackBar('Error en la lectura del archivo de consumos.');
      return;
    }

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

    mapFechaConsumos.forEach((k, v) {
      if (v.length != 24) {
        showSnackBar('Error en la lectura del archivo de consumos.');
        return;
      }
      var date = DateFormat('dd-MM-yyyy').parse(k);
      mapDateConsumos[date] = v;
    });

    if (mapFechaConsumos.isEmpty ||
        mapFechaConsumos.values.isEmpty ||
        mapDateConsumos.isEmpty ||
        mapDateConsumos.values.isEmpty) {
      showSnackBar('Error en la lectura del archivo de consumos.');
      return;
    }

    // GET PRECIOS BY FECHAS
    // PVPC
    /*var fechasLimite = getRangoFormat(fechasCsv);
    var fecha1 = fechasLimite.fecha1;
    var fecha2 = fechasLimite.fecha2;*/

    var fechasLimite = getRangoDates(datesCsv);
    if (fechasLimite.fecha1 == null || fechasLimite.fecha2 == null) {
      showSnackBar('Error en la lectura del archivo de consumos.');
      return;
    }
    String fecha1 = fechasLimite.fecha1!;
    String fecha2 = fechasLimite.fecha2!;

    setState(() => downloadOnProgress = true);
    var download = await FileUtil.downloadFilePVPC(
      fecha1: fecha1,
      fecha2: fecha2,
    );
    setState(() => downloadOnProgress = false);
    if (download.statusCode != 200) {
      showSnackBar('Error en la descarga de los precios PVPC.');
      return;
    }
    if (fecha1 != fecha2) {
      final String fileName = '$fecha1-$fecha2.zip';
      var extractZipOk = await FileUtil.extractZipPVPC(fileName);
      if (extractZipOk == false) {
        showSnackBar('Error en la extracción de datos de los precios PVPC.');
        return;
      }
      FileUtil.deleteFile(fileName);
    }

    // appDocDirPath/PVPC/ => 20250213.json
    var archivos = await FileUtil.getFilesPVPC();
    if (archivos.isEmpty) {
      showSnackBar('Error en la recuperación de los archivos de precios PVPC.');
      return;
    }
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
    } catch (e) {
      showSnackBar('Error en la consulta de los precios PVPC.');
      return;
    } finally {
      await FileUtil.deleteDir();
    }

    if (mapFechaPrecios.isEmpty || mapFechaPrecios.values.isEmpty) {
      showSnackBar('Error: archivo de precios PVPC vacío.');
      return;
    }

    for (var k in mapFechaPrecios.keys) {
      var dateDT = DateFormat('dd-MM-yyyy').parse(k);
      var fechaString = DateFormat('yyyy-MM-dd').format(dateDT);
      if (HorarioVerano.check(fechaString)) {
        mapFechaPrecios[k]?.insert(2, 0);
      }
    }

    Map<DateTime, List<double>> mapDatePrecios = {};
    mapFechaPrecios.forEach((k, v) {
      if (v.length != 24) {
        showSnackBar('Error en la lectura del archivo de precios PVPC.');
        return;
      }
      var date = DateFormat('dd-MM-yyyy').parse(k);
      // var fecha = DateFormat('yyyy-MM-dd').format(DateTime(year, mes, dia));
      // DateTime date = DateTime.parse(fecha);
      mapDatePrecios[date] = v;
    });

    // MERCADO LIBRE
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
            Periodo.punta => double.tryParse(controllerPrecioPunta.text)!,
            Periodo.llano => double.tryParse(controllerPrecioLlano.text)!,
            Periodo.valle => double.tryParse(controllerPrecioValle.text)!,
          };
          preciosHoraLibre.add(precioHora);
        }
        mapFechaPreciosLibre[fecha] = preciosHoraLibre;
      }
    } catch (e) {
      showSnackBar('Error en cálculo de precios.');
      return;
    }

    if (mapFechaPreciosLibre.values.isEmpty) {
      showSnackBar('Error: cálculo de precios de mercado libre.');
      return;
    }

    Map<DateTime, List<double>> mapDatePreciosLibre = {};
    mapFechaPreciosLibre.forEach((k, v) {
      if (v.length != 24) {
        showSnackBar('Error en el cáculo de precios del mercado libre.');
        return;
      }
      var date = DateFormat('dd-MM-yyyy').parse(k);
      mapDatePreciosLibre[date] = v;
    });

    // PRECIOS PVPC Y LIBRES
    var sortedByKeymapDatePrecios = Map.fromEntries(
      mapDatePrecios.entries.toList()
        ..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );

    if (sharedPrefs.storageComparador) {
      mapDatePrecios.forEach((date, value) {
        if (!storage.fechaInBoxData(date)) {
          storage.saveBoxData(BoxData(fecha: date, preciosHora: value));
        }
      });
    }

    var sortedByKeymapDatePreciosLibre = Map.fromEntries(
      mapDatePreciosLibre.entries.toList()
        ..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );

    List<DateTime> listaDates = mapDateConsumos.keys.toList();
    List<List<double>> listasConsumo = mapDateConsumos.values.toList();
    List<List<double>> listasPrecio = sortedByKeymapDatePrecios.values.toList();
    List<List<double>> listasPrecioLibre = sortedByKeymapDatePreciosLibre.values
        .toList();

    List<List<double>> listasConsumoXPrecio = getListasConsumoXPrecio(
      listasPrecios: listasPrecio,
      listasConsumos: listasConsumo,
    );
    List<List<double>> listasConsumoXPrecioLibre = getListasConsumoXPrecio(
      listasPrecios: listasPrecioLibre,
      listasConsumos: listasConsumo,
    );

    if (listasConsumoXPrecio.isEmpty) {
      showSnackBar('Error en la obtención de los precios PVPC.');
      return;
    }
    if (listasConsumoXPrecioLibre.isEmpty) {
      showSnackBar('Error en la obtención de los precios del mercado libre.');
      return;
    }

    /*Map<DateTime, List<double>> mapFechaConsumoXPrecio =
        Map.fromIterables(listaDates, listasConsumoXPrecio);
    Map<DateTime, List<double>> mapFechaConsumoXPrecioLibre =
        Map.fromIterables(listaDates, listasConsumoXPrecioLibre);*/

    double facturaConsumosPVPC = getFacturaConsumos(
      listasConsumoXPrecio: listasConsumoXPrecio,
    );
    double facturaConsumosLibre = getFacturaConsumos(
      listasConsumoXPrecio: listasConsumoXPrecioLibre,
    );

    int dias = listaDates.length;
    double facturaPotenciaPVPC =
        (double.tryParse(controllerPotenciaPVPCPunta.text)! *
            double.tryParse(controllerPotenciaPVPCPuntaPrecio.text)! *
            dias) +
        (double.tryParse(controllerPotenciaPVPCValle.text)! *
            double.tryParse(controllerPotenciaPVPCVallePrecio.text)! *
            dias);

    double facturaPotenciaLibre =
        (double.tryParse(controllerPotenciaLibrePunta.text)! *
            double.tryParse(controllerPotenciaLibrePuntaPrecio.text)! *
            dias) +
        (double.tryParse(controllerPotenciaLibreValle.text)! *
            double.tryParse(controllerPotenciaLibreVallePrecio.text)! *
            dias);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Resultado(
            fechas: listaDates,
            facturaConsumosPVPC: facturaConsumosPVPC,
            facturaPotenciaPVPC: facturaPotenciaPVPC,
            facturaConsumosLibre: facturaConsumosLibre,
            facturaPotenciaLibre: facturaPotenciaLibre,
          ),
        ),
      );
    }
  }

  /*({String fecha1, String fecha2}) getRangoFormat(List<String> fechas) {
    //{13/02/2025, 14/02/2025,
    var inputFormat = DateFormat('dd-MM-yyyy');
    DateTime date1 = inputFormat.parse(fechas.first); // 00:00:00
    DateTime date2 = inputFormat.parse(fechas.last);
    String fecha1 = DateFormat('yyyy-MM-dd').format(date1);
    String fecha2 = DateFormat('yyyy-MM-dd').format(date2);
    return (fecha1: fecha1, fecha2: fecha2);
  }*/

  ({String? fecha1, String? fecha2}) getRangoDates(List<DateTime> dates) {
    if (dates.last.isBefore(dates.first)) {
      return (fecha1: null, fecha2: null);
    }
    String fecha1 = DateFormat('yyyy-MM-dd').format(dates.first);
    String fecha2 = DateFormat('yyyy-MM-dd').format(dates.last);
    return (fecha1: fecha1, fecha2: fecha2);
  }

  int? getIndex(List encabezados, String keyHead) {
    int? index;
    for (var field in encabezados) {
      if (field is String && field.contains(keyHead)) {
        index = encabezados.indexOf(field);
      }
    }
    return index;
  }

  ({String keyFecha, String keyConsumo}) getKeysHead(List head) {
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

  List<List<double>> getListasConsumoXPrecio({
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

  double getFacturaConsumos({
    required List<List<double>> listasConsumoXPrecio,
  }) {
    double facturaConsumos = 0;
    for (var lista in listasConsumoXPrecio) {
      var sumaLista = lista.reduce((v, e) => v + e);
      facturaConsumos = facturaConsumos + sumaLista;
    }
    return facturaConsumos;
  }
}
