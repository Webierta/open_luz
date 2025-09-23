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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Rango de precios',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.white),
          ),
        ),
        //Text('mín., medio y max.'),
        Expanded(child: IndicadorPrecios(boxData: boxData)),
      ],
    );
  }
}
