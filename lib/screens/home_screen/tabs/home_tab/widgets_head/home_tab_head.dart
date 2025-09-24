import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../database/box_data.dart';
import '../../../../../models/tarifa.dart';
import '../../../../../theme/style_app.dart';
import '../../../../../utils/estados.dart';

class HomeTabHead extends StatelessWidget {
  final BoxData boxData;
  const HomeTabHead({required this.boxData, super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toLocal();
    double precioNow = boxData.getPrecio(boxData.preciosHora, now.hour);
    Periodo periodoAhora = Tarifa.getPeriodo(
      boxData.fecha.copyWith(hour: now.hour),
    );
    var desviacion = boxData.preciosHora[now.hour] - boxData.precioMedio;
    //Color color = Tarifa.getColorCara(boxData.preciosHora, precioNow);
    RangoHorasBombilla rango = Tarifa.getRangoHora(
      boxData.preciosHora,
      precioNow,
    );

    /*int indexPrecio() {
      Map<int, double> mapPreciosOrdenados =
          boxData.ordenarPrecios(boxData.preciosHora);
      List<double> preciosOrdenados = mapPreciosOrdenados.values.toList();
      return preciosOrdenados.indexOf(precioNow) + 1;
    }*/

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${boxData.fechaddMMyy} a las ${DateFormat('HH:mm').format(now)}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        FittedBox(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 20, 10),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Text(
                        precioNow.toStringAsFixed(5),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      const Text(
                        '€/kWh',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        //const Spacer(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Tarifa.getIconPeriodo(periodoAhora, size: 38),
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Periodo ${periodoAhora.name.toUpperCase()}',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              width: 38,
              Tarifa.getBombilla(boxData.preciosHora, precioNow),
            ),
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(rango.description, style: TextStyle(fontSize: 14)),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            decoration: StyleApp.kIconDeco,
            child: Icon(
              desviacion > 0 ? Icons.upload : Icons.download,
              color: desviacion > 0 ? Colors.red : Colors.green,
              size: 38,
            ),
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${desviacion.toStringAsFixed(4)} €',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        //const Spacer(),
      ],
    );
  }
}
