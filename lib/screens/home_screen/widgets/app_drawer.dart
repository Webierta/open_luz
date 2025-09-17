import 'package:flutter/material.dart';

import '../../../theme/style_app.dart';
import '../../../utils/constantes.dart';
import '../../help_screens/about_screen.dart';
import '../../help_screens/donate_screen.dart';
import '../../help_screens/iconografia_screen.dart';
import '../../help_screens/info_screen.dart';
import '../../settings_screens/settings_screen.dart';
import '../../settings_screens/storage_screen/storage_screen.dart';
import '../../tools_screens/bono_screen.dart';
import '../../tools_screens/comparador_screen/comparador_screen.dart';
import '../../tools_screens/eprel/label_screen.dart';
import '../home_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    /* Future<void> launchURL(String url) async {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not launch $url'),
        ));
      }
    } */
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.2, 0.5, 0.8, 0.7],
            colors: [
              StyleApp.primaryColorOpacity01,
              StyleApp.primaryColorOpacity05,
              StyleApp.primaryColorOpacity08,
              StyleApp.primaryColorOpacity07,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      /* image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/drawer3.png'),
                      ), */
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.7,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              'OPEN LUZ',
                              style: Theme.of(context).textTheme.headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w100,
                                    color: StyleApp.accentColor,
                                  ),
                            ),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.7,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              'TARIFA ELÉCTRICA REGULADA (PVPC)',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Copyleft 2020-2025',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w100),
                        ),
                        Text(
                          'Jesús Cuerda (Webierta)',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w100),
                        ),
                        Text(
                          'All Wrongs Reserved. Licencia GPLv3',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w100),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Inicio'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Archivo'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StorageScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Ajustes'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const DividerDrawer(),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Info'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.emoji_symbols),
                    title: const Text('Iconografía'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IconografiaScreen(),
                        ),
                      );
                    },
                  ),
                  const DividerDrawer(),
                  ListTile(
                    leading: const Icon(Icons.difference),
                    title: const Text('Comparador'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Comparador(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.beenhere_outlined),
                    title: const Text('Etiqueta energética'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LabelScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.savings_outlined),
                    title: const Text('Bono social'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BonoSocial(),
                        ),
                      );
                    },
                  ),
                  const DividerDrawer(),
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: const Text('About'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_cafe_outlined),
                    title: const Text('Donar'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DonateScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.surface.withAlpha(100),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
              child: Text(
                'Versión $kVersion',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  //color: Theme.of(context).colorScheme.background,
                  color: Theme.of(context).colorScheme.surface.withAlpha(100),
                ),
              ),
            ),
            /* InkWell(
              onTap: () {
                launchURL('https://lacorrientecoop.es/');
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                color: Colors.white,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: AssetImage('assets/images/logo_corriente.jpg'),
                    ),
                  ),
                  child: const Text(
                    'Patrocinador',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ), */
          ],
        ),
      ),
    );
  }
}

class DividerDrawer extends StatelessWidget {
  const DividerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      //color: Theme.of(context).colorScheme.onBackground,
      color: Theme.of(context).colorScheme.onSurface,
      thickness: 0.4,
      indent: 20,
      endIndent: 20,
    );
  }
}
