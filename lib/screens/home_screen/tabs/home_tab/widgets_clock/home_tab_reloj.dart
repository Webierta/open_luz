import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../../../../../theme/style_app.dart';
import 'indicador_horas.dart';

class HomeTabReloj extends StatelessWidget {
  final BoxData boxData;
  const HomeTabReloj({super.key, required this.boxData});

  @override
  Widget build(BuildContext context) {
    final double altoScreen = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Row(
            children: [
              Text(
                '🕒 Horas y Periodos',
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

        /*Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: altoScreen / 1.4),
            //constraints: BoxConstraints(maxWidth: anchoScreen),
            child: AspectRatio(
              aspectRatio: 5 / 4,
              child: IndicadorHoras(boxData: boxData),
            ),
          ),
        ),*/
        Align(
          alignment: Alignment.centerLeft,
          child: AspectRatio(
            aspectRatio: 5 / 4, //5 / 4, //5 / 4,
            child: IndicadorHoras(boxData: boxData),
          ),
        ),
      ],
    );
  }
}
