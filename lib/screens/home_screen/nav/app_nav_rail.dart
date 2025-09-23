import 'package:flutter/material.dart';

import '../../../theme/style_app.dart';
import '../../../utils/constantes.dart';
import 'nav_destinations.dart';

enum NavRailDestinations {
  inicio(texto: 'Inicio', icon: Icons.home),
  util(texto: 'Útil', icon: Icons.build),
  info(texto: 'Info', icon: Icons.help_center_outlined);

  final String texto;
  final IconData icon;
  const NavRailDestinations({required this.texto, required this.icon});
}

class AppNavRail extends StatefulWidget {
  const AppNavRail({super.key});
  @override
  State<AppNavRail> createState() => _AppNavRailState();
}

class _AppNavRailState extends State<AppNavRail> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: NavigationRail(
              backgroundColor: StyleApp.backgroundColor,
              elevation: 12,
              labelType: NavigationRailLabelType.all,
              selectedLabelTextStyle: TextStyle(
                color: Colors.blue,
                fontSize: 30,
                letterSpacing: 1,
                decorationThickness: 2.5,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                letterSpacing: 0.8,
              ),
              selectedIconTheme: IconThemeData(color: Colors.blue),
              unselectedIconTheme: IconThemeData(color: Colors.grey),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
              leading: Column(
                children: [
                  Image.asset('assets/images/ic_launcher.png'),
                  Divider(),
                ],
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(),
                      Badge(
                        label: Text(kVersion),
                        backgroundColor: StyleApp.backgroundColor,
                        textColor: Colors.grey,
                        padding: const EdgeInsets.only(bottom: 4),
                      ),
                    ],
                  ),
                ),
              ),
              destinations: List.generate(NavRailDestinations.values.length, (
                index,
              ) {
                var nav = NavRailDestinations.values[index];
                return NavigationRailDestination(
                  icon: Icon(nav.icon),
                  label: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: RotatedBox(quarterTurns: -1, child: Text(nav.texto)),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            flex: 3,
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
              child: selectedMenu(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedMenu(int index) {
    switch (index) {
      case 0:
        return ListView(
          children: [...NavHelper.buildListNav(context, destinos: navMain)],
        );
      case 1:
        return ListView(
          children: [...NavHelper.buildListNav(context, destinos: navTools)],
        );
      case 2:
        return ListView(
          children: [...NavHelper.buildListNav(context, destinos: navHelp)],
        );
      default:
        return ListView(
          children: [...NavHelper.buildListNav(context, destinos: navMain)],
        );
    }
  }
}
