import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'database/box_data.dart';
import 'screens/home_screen/home_screen.dart';
import 'theme/theme_app.dart';
import 'utils/constantes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BoxDataAdapter());
  await Hive.openBox<BoxData>(boxStore);
  runApp(const OpenLuz());
}

class OpenLuz extends StatelessWidget {
  const OpenLuz({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Open Luz',
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es', 'ES')],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ThemeApp.colorScheme,
        textTheme: ThemeApp.textTheme,
        floatingActionButtonTheme: ThemeApp.floatingActionButtonTheme,
        dialogTheme: ThemeApp.dialogThemeData,
        bottomNavigationBarTheme: ThemeApp.bottomNavigationBarTheme,
      ),
      home: const HomeScreen(isFirstLaunch: true),
    );
  }
}
