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
      ],
    );
  }

  static const String text1 =
      'El precio de la potencia contratada en la tarifa PVPC incluye el importe '
      'por peajes de transporte y distribución + el importe por cargos de potencia.';

  static const String text2 =
      'Al seleccionar un año, se ofrecen los precios de la potencia (€/kW día) '
      'para ese ejercicio. La aplicación calcula esos precios en base a las '
      'tarifas oficiales (€/kW año) publicadas cada año en el BOE.';

  static const String text3 =
      'Alternativamente, el usuario puede introducir su propios precios.';
}
