import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../utils/estados.dart';

class OpenDialog {
  static Future<Response?> alert(
    BuildContext context,
    Alert alert, {
    DateTime? fechaDuple,
  }) async {
    String title = 'Fecha en Archivo';
    String fechaString = fechaDuple != null
        ? DateFormat('d MMM yy').format(fechaDuple)
        : 'ese día';
    String content =
        'Los datos de $fechaString ya han sido consultados y están archivados. '
        'Puedes verlos en el histórico de consultas.\n'
        'Continuar con la consulta sobreescribe los datos almacenados.';
    if (alert == Alert.notyet) {
      title = 'No publicado';
      content =
          'En torno a las 20:15h de cada día, la REE publica los precios '
          'de la electricidad que se aplicarán al día siguiente, por lo que '
          'es posible que los datos todavía no estén publicados.';
    }
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(Response.cancel),
            ),
            if (alert == Alert.archived)
              TextButton(
                onPressed: () => Navigator.pop(context, Response.go),
                child: const Text('Ver'),
              ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(Response.ok),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> confirm(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String contenido,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, size: 40),
              const SizedBox(width: 10),
              Text(titulo),
            ],
          ),
          //insetPadding: EdgeInsets.all(20),
          //contentPadding: EdgeInsets.all(20),
          content: Text('Confirmación rerquerida: $contenido'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
