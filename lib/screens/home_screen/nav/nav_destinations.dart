import 'package:flutter/material.dart';

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

enum NavDestinations {
  inicio(texto: 'Inicio', icon: Icons.home, destino: HomeScreen()),
  archivo(texto: 'Archivo', icon: Icons.storage, destino: StorageScreen()),
  ajustes(texto: 'Ajustes', icon: Icons.settings, destino: SettingsScreen()),
  comparador(
    texto: 'Comparador',
    icon: Icons.difference,
    destino: Comparador(),
  ),
  etiqueta(
    texto: 'Eqiqueta energética',
    icon: Icons.beenhere_outlined,
    destino: LabelScreen(),
  ),
  bono(
    texto: 'Bono social',
    icon: Icons.savings_outlined,
    destino: BonoSocial(),
  ),
  info(texto: 'Info', icon: Icons.info_outline, destino: InfoScreen()),
  iconografia(
    texto: 'Iconografía',
    icon: Icons.emoji_symbols,
    destino: IconografiaScreen(),
  ),
  about(texto: 'About', icon: Icons.code, destino: AboutScreen()),
  donar(
    texto: 'Donar',
    icon: Icons.local_cafe_outlined,
    destino: DonateScreen(),
  );

  final String texto;
  final IconData icon;
  final Widget destino;
  const NavDestinations({
    required this.texto,
    required this.icon,
    required this.destino,
  });
}

const List<NavDestinations> navMain = [
  NavDestinations.inicio,
  NavDestinations.archivo,
  NavDestinations.ajustes,
];

const List<NavDestinations> navTools = [
  NavDestinations.comparador,
  NavDestinations.etiqueta,
  NavDestinations.bono,
];

const List<NavDestinations> navHelp = [
  NavDestinations.info,
  NavDestinations.iconografia,
  NavDestinations.about,
  NavDestinations.donar,
];

class NavHelper {
  static List<ListTile> buildListNav(
    BuildContext context, {
    required List<NavDestinations> destinos,
  }) {
    return List.generate(destinos.length, (index) {
      var destino = destinos[index];
      return ListTile(
        leading: Icon(destino.icon),
        title: Text(destino.texto),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destino.destino),
          );
        },
      );
    });
  }

  static List<NavigationRailDestination> buildDestinations(
    BuildContext context, {
    required List<NavDestinations> destinos,
  }) {
    return List.generate(destinos.length, (index) {
      var destino = destinos[index];
      return NavigationRailDestination(
        icon: Icon(destino.icon),
        label: Text(destino.texto),
      );
    });
  }
}
