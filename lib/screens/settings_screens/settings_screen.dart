import 'package:flutter/material.dart';

import '../../theme/style_app.dart';
import '../../utils/shared_prefs.dart';
import '../nav/pop_scope_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final controllerToken = TextEditingController();
  final SharedPrefs sharedPrefs = SharedPrefs();
  bool autoGetData = true;
  //bool autoSave = true;
  int maxArchivo = 0;
  String maxArchivoText = 'Sin límite';
  bool storageComparador = false;

  @override
  void initState() {
    loadSharedPrefs();
    super.initState();
  }

  void loadSharedPrefs() async {
    await sharedPrefs.init();
    setState(() {
      autoGetData = sharedPrefs.autoGetData;
      //autoSave = sharedPrefs.autoSave;
      maxArchivo = sharedPrefs.maxArchivo;
      maxArchivoText = getMaxArchivoText(maxArchivo);
      storageComparador = sharedPrefs.storageComparador;
    });
  }

  void setAutoGetData(bool value) {
    setState(() => autoGetData = value);
    sharedPrefs.autoGetData = value;
  }

  void setMaxArchivo(int value) {
    setState(() {
      maxArchivo = value;
      maxArchivoText = getMaxArchivoText(maxArchivo);
    });
    if (value != 0) {
      setStorageComparador(false);
    }
    sharedPrefs.maxArchivo = value;
  }

  String getMaxArchivoText(int max) {
    return switch (max) {
      0 => 'Sin límite',
      7 => '7 fechas',
      30 => '30 fechas',
      _ => 'Sin límite',
    };
  }

  void setStorageComparador(bool value) {
    setState(() => storageComparador = value);
    sharedPrefs.storageComparador = value;
  }

  /* void setAutoSave(bool value) {
    setState(() => autoSave = value);
    sharedPrefs.autoSave = value;
  } */

  /* final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  ); */

  final WidgetStateProperty<Icon?> thumbIcon =
      WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.check);
        }
        return const Icon(Icons.close);
      });

  @override
  void dispose() {
    controllerToken.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: PopScopeHelper.onPopInvoked(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ajustes')),
        body: SafeArea(
          child: Container(
            decoration: StyleApp.mainDecoration,
            padding: const EdgeInsets.all(20),
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    horizontalTitleGap: 8,
                    isThreeLine: true,
                    title: const Text('Sincronización automática'),
                    subtitle: const Text(
                      'Al abrir la aplicación se consultan los últimos datos disponibles',
                    ),
                    trailing: Switch(
                      thumbIcon: thumbIcon,
                      value: autoGetData,
                      onChanged: (bool value) {
                        setAutoGetData(value);
                      },
                    ),
                  ),
                  const Divider(height: 40, color: StyleApp.onBackgroundColor),
                  ListTile(
                    isThreeLine: true,
                    title: const Text('Límite en archivo'),
                    subtitle: const Text(
                      'Autoelimina los datos más antiguos. Si el archivo alcanza este límite, '
                      'las consultas de fechas previas no quedan almacenadas',
                    ),
                    trailing: PopupMenuButton<int>(
                      initialValue: maxArchivo,
                      icon: Text(
                        maxArchivoText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onSelected: (int value) {
                        setMaxArchivo(value);
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text('Sin límite'),
                        ),
                        const PopupMenuItem<int>(
                          value: 7,
                          child: Text('7 fechas'),
                        ),
                        const PopupMenuItem<int>(
                          value: 30,
                          child: Text('30 fechas'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 40, color: StyleApp.onBackgroundColor),
                  ListTile(
                    horizontalTitleGap: 8,
                    isThreeLine: true,
                    title: const Text('Guardar precios del Comparador'),
                    subtitle: const Text(
                      'Guarda los precios descargados para calcular la factura. '
                      'Requiere ajustar Límite en archivo a Sin límite. '
                      'Si los precios ya existen, no sobreescribe los datos previos. '
                      'No incluyen datos sobre el Balance de Generación',
                    ),
                    trailing: Switch(
                      thumbIcon: thumbIcon,
                      value: storageComparador,
                      onChanged: (bool value) {
                        setStorageComparador(value);
                        if (value) {
                          setMaxArchivo(0);
                        }
                      },
                    ),
                  ),
                  /* ListTile(
                      horizontalTitleGap: 8,
                      title: const Text('Guardado automático'),
                      subtitle: const Text(
                          'Archiva los datos en la página Histórico'),
                      trailing: Switch(
                        thumbIcon: thumbIcon,
                        value: autoSave,
                        onChanged: (bool value) {
                          setAutoSave(value);
                        },
                      ),
                    ), */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
