import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../utils/file_util.dart';

class ComparadorResultado extends StatefulWidget {
  final List<DateTime> fechas;
  final double facturaConsumosPVPC;
  final double facturaPotenciaPVPC;
  final double facturaConsumosLibre;
  final double facturaPotenciaLibre;

  const ComparadorResultado({
    super.key,
    required this.fechas,
    required this.facturaConsumosPVPC,
    required this.facturaPotenciaPVPC,
    required this.facturaConsumosLibre,
    required this.facturaPotenciaLibre,
  });

  @override
  State<ComparadorResultado> createState() => _ComparadorResultadoState();
}

class _ComparadorResultadoState extends State<ComparadorResultado> {
  ScreenshotController screenshotController = ScreenshotController();
  String fecha1 = '';
  String fecha2 = '';

  @override
  void initState() {
    fecha1 = DateFormat('dd/MM/yyyy').format(
      DateTime(
        widget.fechas.first.year,
        widget.fechas.first.month,
        widget.fechas.first.day,
      ),
    );
    fecha2 = DateFormat('dd/MM/yyyy').format(
      DateTime(
        widget.fechas.last.year,
        widget.fechas.last.month,
        widget.fechas.last.day,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () async {
                    await FileUtil.sharingScreenshot(screenshotController);
                  },
                  icon: Icon(Icons.share),
                ),
              ),
              const SizedBox(height: 4),
              const Text('COMPARATIVA DE FACTURAS ESTIMADAS'),
              Text('Periodo del $fecha1 al $fecha2'),
              const Spacer(),
              Text(
                'Tarifa regulada PVPC',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                '${(widget.facturaConsumosPVPC + widget.facturaPotenciaPVPC).toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                'Consumo: ${widget.facturaConsumosPVPC.toStringAsFixed(2)} €',
                //style: TextStyle(fontSize: 30),
              ),
              Text(
                'Potencia: ${widget.facturaPotenciaPVPC.toStringAsFixed(2)} €',
                //style: TextStyle(fontSize: 30),
              ),
              const Spacer(),
              Text(
                'Tarifa del Mercado Libre',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                '${(widget.facturaConsumosLibre + widget.facturaPotenciaLibre).toStringAsFixed(2)} €',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                'Consumo: ${widget.facturaConsumosLibre.toStringAsFixed(2)} €',
                //style: TextStyle(fontSize: 30),
              ),
              Text(
                'Potencia: ${widget.facturaPotenciaLibre.toStringAsFixed(2)} €',
                //style: TextStyle(fontSize: 30),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
