import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../../../../../theme/style_app.dart';
import '../../../../../utils/estados.dart';
import 'generacion_balance.dart';
import 'generacion_error.dart';

class HomeTabGeneracion extends StatelessWidget {
  final BoxData boxData;
  const HomeTabGeneracion({super.key, required this.boxData});

  double get total {
    return (boxData.generacion[Generacion.renovable.texto] ?? 0) +
        (boxData.generacion[Generacion.noRenovable.texto] ?? 0);
  }

  Map<String, double> sortedMap(Map<String, double> mapDataGeneracion) {
    var mapGeneracion = <String, double>{};
    mapGeneracion = Map.from(mapDataGeneracion);
    return Map.fromEntries(
      mapGeneracion.entries.toList()
        ..sort((e1, e2) => (e2.value).compareTo((e1.value))),
    );
  }

  String calcularPorcentaje(double valor) {
    return ((valor * 100) / total).toStringAsFixed(1);
  }

  double valueLinearProgress(String typo) {
    var g = typo == 'Generación renovable'
        ? sortedMap(boxData.mapRenovables!)
        : sortedMap(boxData.mapNoRenovables!);
    return (double.tryParse(calcularPorcentaje(g[typo] ?? 100)) ?? 100) / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Row(
            children: [
              Text(
                '⚡ Balance Generación',
                style: TextStyle(
                  color: StyleApp.onBackgroundColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ClipPath(
          clipper: StyleApp.kBorderClipper,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            width: double.infinity,
            decoration: StyleApp.kBoxDeco,
            child:
                (boxData.mapRenovables == null ||
                    boxData.mapNoRenovables == null ||
                    (boxData.mapRenovables?.isEmpty ?? true) ||
                    (boxData.mapRenovables?.isEmpty ?? true) ||
                    (!boxData.generacion.containsKey(
                      Generacion.renovable.texto,
                    )) ||
                    !boxData.generacion.containsKey(
                      Generacion.noRenovable.texto,
                    ))
                ? const GeneracionError()
                : Column(
                    children: [
                      GeneracionBalance(
                        sortedMap: sortedMap(boxData.mapRenovables!),
                        generacion: Generacion.renovable,
                        total: total,
                      ),
                      LinearProgressIndicator(
                        value: valueLinearProgress(Generacion.renovable.texto),
                        backgroundColor: Colors.grey,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20),
                      GeneracionBalance(
                        sortedMap: sortedMap(boxData.mapNoRenovables!),
                        generacion: Generacion.noRenovable,
                        total: total,
                      ),
                      LinearProgressIndicator(
                        value: valueLinearProgress(
                          Generacion.noRenovable.texto,
                        ),
                        backgroundColor: Colors.grey,
                        color: Colors.red,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            DateTime.now().difference(boxData.fecha).inDays >= 1
                                ? 'Datos programados'
                                : 'Datos previstos',
                            style: TextStyle(
                              color:
                                  //StyleApp.onBackgroundColor.withOpacity(0.8),
                                  StyleApp.onBackgroundColor.withAlpha(180),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
