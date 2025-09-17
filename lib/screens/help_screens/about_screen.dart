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
                const Icon(Icons.code, size: 60),
                Text(
                  'Versión $kVersion', // VERSION
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Copyleft 2020-2025\nJesús Cuerda (Webierta)',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const FittedBox(
                  child: Text('All Wrongs Reserved. Licencia GPLv3'),
                ),
                //Divider(color: Theme.of(context).colorScheme.onBackground),
                Divider(color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(height: 10.0),
                const ReadFile(archivo: 'assets/files/about.txt'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
