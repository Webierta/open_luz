import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../../../../../models/tarifa.dart';
import '../../../../../theme/style_app.dart';
import '../../../../../utils/estados.dart';
import 'list_tile_fecha.dart';

class HomeTabHoras extends StatelessWidget {
  final BoxData boxData;
  final bool isMobileLayout;
  const HomeTabHoras({
    super.key,
    required this.boxData,
    this.isMobileLayout = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Row(
            children: [
              Text(
                '💲 Horas más barata y más cara',
                style: TextStyle(
                  color: StyleApp.onBackgroundColor,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        isMobileLayout
            ? ClipHoras(boxData: boxData)
            : AspectRatio(
                aspectRatio: 5 / 4,
                child: ClipHoras(boxData: boxData),
              ),
      ],
    );
  }
}

class ClipHoras extends StatelessWidget {
  final BoxData boxData;
  const ClipHoras({super.key, required this.boxData});

  Periodo get periodoMin {
    int hora = boxData.getHour(boxData.preciosHora, boxData.precioMin);
    DateTime f = boxData.fecha.copyWith(hour: hora);
    return Tarifa.getPeriodo(f);
  }

  Periodo get periodoMax {
    int hora = boxData.getHour(boxData.preciosHora, boxData.precioMax);
    DateTime f = boxData.fecha.copyWith(hour: hora);
    return Tarifa.getPeriodo(f);
  }

  /* String get horaPeriodoMin => boxData.getHora(
        boxData.preciosHora,
        boxData.precioMin,
      );

  String get horaPeriodoMax => boxData.getHora(
        boxData.preciosHora,
        boxData.precioMax,
      ); */

  double get desviacionMin => boxData.precioMin - boxData.precioMedio;
  double get desviacionMax => boxData.precioMax - boxData.precioMedio;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: StyleApp.kBorderClipper,
      child: Container(
        //padding: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.only(top: 10),
        width: double.infinity,
        decoration: StyleApp.kBoxDeco,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Diferencia: ${(boxData.precioMax - boxData.precioMin).toStringAsFixed(5)} €/kWh',
                style: const TextStyle(color: StyleApp.onBackgroundColor),
              ),
            ),
            Divider(
              //color: StyleApp.onBackgroundColor.withOpacity(0.5),
              color: StyleApp.onBackgroundColor.withAlpha(50),
              indent: 20,
              endIndent: 20,
            ),
            ListTileFecha(
              periodo: periodoMin,
              hora: boxData.horaPrecioMin, // horaPeriodoMin
              precio: boxData.precioMin.toStringAsFixed(5),
              desviacion: desviacionMin,
            ),
            Divider(
              //color: StyleApp.onBackgroundColor.withOpacity(0.5),
              color: StyleApp.onBackgroundColor.withAlpha(50),
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ListTileFecha(
                periodo: periodoMax,
                hora: boxData.horaPrecioMax, // horaPeriodoMax,
                precio: boxData.precioMax.toStringAsFixed(5),
                desviacion: desviacionMax,
              ),
            ),
            Divider(
              //color: StyleApp.onBackgroundColor.withOpacity(0.5),
              color: StyleApp.onBackgroundColor.withAlpha(50),
              indent: 20,
              endIndent: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                'Precio Medio: ${(boxData.precioMedio).toStringAsFixed(5)} €/kWh',
                style: const TextStyle(color: StyleApp.onBackgroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
