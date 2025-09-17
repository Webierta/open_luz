import 'package:flutter/material.dart';

import '../../../../../database/box_data.dart';
import '../../../../../theme/style_app.dart';
import 'evolution_chart.dart';

class HomeTabEvolution extends StatelessWidget {
  final BoxData boxData;
  const HomeTabEvolution({super.key, required this.boxData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Row(
            children: [
              Text(
                '📈 Evolución diaria del precio',
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
        EvolutionChart(boxData: boxData),
      ],
    );
  }
}
