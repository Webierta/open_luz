import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';

import '../../../theme/style_app.dart';
import '../../../utils/constantes.dart';
import '../../../utils/launch_url.dart';
import 'nav_destinations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
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
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/ic_launcher.png'),
              ),
              currentAccountPictureSize: Size.square(60),
              accountName: Text(
                'Open Luz',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w100,
                  color: StyleApp.accentColor,
                ),
              ),
              accountEmail: Badge(
                label: Text(kVersion),
                backgroundColor: StyleApp.backgroundColor,
                textColor: Colors.white,
              ),
              otherAccountsPicturesSize: Size.square(30),
              otherAccountsPictures: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () => LaunchUrl.init(context, url: kGitHub),
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/images/logo-github.svg',
                      semanticsLabel: 'GitHub Logo',
                      colorFilter: const ColorFilter.mode(
                        StyleApp.backgroundColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: StyleApp.backgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    border: Border.all(color: Colors.white, width: 2.0),
                  ),
                  child: IconButton(
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(text: 'Prueba Open Luz App: $kGitHub'),
                      );
                    },
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.share, color: Colors.white, size: 20),
                  ),
                  //child: Icon(Icons.share),
                ),
              ],
            ),
            ...[...NavHelper.buildListNav(context, destinos: navMain)],
            const DividerDrawer(),
            ...[...NavHelper.buildListNav(context, destinos: navTools)],
            const DividerDrawer(),
            ...[...NavHelper.buildListNav(context, destinos: navHelp)],
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
      color: Theme.of(context).colorScheme.onSurface,
      thickness: 0.4,
      indent: 20,
      endIndent: 20,
    );
  }
}
