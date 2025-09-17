import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/box_data.dart';
import '../../database/storage.dart';
import '../../models/request_ree.dart';
import '../../theme/style_app.dart';
import '../../utils/estados.dart';
import '../../utils/fecha_util.dart';
import '../../utils/file_util.dart';
import '../../utils/horario_verano.dart';
import '../../utils/shared_prefs.dart';
import 'widgets/grafico_precios.dart';
import 'tabs/home_tab/home_tab.dart';
import 'tabs/precios_tab.dart';
import 'tabs/timelapse_tab.dart';
import 'widgets/app_drawer.dart';
import 'widgets/main_body.dart';

class HomeScreen extends StatefulWidget {
  final DateTime? fecha;
  final bool isFirstLaunch;
  const HomeScreen({this.fecha, this.isFirstLaunch = false, super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFirstLaunch = false;
  int currentTab = 0;
  late ScrollController scrollController;
  final SharedPrefs sharedPrefs = SharedPrefs();
  HttpStatus httpStatus = HttpStatus.stopped;
  Storage storage = Storage();
  List<BoxData> listBoxData = [];
  BoxData? boxDataSelect;

  @override
  void initState() {
    Intl.defaultLocale = 'es_ES';
    isFirstLaunch = widget.isFirstLaunch;
    loadSharedPrefs();
    scrollController = ScrollController();
    listBoxData = storage.listBoxDataSort;
    initApp();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void loadSharedPrefs() async => await sharedPrefs.init();

  void resetHomeScreen() {
    setState(() {
      isFirstLaunch = false;
      loadSharedPrefs();
      currentTab = 0;
    });
    loadBoxData();
  }

  /// INICIO APLICACION : CARGA DATOS ALMACENADOS O CONSULTA NUEVOS DATOS
  void initApp() async {
    await sharedPrefs.init();
    DateTime fecha;
    final DateTime hoy = DateTime.now().toLocal();
    if (widget.fecha != null) {
      fecha = widget.fecha!;
      boxDataSelect = storage.getBoxData(fecha);
      loadBoxData();
    } else if (isFirstLaunch && sharedPrefs.autoGetData == true) {
      fecha = hoy.hour < 21 ? hoy : DateTime.now().add(const Duration(days: 1));
      if (storage.fechaInBoxData(fecha)) {
        boxDataSelect = storage.getBoxData(fecha);
        loadBoxData();
      } else {
        /// CONSULTA NUEVOS DATOS
        httpBoxData(fecha);
        //httpBoxDatas(fecha, fecha);
      }
    } else if (widget.fecha == null && storage.listBoxData.isNotEmpty) {
      fecha = storage.lastFecha;
      boxDataSelect = storage.getBoxData(fecha);
      if (sharedPrefs.maxArchivo != 0) {
        while (storage.listBoxData.length > sharedPrefs.maxArchivo) {
          storage.deleteFirst();
        }
      }
      loadBoxData();
    } else {
      fecha = hoy;
    }
  }

  /// CARGA DATOS ALMACENADOS
  void loadBoxData() {
    setState(() {
      listBoxData = storage.listBoxDataSort;
      httpStatus = HttpStatus.completed;
    });
  }

  /// CONSULTA NUEVOS DATOS A PARTIR DE UNA FECHA
  void httpBoxData([DateTime? fechaSelect]) async {
    /// DETERMINA LA FECHA
    if (fechaSelect != null) {
      setState(() => isFirstLaunch = false);
    }
    fechaSelect = fechaSelect ?? DateTime.now().toLocal();
    fechaSelect = FechaUtil.dateToDate000(fechaSelect);

    /// COMPRUEBA SI LA FECHA ESTÁ ALMACENADA
    if (isFirstLaunch == false && storage.fechaInBoxData(fechaSelect)) {
      Response? response = await openDialog(
        Alert.archived,
        fechaDuple: fechaSelect,
      );
      /*if (response == Response.cancel || response == null) {
        return;
      } else if (response == Response.go)*/
      if (response == Response.cancel || response == null) {
        return;
      } else if (response == Response.go) {
        setState(() {
          boxDataSelect = storage.getBoxData(fechaSelect!);
        });
        loadBoxData();
        return;
      }
    } else if (isFirstLaunch == true && storage.fechaInBoxData(fechaSelect)) {
      return;
    }

    /// CONSULTA DE DATOS
    setState(() => httpStatus = HttpStatus.api);
    RequestRee requestRee = RequestRee();
    var fechaRequest = DateFormat('yyyy-MM-dd').format(fechaSelect);
    var preciosHora = await requestRee.datePVPC(fechaRequest);

    if (requestRee.status != Status.ok || preciosHora.isEmpty) {
      //setState(() => httpStatus = HttpStatus.completed);
      if (!context.mounted) return;
      if (!mounted) return;
      CheckStatusError(requestRee.status, context).showError();
    } else {
      /// CONSULTA DATOS GENERACION
      setState(() => httpStatus = HttpStatus.generacion);
      //await httpRequestApi.getDatosGeneracion(httpRequestApi.fecha);
      // print(httpRequestApi.fecha); 2023-07-18
      var generacion = await requestRee.dataBalance(fecha1: fechaRequest);
      Map<String, double> mapRenovables = {};
      Map<String, double> mapNoRenovables = {};
      for (var gen in generacion) {
        if (gen.fecha != fechaSelect) {
          continue;
        }
        for (var balance in gen.balances) {
          if (balance.renovable) {
            mapRenovables[balance.name] = balance.generacion;
          } else {
            mapNoRenovables[balance.name] = balance.generacion;
          }
        }
      }

      /// ALMACENA LOS DATOS OBTENIDOS
      storage.saveBoxData(
        BoxData(
          fecha: fechaSelect,
          preciosHora: preciosHora,
          mapRenovables: mapRenovables,
          mapNoRenovables: mapNoRenovables,
        ),
      );
      setState(() {
        boxDataSelect = storage.getBoxData(fechaSelect!);
      });
      if (sharedPrefs.maxArchivo != 0) {
        while (storage.listBoxData.length > sharedPrefs.maxArchivo) {
          storage.deleteFirst();
        }
      }
      loadBoxData();
    }
  }

  /// CONSULTA NUEVOS DATOS A PARTIR DE DOS FECHAS
  void httpBoxDatas(DateTime fechaSelect1, DateTime fechaSelect2) async {
    setState(() => httpStatus = HttpStatus.api);

    //fechaSelect2 ??= fechaSelect1;
    //print(fechaSelect1); 2025-07-14 00:00:00.000
    //print(fechaSelect2); 2025-07-17 00:00:00.000

    RequestRee requestRee = RequestRee();
    var fechaRequest1 = DateFormat('yyyy-MM-dd').format(fechaSelect1);
    var fechaRequest2 = DateFormat('yyyy-MM-dd').format(fechaSelect2);

    /// DESCARGA ARCHIVO
    var download = await requestRee.rangePVPCDownload(
      fechaRequest1,
      fechaRequest2,
    );
    if (download.statusCode != 200) {
      showSnackBar('Error en la descarga de los precios PVPC.');
      setState(() => httpStatus = HttpStatus.stopped);
      return;
    }

    /// EXTRAE ARCHIVOS DESCARGADOS
    if (fechaSelect1 != fechaSelect2) {
      final String fileName = '$fechaRequest1-$fechaRequest2.zip';
      var extractZipOk = await FileUtil.extractZipPVPC(fileName);
      if (extractZipOk == false) {
        showSnackBar('Error en la extracción de datos de los precios PVPC.');
        return;
      }
    }
    var archivos = await FileUtil.getFilesPVPC();
    if (archivos.isEmpty) {
      showSnackBar('Error en la recuperación de los archivos de precios PVPC.');
      setState(() => httpStatus = HttpStatus.stopped);
      return;
    }

    /// ANALIZA ARCHIVOS DESCARGADOS
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

    /// ALMACENA LOS DATOS OBTENIDOS
    mapDatePrecios.forEach((k, v) {
      storage.saveBoxData(BoxData(fecha: k, preciosHora: v));
    });
    List<DateTime> listaFechas = mapDatePrecios.keys.toList();
    listaFechas.sort((a, b) => a.compareTo(b));
    setState(() {
      boxDataSelect = storage.getBoxData(listaFechas.first);
    });
    loadBoxData();
  }

  void showSnackBar(String msg) {
    //ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snackbar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  bool get isLastFecha {
    setState(() => listBoxData = storage.listBoxDataSort);
    int currentIndex = listBoxData.indexWhere(
      (e) => e.fecha == boxDataSelect?.fecha,
    );
    return currentIndex == 0;
  }

  bool get isFirstFecha {
    setState(() => listBoxData = storage.listBoxDataSort);
    int currentIndex = listBoxData.indexWhere(
      (e) => e.fecha == boxDataSelect?.fecha,
    );
    return (currentIndex == listBoxData.length - 1);
  }

  void scrollPositionMin() {
    if (scrollController.position.pixels ==
        scrollController.position.minScrollExtent) {
      return;
    }
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void nextBoxData() {
    scrollPositionMin();
    setState(() => listBoxData = storage.listBoxDataSort);
    int currentIndex = listBoxData.indexWhere(
      (e) => e.fecha == boxDataSelect?.fecha,
    );
    if (currentIndex < listBoxData.length - 1) {
      BoxData nextBoxData = listBoxData[currentIndex + 1];
      setState(() => boxDataSelect = nextBoxData);
      loadBoxData();
    }
  }

  void prevBoxData() {
    scrollPositionMin();
    setState(() => listBoxData = storage.listBoxDataSort);
    int currentIndex = listBoxData.indexWhere(
      (e) => e.fecha == boxDataSelect?.fecha,
    );
    if (currentIndex > 0) {
      BoxData prevBoxData = listBoxData[currentIndex - 1];
      setState(() => boxDataSelect = prevBoxData);
      loadBoxData();
    }
  }

  /// SELECTOR DE UNA FECHA
  Future<void> selectDate() async {
    final DateTime hoy = DateTime.now().toLocal();
    DateTime manana = DateTime(hoy.year, hoy.month, hoy.day + 1);
    DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2021, 6),
      lastDate: manana,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      //bool dataNotYet = picked.difference(hoy).inDays > 1;
      if (picked == manana && hoy.hour < 20) {
        if (await openDialog(Alert.notyet) == Response.ok) {
          httpBoxData(picked);
          //httpBoxDatas(picked, picked);
        }
      } else {
        httpBoxData(picked);
        //httpBoxDatas(picked, picked);
      }
    }
  }

  /// SELECTOR DE DOS FECHAS
  Future<void> selectDates() async {
    final DateTime hoy = DateTime.now().toLocal();
    DateTimeRange? newRange = await showDateRangePicker(
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
    if (newRange != null) {
      //DateTime start = FechaUtil.dateToDateHms(newRange.start);
      //DateTime end = FechaUtil.dateToDateHms(newRange.end);
      newRange = DateTimeRange(start: newRange.start, end: newRange.end);
      //print(newRange); 2025-04-07 00:00:00.000 - 2025-04-12 00:00:00.000
      httpBoxDatas(newRange.start, newRange.end);
    }
  }

  Future<Response>? openDialog(Alert alert, {DateTime? fechaDuple}) async {
    String title = 'Fecha en Archivo';
    String fechaString = fechaDuple != null
        ? DateFormat('d MMM yy').format(fechaDuple)
        : 'ese día';
    String content =
        'Los datos de $fechaString ya han sido consultados y están archivados. '
        'Puedes verlos en el histórico de consultas.\n'
        'Continuar con la consulta sobreescribe los datos almacenados.';
    if (alert == Alert.notyet) {
      title = 'No publicado';
      content =
          'En torno a las 20:15h de cada día, la REE publica los precios '
          'de la electricidad que se aplicarán al día siguiente, por lo que '
          'es posible que los datos todavía no estén publicados.';
    }
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(Response.cancel),
            ),
            if (alert == Alert.archived)
              TextButton(
                onPressed: () => Navigator.pop(context, Response.go),
                child: const Text('Ver'),
              ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(Response.ok),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BoxData? newBoxData;
    if (boxDataSelect != null) {
      setState(() {
        listBoxData = storage.listBoxDataSort;
        newBoxData = boxDataSelect!.copyWith(
          fecha: boxDataSelect!.fecha,
          preciosHora: boxDataSelect!.preciosHora,
          mapRenovables: boxDataSelect!.mapRenovables,
          mapNoRenovables: boxDataSelect!.mapNoRenovables,
        );
      });
    }
    Widget mainBody = MainBodyEmpty();
    if (httpStatus == HttpStatus.started ||
        httpStatus == HttpStatus.api ||
        httpStatus == HttpStatus.file ||
        httpStatus == HttpStatus.generacion) {
      mainBody = MainBodyStarted(stringProgress: httpStatus.textProgress);
    } else if (httpStatus == HttpStatus.completed &&
        listBoxData.isNotEmpty &&
        newBoxData != null
    //&& newBoxData!.preciosHora.isNotEmpty
    ) {
      mainBody = SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const ClampingScrollPhysics(),
          controller: scrollController,
          child: switch (currentTab) {
            0 => HomeTab(boxData: newBoxData!),
            1 => PreciosTab(tab: currentTab, boxData: newBoxData!),
            2 => PreciosTab(tab: currentTab, boxData: newBoxData!),
            3 => TimelapseTab(boxData: newBoxData!),
            int() => HomeTab(boxData: newBoxData!),
          },
        ),
      );
    }
    Widget? floatingActionButton() {
      if (currentTab == 0) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () {
                setState(() => isFirstLaunch = false);
                httpBoxData();
              },
              child: const Icon(Icons.update, size: 28),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GraficoPrecios(boxData: newBoxData!),
                  ),
                );
              },
              child: const Icon(Icons.bar_chart, size: 28),
            ),
          ],
        );
      }
      if (currentTab == 1 || currentTab == 2) {
        return FloatingActionButton.small(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GraficoPrecios(boxData: newBoxData!),
              ),
            );
          },
          child: const Icon(Icons.bar_chart, size: 28),
        );
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Open Luz',
          style: TextStyle(color: StyleApp.accentColor),
        ),
        actions: [
          IconButton(
            onPressed: (listBoxData.length > 1 && !isFirstFecha)
                ? nextBoxData
                : null,
            icon: const Icon(Icons.skip_previous),
          ),
          IconButton(
            onPressed: (listBoxData.length > 1 && !isLastFecha)
                ? prevBoxData
                : null,
            icon: const Icon(Icons.skip_next),
          ),
          IconButton(onPressed: selectDate, icon: const Icon(Icons.today)),
          IconButton(
            onPressed: selectDates,
            icon: const Icon(Icons.date_range),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: ((int item) {
              switch (item) {
                case 0:
                  showSnackBar(
                    'Los datos del día ${newBoxData!.fechaddMMyy} han sido eliminados',
                  );
                  setState(() {
                    listBoxData.remove(newBoxData);
                    listBoxData = storage.listBoxDataSort;
                    storage.deleteBoxData(newBoxData!);
                  });
                  resetHomeScreen();
                  initApp();
                  loadBoxData();
                case != 0:
                  break;
              }
            }),
            itemBuilder: (context) => const [
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 2),
                  dense: true,
                  leading: Icon(Icons.delete),
                  title: Text('Eliminar'),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),

      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          decoration: StyleApp.mainDecoration,
          child: mainBody,
        ),
      ),
      floatingActionButton: floatingActionButton(),
      bottomNavigationBar:
          // storage.listBoxData.isNotEmpty
          (listBoxData.isNotEmpty && httpStatus == HttpStatus.completed)
          ? BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.lightbulb_outline),
                  activeIcon: Icon(Icons.upgrade),
                  label: 'PVPC',
                  //backgroundColor: Colors.amber,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.euro_symbol),
                  activeIcon: Icon(Icons.upgrade),
                  label: 'PRECIO',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.access_time),
                  activeIcon: Icon(Icons.upgrade),
                  label: 'HORAS',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timelapse),
                  activeIcon: Icon(Icons.upgrade),
                  label: 'FRANJAS',
                ),
              ],
              currentIndex: currentTab,
              onTap: (int index) {
                /*scrollController.animateTo(
                      scrollController.position.minScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                    );*/
                scrollPositionMin();
                if (currentTab != index) {
                  setState(() => currentTab = index);
                }
              },
            )
          : null,
    );
  }
}
