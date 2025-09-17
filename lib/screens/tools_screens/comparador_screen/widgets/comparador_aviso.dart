import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String urlGitHub = 'https://github.com/Webierta/tarifa_luz/issues';

class ComparadorAviso extends StatelessWidget {
  const ComparadorAviso({super.key});

  Future<void> launchURL(BuildContext context, String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Aviso',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Text(
          'El comparador de tarias todavía es una FUNCIÓN '
          'EXPERIMENTAL en fase de desarrollo.',
        ),
        const SizedBox(height: 10),
        Text(
          'Esta nueva herramienta compara una simulación de facturas de la '
          'tarifa PVPC y del mercado libre calculadas en base a un periodo '
          'concreto de consumos.',
        ),
        const SizedBox(height: 10),
        Text(
          'Las facturas estimadas no incluyen impuestos ni otros conceptos '
          'como el bono social o el alquiler del contador.',
        ),
        const SizedBox(height: 10),
        Text(
          'Para utilizarla debes adjuntar un fichero con extensión csv '
          'con los datos horarios de tu consumo. Puedes '
          'descargarlo en la página web de tu distribuidora '
          '(no confundir con tu comercializadora).',
        ),
        const SizedBox(height: 10),
        Text(
          'Puedes conocer tu distribuidora en el apartado '
          'DATOS DEL CONTRATO de tu factura. En su web selecciona '
          'Consumo registrado o Consumo por factura '
          'para descargar un archivo csv con tus consumos.',
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            //style: Theme.of(context).textTheme.bodyLarge,
            children: [
              const TextSpan(
                text:
                    'Las distribuidoras más importantes '
                    'en España son i-DE Iberdrola, e-distribución Endesa, '
                    'UFD Grupo Naturgy Unión Fenosa y Viesgo. Enlace al ',
              ),
              TextSpan(
                style: const TextStyle(
                  color: Color(0xFFCFD8DC),
                  decoration: TextDecoration.underline,
                ),
                text: 'listado completo de Distribuidoras de Electricidad.',
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchURL(
                    context,
                    'https://sede.cnmc.gob.es/listado/censo/1',
                  ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            //style: Theme.of(context).textTheme.bodyLarge,
            children: [
              const TextSpan(
                text:
                    'Ten en cuenta que no existe un estándar establecido '
                    'respecto al archivo de consumos, y cada distribuidora utiliza su propio formato '
                    '(nombres de los campos, formatos de fecha y hora, unidades '
                    'de consumo, separador de decimales, etc.). Esto potencia el '
                    'riesgo de errores durante la lectura automatizada de los '
                    'datos. Por eso es posible que puedas encontrar algún error '
                    'si utilizas un modelo no testado. Si es así y quieres colaborar '
                    'para solucionar el problema y mejorar esta app, puedes ',
              ),
              TextSpan(
                style: const TextStyle(
                  color: Color(0xFFCFD8DC),
                  decoration: TextDecoration.underline,
                ),
                text: 'informar vía Github',
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchURL(context, urlGitHub),
              ),
              const TextSpan(
                text:
                    '. En cualquier caso se agradece el envío de modelos '
                    'de archivo de consumos para colaborar en hacer la app más '
                    'compatible y útil a más usuarios. Gracias.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Además, hay distribuidoras que no proporcionan un fichero CSV, '
          'sino un fichero en formato Excel (XLS). En ese caso, se puede convertir '
          'el fichero XLS en un fichero CSV (por ejemplo con el programa '
          'LibreOffice Calc, seleccionando en opciones Delimitador de campos: '
          '[ ; ] y Delimitador de cadena: [ " ] ). No obstante, no hay ninguna '
          'garantía de que el resultado sea satisfactorio.',
        ),
        const SizedBox(height: 10),
        Text(
          'La aplicación no almacena ningún dato del archivo de consumos. '
          'Opcionalmente, desde Ajustes puedes elegir que los precios '
          'descargados para calcular la factura PVPC se incorporen a la App '
          'como si fueran fechas consultadas por el usuario.',
        ),
      ],
    );
  }
}
