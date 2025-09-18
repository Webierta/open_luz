import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../widgets/fuente_ree.dart';
import '../widgets_balance/home_tab_generacion.dart';
import '../widgets_clock/home_tab_reloj.dart';
import '../widgets_evolution_chart/home_tab_evolution.dart';
import '../widgets_head/home_tab_head.dart';
import '../widgets_head/rango_precios.dart';
import '../widgets_horas/home_tab_horas.dart';

class DesktopLayout extends StatelessWidget {
  final BoxConstraints parentConstraints;
  final BoxData boxData;
  const DesktopLayout({
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
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: HomeTabHead(boxData: boxData)),
                      RangoPrecios(boxData: boxData),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 10, child: HomeTabReloj(boxData: boxData)),
                      Spacer(flex: 1),
                      Expanded(
                        flex: 10,
                        child: HomeTabHoras(
                          boxData: boxData,
                          isMobileLayout: false,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                HomeTabEvolution(boxData: boxData),

                const SizedBox(height: 20),
                HomeTabGeneracion(boxData: boxData),
                const SizedBox(height: 20),
                const FuenteREE(),
              ],
            ),
          ),
        );
      },
    );
  }
}
