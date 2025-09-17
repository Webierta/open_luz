import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../widgets/fuente_ree.dart';
import '../widgets_balance/home_tab_generacion.dart';
import '../widgets_clock/home_tab_reloj.dart';
import '../widgets_evolution_chart/home_tab_evolution.dart';
import '../widgets_head/home_tab_head.dart';
import '../widgets_horas/home_tab_horas.dart';

class MobileLayout extends StatelessWidget {
  final BoxConstraints parentConstraints;
  final BoxData boxData;
  const MobileLayout({
    super.key,
    required this.boxData,
    required this.parentConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          //height: constraints.maxHeight,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                HomeTabHead(boxData: boxData),
                const SizedBox(height: 20),
                HomeTabReloj(boxData: boxData),
                const SizedBox(height: 20),
                HomeTabEvolution(boxData: boxData),
                const SizedBox(height: 20),
                HomeTabHoras(boxData: boxData),
                const SizedBox(height: 20),
                HomeTabGeneracion(boxData: boxData),
                //SizedBox(height: parentConstraints.maxHeight / 20),
                const FuenteREE(),
              ],
            ),
          ),
        );
      },
    );
  }
}
