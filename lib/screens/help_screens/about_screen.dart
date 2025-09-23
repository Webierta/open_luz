import 'package:flutter/material.dart';

import '../../theme/style_app.dart';
import '../../utils/constantes.dart';
import '../../utils/read_file.dart';
import 'widgets/head_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: SafeArea(
        child: Container(
          decoration: StyleApp.mainDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: <Widget>[
                const HeadScreen(),
                Divider(color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(height: 10.0),
                const ReadFile(archivo: 'assets/files/about.txt'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => Container(
                          decoration: StyleApp.kBoxDeco,
                          child: Theme(
                            data: ThemeData(
                              brightness: Brightness.dark,
                              scaffoldBackgroundColor: Colors.blueGrey[600],
                              appBarTheme: AppBarThemeData(
                                backgroundColor: Colors.blueGrey[600],
                              ),
                              cardColor: Colors.blueGrey[600],
                              dividerTheme: DividerThemeData(
                                color: Colors.white,
                              ),
                              textTheme: TextTheme(
                                headlineSmall: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  color: StyleApp.accentColor,
                                  fontSize: 40,
                                ),
                              ),
                            ),
                            child: Container(
                              decoration: StyleApp.kBoxDeco,
                              child: LicensePage(
                                applicationIcon: Image.asset(
                                  'assets/images/ic_launcher.png',
                                ),
                                applicationName: 'Open Luz',
                                applicationVersion: kVersion,
                                applicationLegalese:
                                    'Copyleft 2020-2025\nJesús Cuerda (Webierta).\nAll Wrongs Reserved.\nLicencia GPLv3.',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text('Ver Licencias'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
