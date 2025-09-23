import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../widgets/fuente_ree.dart';
import '../widgets_balance/home_tab_generacion.dart';
import '../widgets_clock/home_tab_reloj.dart';
import '../widgets_evolution_chart/home_tab_evolution.dart';
import '../widgets_head/home_tab_head.dart';
import '../widgets_head/rango_precios.dart';
import '../widgets_horas/home_tab_horas.dart';
import 'layout.dart';

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
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: HomeTabHead(boxData: boxData)),
                      if (constraints.maxWidth > 450) ...[
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: RangoPrecios(boxData: boxData),
                        ),
                      ],
                    ],
                  ),
                ),*/
                //const SizedBox(height: 20),
                /*if (constraints.maxWidth < 450) ...[
                  SizedBox(
                    height: 250,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: RangoPrecios(boxData: boxData),
                        ),
                      ],
                    ),
                  ),
                ],*/
                IntrinsicHeight(
                  child: Row(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 4, child: HomeTabHead(boxData: boxData)),
                      RangoPrecios(boxData: boxData),
                    ],
                  ),
                ),
                /*SizedBox(
                  width: double.maxFinite,
                  child: Wrap(
                    //direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceBetween,
                    //runAlignment: WrapAlignment.end,
                    //crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 10.0,
                    runSpacing: 20.0,
                    children: [
                      SizedBox(
                        width: 300,
                        height: 350,
                        child: HomeTabHead(boxData: boxData),
                      ),
                      SizedBox(
                        width: 100,
                        height: 350,
                        child: RangoPrecios(boxData: boxData),
                      ),
                    ],
                  ),
                ),*/
                const SizedBox(height: 20),
                HomeTabReloj(boxData: boxData, layout: Layout.MobileLayout),
                const SizedBox(height: 20),
                HomeTabEvolution(boxData: boxData),
                const SizedBox(height: 20),
                HomeTabHoras(boxData: boxData, layout: Layout.MobileLayout),
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
