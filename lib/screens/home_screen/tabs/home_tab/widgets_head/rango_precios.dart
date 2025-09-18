import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import 'indicador_precios.dart';

class RangoPrecios extends StatelessWidget {
  final BoxData boxData;
  const RangoPrecios({super.key, required this.boxData});

  @override
  Widget build(BuildContext context) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Rango de precios',
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: Colors.white),
        ),
        Expanded(child: IndicadorPrecios(boxData: boxData)),
      ],
    );
  }
}
