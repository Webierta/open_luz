import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../../../../../theme/style_app.dart';
import '../layouts/layout.dart';
import 'indicador_horas.dart';

class HomeTabReloj extends StatelessWidget {
  final BoxData boxData;
  final Layout layout;
  const HomeTabReloj({
    super.key,
    required this.boxData,
    this.layout = Layout.MobileLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Align(
            alignment: Alignment.topLeft,
            child: FittedBox(
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
          ),
        ),
        const SizedBox(height: 4),
        /*Align(
          alignment: Alignment.centerLeft,
          child: AspectRatio(
            aspectRatio: 5 / 4, // 5 / 4,
            child: IndicadorHoras(boxData: boxData),
          ),
        ),*/
        AspectRatio(
          aspectRatio: switch (layout) {
            Layout.DesktopLayout => 1.3,
            Layout.TabletLayout => 0.9,
            Layout.MobileLayout => 1.25,
          },
          child: IndicadorHoras(boxData: boxData),
        ),
      ],
    );
  }
}
