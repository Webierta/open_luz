import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../database/box_data.dart';
import '../../../../../models/tarifa.dart';
import '../../../../../theme/style_app.dart';

class EvolutionChart extends StatelessWidget {
  final BoxData boxData;
  const EvolutionChart({required this.boxData, super.key});

  double cuatroDec(double precio) {
    return double.parse((precio).toStringAsFixed(4));
  }

  double getMaxY() {
    return double.parse(
      (boxData.precioMax + (boxData.precioMax / 5)).toStringAsFixed(2),
    );
  }

  List<HorizontalLine> getExtraLinesY() {
    List<HorizontalLine> horizontalLines = [];
    for (double i = 0; i < boxData.precioMax + 0.05; i += 0.05) {
      horizontalLines.add(
        HorizontalLine(
          y: i,
          strokeWidth: 1,
          dashArray: [2, 2],
          color: Colors.white30,
        ),
      );
    }
    return horizontalLines;
  }

  @override
  Widget build(BuildContext context) {
    final double altoScreen = MediaQuery.of(context).size.height;
    final now = DateTime.now().toLocal();
    bool puntoRojo = DateFormat('dd/MM/yy').format(now) == boxData.fechaddMMyy;

    return ClipPath(
      clipper: StyleApp.kBorderClipper,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 30, 10, 0),
        width: double.infinity,
        height: altoScreen / 2.5,
        decoration: StyleApp.kBoxDeco,
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (value, meta) {
                    if (int.parse(meta.formattedValue).isEven) {
                      return Text(meta.formattedValue);
                    }
                    return const Text('');
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 0.05,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      //axisSide: meta.axisSide,
                      meta: meta,
                      child:
                          double.parse(
                                meta.formattedValue,
                              ).toStringAsFixed(2).endsWith('0') ||
                              double.parse(
                                meta.formattedValue,
                              ).toStringAsFixed(2).endsWith('5')
                          ? FittedBox(
                              child: Text(
                                meta.formattedValue.substring(0, 4),
                                style: const TextStyle(fontSize: 10),
                              ),
                            )
                          : const SizedBox(width: 0, height: 0),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: false,
              drawVerticalLine: true,
              getDrawingVerticalLine: (value) {
                return FlLine(
                  //color: Colors.grey.withOpacity(0.4),
                  color: Colors.grey.withAlpha(40),
                  strokeWidth: 0.8,
                  dashArray: [2, 2],
                );
              },
            ),
            extraLinesData: ExtraLinesData(
              //extraLinesOnTop: true,
              horizontalLines: [
                HorizontalLine(
                  y: boxData.precioMedio,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                  color: Colors.blue[100],
                  label: HorizontalLineLabel(
                    show: true,
                    padding: const EdgeInsets.only(left: 10, bottom: 4),
                    labelResolver: (_) =>
                        '${cuatroDec(boxData.precioMedio)}€/kWh',
                  ),
                ),
                ...getExtraLinesY(),
              ],
            ),
            minY: 0,
            maxY: getMaxY(),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                //tooltipBgColor: Colors.black54,
                getTooltipColor: ((touchedSpot) => Colors.black54),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    String horas =
                        '${touchedSpot.spotIndex}-${touchedSpot.spotIndex + 1} h';
                    double precio = boxData.preciosHora[touchedSpot.spotIndex];
                    return LineTooltipItem(
                      '$horas\n${cuatroDec(precio)}',
                      TextStyle(color: Tarifa.getColorBorder(precio)),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: boxData.preciosHora
                    .asMap()
                    .entries
                    .map(
                      (precio) => FlSpot(
                        precio.key.toDouble() + 1,
                        cuatroDec(precio.value),
                      ),
                    )
                    .toList(),
                isCurved: true,
                barWidth: 2,
                color: Colors.white,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (p0, p1, p2, p3) {
                    if (p3 == now.hour && puntoRojo) {
                      return FlDotCirclePainter(
                        color: Colors.red,
                        radius: 6,
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      );
                    }
                    return FlDotCirclePainter(
                      color: Colors.white,
                      strokeWidth: 0,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      //Colors.white.withOpacity(0.5),
                      //Colors.white.withOpacity(0),
                      Colors.white.withAlpha(100),
                      Colors.white.withAlpha(0),
                    ],
                    stops: const [0.5, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
