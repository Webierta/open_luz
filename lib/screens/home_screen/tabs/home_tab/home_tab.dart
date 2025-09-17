import 'package:flutter/material.dart';

import '../../../../database/box_data.dart';
import 'layouts/desktop_layout.dart';
import 'layouts/mobile_layout.dart';
import 'layouts/tablet_layout.dart';

class HomeTab extends StatelessWidget {
  final BoxData boxData;
  const HomeTab({super.key, required this.boxData});

  @override
  Widget build(BuildContext context) {
    //final double altoScreen = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return DesktopLayout(
            parentConstraints: constraints,
            boxData: boxData,
          );
        } else if (constraints.maxWidth >= 600) {
          return TabletLayout(parentConstraints: constraints, boxData: boxData);
        } else {
          return MobileLayout(parentConstraints: constraints, boxData: boxData);
        }
        /*return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            children: [
              HomeTabHead(boxData: boxData),
              const SizedBox(height: 20),
              HomeTabReloj(boxData: boxData),
              const SizedBox(height: 20),
              SizedBox(height: 20),
              HomeTabHoras(boxData: boxData),
              SizedBox(height: 20),
              HomeTabGeneracion(boxData: boxData),
              SizedBox(height: altoScreen / 20),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    Divider(color: StyleApp.onBackgroundColor.withAlpha(50)),
                    Text(
                      'Fuente: REE (e·sios y REData)',
                      style: TextStyle(
                        color: StyleApp.onBackgroundColor.withAlpha(100),
                      ),
                    ),
                    Divider(color: StyleApp.onBackgroundColor.withAlpha(50)),
                  ],
                ),
              ),
            ],
          ),
        );*/
      },
    );
  }
}
