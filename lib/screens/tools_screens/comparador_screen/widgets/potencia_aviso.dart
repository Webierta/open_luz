import 'package:flutter/material.dart';

class PotenciaAviso extends StatelessWidget {
  const PotenciaAviso({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Info',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 20),
        const Text(text1),
        const SizedBox(height: 20),
        const Text(text2),
        const SizedBox(height: 20),
        const Text(text3),
        const SizedBox(height: 20),
        const Text(text4),
        const SizedBox(height: 20),
        const Text(text5),
      ],
    );
  }

  static const String text1 =
      'El precio de la potencia contratada en la tarifa PVPC incluye el importe '
      'por peajes de transporte y distribución + el importe por cargos de potencia.';

  static const String text2 =
      'Como referencia aparecen por defecto los últimos precios oficiales para '
      '2025 publicados en el BOE. En caso de introducir datos de años '
      'anteriores, habría que introducir los precios correspondientes, que '
      'se pueden encontrar en la factura o en el BOE.';

  static const String text3 =
      'Concretamente, los precios utilizados aquí se han obtenido de:';

  static const String text4 =
      'BOE núm. 302 de 16 de diciembre de 2024: Resolución de 4 de diciembre de '
      '2024, de la Comisión Nacional de los Mercados y la Competencia, por la '
      'que se establecen los valores de los peajes de acceso a las redes de '
      'transporte y distribución de electricidad de aplicación a partir del 1 '
      'de enero de 2025.';

  static const String text5 =
      'BOE núm. 313 de 28 de diciembre de 2024: Orden TED/1487/2024, de 26 de '
      'diciembre, por la que se establecen los precios de los cargos del sistema '
      'eléctrico y se establecen diversos costes regulados del sistema eléctrico '
      'para el ejercicio 2025.';
}
