import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../widgets/fuente_ree.dart';
import '../widgets_balance/home_tab_generacion.dart';
import '../widgets_clock/home_tab_reloj.dart';
import '../widgets_evolution_chart/home_tab_evolution.dart';
import '../widgets_head/home_tab_head.dart';
import '../widgets_head/indicador_precios.dart';
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
          //height: constraints.maxHeight,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: HomeTabHead(
                          boxData: boxData,
                          isDesktopLayout: true,
                        ),
                      ),

                      //SizedBox(width: 40),
                      //const Spacer(flex: 1),
                      Column(
                        //crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rango de precios',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(color: Colors.white),
                          ),
                          Expanded(child: IndicadorPrecios(boxData: boxData)),
                        ],
                      ),
                      Expanded(flex: 2, child: HomeTabReloj(boxData: boxData)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                HomeTabHoras(boxData: boxData),
                const SizedBox(height: 20),
                HomeTabEvolution(boxData: boxData),
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
