import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import '../../../database/box_data.dart';
import '../../../database/storage.dart';
import '../../../theme/style_app.dart';
import '../../../utils/file_util.dart';
import '../../../utils/shared_prefs.dart';
import '../../nav/pop_scope_helper.dart';
import '../../nav/snack_bar_helper.dart';
import 'comparador.dart';
import 'precio_potencia_pvpc.dart';
import 'widgets/comparador_aviso.dart';
import 'widgets/open_aviso.dart';
import 'widgets/potencia_aviso.dart';
import 'widgets/resultado.dart';

typedef LineaCsv = ({String fecha, int hora, double consumo});

class ComparadorScreen extends StatefulWidget {
  const ComparadorScreen({super.key});
  @override
  State<ComparadorScreen> createState() => _ComparadorScreenState();
}

class _ComparadorScreenState extends State<ComparadorScreen> {
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

  PrecioPotenciaPVPC yearDefault = PrecioPotenciaPVPC.values.first;
  PrecioPotenciaPVPC? yearSelect = PrecioPotenciaPVPC.values.first;

  @override
  void initState() {
    loadSharedPrefs();
    controllerPotenciaPVPCPuntaPrecio.text = '0.073782'; // '0.069376';
    controllerPotenciaPVPCVallePrecio.text = '0.001911'; // '0.002647';
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
      //const snackBar = SnackBar(content: Text('Archivo no válido.'));
      //ScaffoldMessenger.of(context).showSnackBar(snackBar);
      SnackBarHelper.show(context, 'Archivo no válido.');
    } else {
      controllerFile.text = path.basename(resultCsv.fileCsv!.path);
      setState(() => fileConsumos = resultCsv.fileCsv);
    }
  }

  void updatePrecioPotenciaPVPC(PrecioPotenciaPVPC? year) {
    if (year == null) {
      return;
    }
    controllerPotenciaPVPCPuntaPrecio.text = year.precioDiaPunta
        .toStringAsFixed(6);
    controllerPotenciaPVPCVallePrecio.text = year.precioDiaValle
        .toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: PopScopeHelper.onPopInvoked(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Comparador'),
          actions: [
            IconButton(
              onPressed: () {
                OpenAviso.show(context, widget: ComparadorAviso());
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '💡 PVPC',
                              style: TextStyle(
                                color: StyleApp.onBackgroundColor,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                OpenAviso.show(
                                  context,
                                  widget: PotenciaAviso(),
                                );
                              },
                              icon: Icon(Icons.help_outline),
                            ),
                          ],
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Potencia contratada',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    DropdownMenu<PrecioPotenciaPVPC>(
                                      initialSelection: yearDefault,
                                      dropdownMenuEntries:
                                          PrecioPotenciaPVPC.entries,
                                      onSelected: (PrecioPotenciaPVPC? year) {
                                        setState(() => yearSelect = year);
                                        updatePrecioPotenciaPVPC(year);
                                      },
                                    ),
                                  ],
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
                        Center(
                          child: ElevatedButton.icon(
                            style: StyleApp.buttonStyle,
                            icon: Icon(Icons.calculate),
                            onPressed: calcular,
                            label: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('CALCULAR'),
                            ),
                            //child: const Center(child: Text('CALCULAR')),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
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
      SnackBarHelper.show(context, 'Datos incorrectos o insuficientes.');
      return;
    }

    /// READ FILE CSV
    List<List> csvData = await Comparador.readFile(fileConsumos!);
    if (csvData.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(context, 'Imposible lectura de archivo de consumos.');
      return;
    }

    /// READ HEAD CSV: KEYS AND INDEX FECHA Y CONSUMO
    var keysHead = Comparador.readHeadCsv(csvData);
    String keyFecha = keysHead.keyFecha;
    String keyConsumo = keysHead.keyConsumo;
    if (keyFecha.isEmpty || keyConsumo.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la lectura del archivo de consumos.',
      );
      return;
    }

    int? indexConsumo = Comparador.getIndexConsumo(csvData, keyConsumo);
    int? indexFecha = Comparador.getIndexFecha(csvData, keyFecha);
    if (indexConsumo == null || indexFecha == null) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la lectura del archivo de consumos.',
      );
      return;
    }

    /// GET DATOS CSV: FECHAS Y CONSUMOS
    var datos = Comparador.getDatos(
      csvData: csvData,
      keyConsumo: keyConsumo,
      indexFecha: indexFecha,
      indexConsumo: indexConsumo,
    );

    int errorType = datos.errorType;
    if (errorType == 1) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error: La fecha mínima es el 1 de junio de 2021, '
        'cuando se aplica el vigente sistema de la tarifa eléctrica.',
      );
      return;
    }
    if (errorType == 2) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la captura de datos del archivo de consumos.',
      );
      return;
    }

    List<LineaCsv> datosCsv = datos.datosCsv;
    if (datosCsv.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(context, 'Error: archivo de consumos vacío.');
      return;
    }

    /// READ DATOS CSV: FECHAS Y CONSUMOS
    var csv = Comparador.readFechas(datosCsv);
    var fechasCsv = csv.fechas;
    var datesCsv = csv.dates;
    if (fechasCsv.isEmpty || datesCsv.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la lectura del archivo de consumos.',
      );
      return;
    }

    var consumos = Comparador.readConsumos(
      datosCsv: datosCsv,
      fechasCsv: fechasCsv,
    );
    var mapFechaConsumos = consumos.mapFechaConsumos;
    var mapDateConsumos = consumos.mapDateConsumos;
    if (mapFechaConsumos.isEmpty ||
        mapFechaConsumos.values.isEmpty ||
        mapDateConsumos.isEmpty ||
        mapDateConsumos.values.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la lectura del archivo de consumos.',
      );
      return;
    }

    /// GET PRECIOS BY FECHAS
    // PVPC
    var fechasLimite = Comparador.getFechas(datesCsv);
    if (fechasLimite.fecha1 == null || fechasLimite.fecha2 == null) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la lectura del archivo de consumos.',
      );
      return;
    }
    String fecha1 = fechasLimite.fecha1!;
    String fecha2 = fechasLimite.fecha2!;

    setState(() => downloadOnProgress = true);
    var download = await Comparador.downloadFile(fecha1, fecha2);
    setState(() => downloadOnProgress = false);
    if (download.statusCode != 200) {
      if (!mounted) return;
      SnackBarHelper.show(context, 'Error en la descarga de los precios PVPC.');
      return;
    }
    if (fecha1 != fecha2) {
      final String fileName = '$fecha1-$fecha2.zip';
      var extractZip = await Comparador.extractZip(fileName);
      if (extractZip == false) {
        if (!mounted) return;
        SnackBarHelper.show(
          context,
          'Error en la extracción de datos de los precios PVPC.',
        );
        return;
      }
      Comparador.deleteFile(fileName);
    }

    // appDocDirPath/PVPC/ => 20250213.json
    var archivos = await Comparador.getFilesPVPC();
    if (archivos.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la recuperación de los archivos de precios PVPC.',
      );
      return;
    }

    var mapFechaPrecios = await Comparador.readFiles(archivos);
    if (mapFechaPrecios.isEmpty || mapFechaPrecios.values.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(context, 'Error en la consulta de los precios PVPC.');
      return;
    }

    mapFechaPrecios = Comparador.checkVerano(mapFechaPrecios);

    var getDatePrecios = Comparador.getDatePrecios(mapFechaPrecios);
    var error24 = getDatePrecios.error24;
    if (error24) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la lectura del archivo de precios PVPC.',
      );
      return;
    }
    var mapDatePrecios = getDatePrecios.mapDatePrecios;

    // MERCADO LIBRE
    double precioPunta = double.tryParse(controllerPrecioPunta.text)!;
    double precioLlano = double.tryParse(controllerPrecioLlano.text)!;
    double precioValle = double.tryParse(controllerPrecioValle.text)!;

    var getPreciosLibre = Comparador.getPreciosLibre(
      mapFechaPrecios,
      precioPunta,
      precioLlano,
      precioValle,
    );
    var errorGetPreciosLibre = getPreciosLibre.error;
    if (errorGetPreciosLibre) {
      if (!mounted) return;
      SnackBarHelper.show(context, 'Error en cálculo de precios.');
      return;
    }
    var mapFechaPreciosLibre = getPreciosLibre.mapFechaPreciosLibre;
    if (mapFechaPreciosLibre.values.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en cálculo de precios de mercado libre.',
      );
      return;
    }

    var getDatePreciosLibre = Comparador.getDatePreciosLibre(
      mapFechaPreciosLibre,
    );
    //var errorGetDatePreciosLibre = getDatePreciosLibre.error;
    if (getDatePreciosLibre.error) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en el cáculo de precios del mercado libre.',
      );
      return;
    }
    var mapDatePreciosLibre = getDatePreciosLibre.mapDatePreciosLibre;

    /// PRECIOS PVPC Y LIBRES

    if (sharedPrefs.storageComparador) {
      mapDatePrecios.forEach((date, value) {
        if (!storage.fechaInBoxData(date)) {
          storage.saveBoxData(BoxData(fecha: date, preciosHora: value));
        }
      });
    }

    //List<DateTime> listaDates = Comparador.getListaDates(mapDateConsumos);
    /*List<List<double>> listasConsumo = Comparador.getListasConsumo(
      mapDateConsumos,
    );
     List<List<double>> listasPrecio = Comparador.getListasPrecio(
      mapDatePrecios,
    );
    List<List<double>> listasPrecioLibre = Comparador.getListasPrecioLibre(
      mapDatePreciosLibre,
    );
    */

    Map<DateTime, List<double>> sortedByKey(
      Map<DateTime, List<double>> mapDate,
    ) => Map.fromEntries(
      mapDate.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );

    List<DateTime> listaDates = mapDateConsumos.keys.toList();
    List<List<double>> listasConsumo = mapDateConsumos.values.toList();
    List<List<double>> listasPrecio = sortedByKey(
      mapDatePrecios,
    ).values.toList();
    List<List<double>> listasPrecioLibre = sortedByKey(
      mapDatePreciosLibre,
    ).values.toList();

    List<List<double>> listasConsumoXPrecio =
        Comparador.getListasConsumoXPrecio(
          listasPrecios: listasPrecio,
          listasConsumos: listasConsumo,
        );
    List<List<double>> listasConsumoXPrecioLibre =
        Comparador.getListasConsumoXPrecio(
          listasPrecios: listasPrecioLibre,
          listasConsumos: listasConsumo,
        );

    if (listasConsumoXPrecio.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la obtención de los precios PVPC.',
      );
      return;
    }
    if (listasConsumoXPrecioLibre.isEmpty) {
      if (!mounted) return;
      SnackBarHelper.show(
        context,
        'Error en la obtención de los precios del mercado libre.',
      );
      return;
    }

    double facturaConsumosPVPC = Comparador.getFacturaConsumos(
      listasConsumoXPrecio,
    );
    double facturaConsumosLibre = Comparador.getFacturaConsumos(
      listasConsumoXPrecioLibre,
    );

    int dias = listaDates.length;
    var potenciaPVPCPunta = double.tryParse(controllerPotenciaPVPCPunta.text)!;
    var potenciaPVPCPuntaPrecio = double.tryParse(
      controllerPotenciaPVPCPuntaPrecio.text,
    )!;
    var potenciaPVPCValle = double.tryParse(controllerPotenciaPVPCValle.text)!;
    var potenciaPVPCVallePrecio = double.tryParse(
      controllerPotenciaPVPCVallePrecio.text,
    )!;
    double facturaPotenciaPVPC = Comparador.facturaPotencia(
      dias,
      potenciaPVPCPunta,
      potenciaPVPCPuntaPrecio,
      potenciaPVPCValle,
      potenciaPVPCVallePrecio,
    );
    var potenciaLibrePunta = double.tryParse(
      controllerPotenciaLibrePunta.text,
    )!;
    var potenciaLibrePuntaPrecio = double.tryParse(
      controllerPotenciaLibrePuntaPrecio.text,
    )!;
    var potenciaLibreValle = double.tryParse(
      controllerPotenciaLibreValle.text,
    )!;
    var potenciaLibreVallePrecio = double.tryParse(
      controllerPotenciaLibreVallePrecio.text,
    )!;
    double facturaPotenciaLibre = Comparador.facturaPotencia(
      dias,
      potenciaLibrePunta,
      potenciaLibrePuntaPrecio,
      potenciaLibreValle,
      potenciaLibreVallePrecio,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Resultado(
            fechas: listaDates,
            facturaConsumosPVPC: facturaConsumosPVPC,
            // * 1000,
            facturaPotenciaPVPC: facturaPotenciaPVPC,
            facturaConsumosLibre: facturaConsumosLibre,
            // * 1000,
            facturaPotenciaLibre: facturaPotenciaLibre,
          ),
        ),
      );
    }
  }
}
