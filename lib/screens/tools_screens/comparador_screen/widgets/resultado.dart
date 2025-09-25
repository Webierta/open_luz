import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../../theme/style_app.dart';
import '../../../../utils/file_util.dart';

enum Mercado {
  regulado('la Tarifa regulada (PVPC)'),
  libre('el Mercado Libre');

  final String texto;
  const Mercado(this.texto);
}

class Resultado extends StatefulWidget {
  final List<DateTime> fechas;
  final double facturaConsumosPVPC;
  final double facturaPotenciaPVPC;
  final double facturaConsumosLibre;
  final double facturaPotenciaLibre;
  const Resultado({
    super.key,
    required this.fechas,
    required this.facturaConsumosPVPC,
    required this.facturaPotenciaPVPC,
    required this.facturaConsumosLibre,
    required this.facturaPotenciaLibre,
  });

  @override
  State<Resultado> createState() => _ResultadoState();
}

class _ResultadoState extends State<Resultado> {
  ScreenshotController screenshotController = ScreenshotController();
  String fecha1 = '';
  String fecha2 = '';

  Mercado? masBarato;
  double diferencia = 0;
  BoxDecoration boxDecoration = StyleApp.mainDecoration;

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

    diferencia =
        (widget.facturaConsumosPVPC + widget.facturaPotenciaPVPC) -
        (widget.facturaConsumosLibre + widget.facturaPotenciaLibre);

    if (diferencia == 0) {
      masBarato = null;
    } else {
      masBarato = diferencia < 0 ? Mercado.regulado : Mercado.libre;
    }

    super.initState();
  }

  void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snackbar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comparador de Tarifas'),
        actions: [
          if (Theme.of(context).platform == TargetPlatform.android)
            //if(Platform.isAndroid)
            IconButton(
              onPressed: () async {
                await FileUtil.sharingScreenshot(screenshotController);
              },
              icon: Icon(Icons.share),
            ),
          IconButton(
            onPressed: () async {
              final directory = (await getDownloadsDirectory())?.path;
              //String fileName = 'Ahorro.png';
              String fileName =
                  'OpenLuz${DateTime.now().microsecondsSinceEpoch}.png';
              if (directory != null) {
                setState(() {
                  boxDecoration = BoxDecoration(color: Colors.blue.shade900);
                });
                try {
                  screenshotController
                      .captureAndSave(directory, fileName: fileName)
                      .then((onValue) {
                        setState(() {
                          boxDecoration = StyleApp.mainDecoration;
                        });
                      })
                      .whenComplete(() {
                        if (context.mounted) {
                          showSnackBar(
                            context,
                            'Imagen $fileName guardada en $directory',
                          );
                        }
                      });
                } catch (error) {
                  if (context.mounted) {
                    showSnackBar(
                      context,
                      'No ha sido posible guardar la imagen.',
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  showSnackBar(
                    context,
                    'No ha sido posible guardar la imagen.',
                  );
                }
              }
            },
            icon: Icon(Icons.download),
          ),
        ],
      ),
      body: SafeArea(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            //decoration: StyleApp.mainDecoration,
            decoration: boxDecoration,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              //scrollDirection: Axis.vertical,
              //physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Text(
                    'COMPARATIVA DE FACTURAS ESTIMADAS',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  Image.asset('assets/images/ic_launcher.png', width: 60),
                  Text(
                    'Open Luz',
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.w100,
                      color: StyleApp.accentColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Periodo del $fecha1 al $fecha2',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('Concepto')),
                              DataColumn(
                                label: Text('TARIFA REGULADA'),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text('MERCADO LIBRE'),
                                numeric: true,
                              ),
                            ],
                            rows: [
                              DataRow(
                                //color: MaterialStateProperty.all(Colors.red),
                                cells: [
                                  DataCell(Text('Consumo')),
                                  DataCell(
                                    Text(
                                      '${widget.facturaConsumosPVPC.toStringAsFixed(2)} €',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${widget.facturaConsumosLibre.toStringAsFixed(2)} €',
                                    ),
                                  ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  DataCell(Text('Potencia')),
                                  DataCell(
                                    Text(
                                      '${widget.facturaPotenciaPVPC.toStringAsFixed(2)} €',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${widget.facturaPotenciaLibre.toStringAsFixed(2)} €',
                                    ),
                                  ),
                                ],
                              ),
                              DataRow(
                                selected: true,
                                cells: [
                                  DataCell(Text('Total')),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (diferencia < 0)
                                          Text(
                                            '\u{1f947}',
                                            style: TextStyle(fontSize: 30),
                                          ),
                                        Text(
                                          '${(widget.facturaConsumosPVPC + widget.facturaPotenciaPVPC).toStringAsFixed(2)} €',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (diferencia > 0)
                                          Text(
                                            '\u{1f947}',
                                            style: TextStyle(fontSize: 30),
                                          ), //
                                        Text(
                                          '${(widget.facturaConsumosLibre + widget.facturaPotenciaLibre).toStringAsFixed(2)} €',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (masBarato == null)
                    FittedBox(
                      child: Text(
                        'No hay diferencia entre la Tarifa Regulada (PVPC) y el Mercado libre.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else ...[
                    Icon(Icons.savings, size: 60, color: Colors.pink.shade200),
                    const SizedBox(width: 10),
                    FittedBox(
                      child: Text(
                        'Ahorras ${diferencia.abs().toStringAsFixed(2)} €\ncon ${masBarato?.texto}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
