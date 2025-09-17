import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';

import '../utils/estados.dart';

enum RangoHoras {
  /*baratas('😄', '8 horas más baratas'),
  intermedias('😐', '8 horas intermedias'),
  caras('😡', '8 horas más caras');*/

  baratas('\u{1F604}', '8 horas más baratas'),
  intermedias('\u{1F610}', '8 horas intermedias'),
  caras('\u{1F621}', '8 horas más caras');

  final String emoji;
  final String description;
  const RangoHoras(this.emoji, this.description);
}

enum RangoHorasAnimated {
  baratas(AnimatedEmojis.grin, '8 horas más baratas'),
  intermedias(AnimatedEmojis.neutralFace, '8 horas intermedias'),
  caras(AnimatedEmojis.rage, '8 horas más caras');

  final AnimatedEmojiData emoji;
  final String description;
  const RangoHorasAnimated(this.emoji, this.description);
}

class Tarifa {
  static Color getColorFondo(double precio) {
    if (precio < 0.10) {
      return const Color(0xFFDCEDC8);
    } else if (precio < 0.15) {
      //return const Color(0xFFFFFDE7);
      return const Color(0xFFFFF9C4);
    } else {
      return const Color(0xFFFFCDD2);
    }
  }

  /*static String getSemaforo(double precio) {
    if (precio < 0.10) {
      return 'semaforo_verde.png';
    } else if (precio < 0.15) {
      return 'semaforo_amarillo.png';
    } else {
      return 'semaforo_rojo.png';
    }
  }*/

  static Color getColorBorder(double precio) {
    if (precio < 0.10) {
      return Colors.lightGreen;
    } else if (precio < 0.15) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  static Color getColorCara(List<double> preciosHoras, double valor) {
    List<double> preciosAs = List.from(preciosHoras);
    preciosAs.sort();
    if (preciosAs.indexWhere((v) => v == valor) < 8) {
      return const Color(0xFF388E3C);
    } else if (preciosAs.indexWhere((v) => v == valor) > 15) {
      return const Color(0xFFE64A19);
    } else {
      return const Color(0xFFFFA000);
    }
  }

  static RangoHoras getRangoHora(List<double> preciosHoras, double valor) {
    List<double> preciosAs = List.from(preciosHoras);
    preciosAs.sort();
    if (preciosAs.indexWhere((v) => v == valor) < 8) {
      return RangoHoras.baratas;
    } else if (preciosAs.indexWhere((v) => v == valor) > 15) {
      return RangoHoras.caras;
    } else {
      return RangoHoras.intermedias;
    }
  }

  static String getEmojiCara(List<double> preciosHoras, double valor) {
    List<double> preciosAs = List.from(preciosHoras);
    preciosAs.sort();
    if (preciosAs.indexWhere((v) => v == valor) < 8) {
      return RangoHoras.baratas.emoji;
    } else if (preciosAs.indexWhere((v) => v == valor) > 15) {
      return RangoHoras.caras.emoji;
    } else {
      return RangoHoras.intermedias.emoji;
    }
  }

  static AnimatedEmojiData getEmojiCaraAnimated(
    List<double> preciosHoras,
    double valor,
  ) {
    List<double> preciosAs = List.from(preciosHoras);
    preciosAs.sort();
    if (preciosAs.indexWhere((v) => v == valor) < 8) {
      return RangoHorasAnimated.baratas.emoji;
    } else if (preciosAs.indexWhere((v) => v == valor) > 15) {
      return RangoHorasAnimated.caras.emoji;
    } else {
      return RangoHorasAnimated.intermedias.emoji;
    }
  }

  /*static Widget getIconCara(List<double> preciosHoras, double valor,
      {double sizeIcon = 40.0, double radius = 20}) {
    List<double> preciosAs = List.from(preciosHoras);
    preciosAs.sort();
    if (preciosAs.indexWhere((v) => v == valor) < 8) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.green[700],
        child: Icon(
          Icons.sentiment_very_satisfied_sharp, //stars, // grade, //flash_on,
          size: sizeIcon,
          color: Colors.white,
        ),
      );
    } else if (preciosAs.indexWhere((v) => v == valor) > 15) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.deepOrange[700],
        child: Icon(
          Icons.sentiment_very_dissatisfied, //warning,
          size: sizeIcon,
          color: Colors.white,
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        foregroundColor: Colors.amber[700],
        child: Icon(
          Icons.sentiment_neutral_sharp,
          size: sizeIcon,
        ),
      );
    }
  }*/

  static Color getPeriodoColor(DateTime fecha) {
    if (fecha.weekday > 5) {
      return getColorPeriodo(Periodo.valle);
    }
    if ((fecha.month == 1 && fecha.day == 1) ||
        (fecha.month == 1 && fecha.day == 6) ||
        (fecha.month == 5 && fecha.day == 1) ||
        (fecha.month == 10 && fecha.day == 12) ||
        (fecha.month == 11 && fecha.day == 1) ||
        (fecha.month == 12 && fecha.day == 6) ||
        (fecha.month == 12 && fecha.day == 8) ||
        (fecha.month == 12 && fecha.day == 25)) {
      return getColorPeriodo(Periodo.valle);
    }
    var hora = fecha.hour;
    if (hora < 8) {
      return getColorPeriodo(Periodo.valle);
    } else if ((hora > 9 && hora < 14) || (hora > 17 && hora < 22)) {
      return getColorPeriodo(Periodo.punta);
    } else {
      return getColorPeriodo(Periodo.llano);
    }
  }

  static Periodo getPeriodo(DateTime fecha) {
    if (fecha.weekday > 5) {
      return Periodo.valle;
    }
    if ((fecha.month == 1 && fecha.day == 1) ||
        (fecha.month == 1 && fecha.day == 6) ||
        (fecha.month == 5 && fecha.day == 1) ||
        (fecha.month == 10 && fecha.day == 12) ||
        (fecha.month == 11 && fecha.day == 1) ||
        (fecha.month == 12 && fecha.day == 6) ||
        (fecha.month == 12 && fecha.day == 8) ||
        (fecha.month == 12 && fecha.day == 25)) {
      return Periodo.valle;
    }
    var hora = fecha.hour;
    if (hora < 8) {
      return Periodo.valle;
    } else if ((hora > 9 && hora < 14) || (hora > 17 && hora < 22)) {
      return Periodo.punta;
    } else {
      return Periodo.llano;
    }
    /* Periodo punta: De lunes a viernes de 10 a 14 h y de 18 a 22 h.
    Periodo llano: De lunes a viernes de 8 a 10 h., de 14 a 18 h. y de 22 a 24 h.
    Periodo valle: De lunes a viernes de 24 h. a 8 h. y todas las horas de fines de semana y
    festivos nacionales de fecha fija yel 6 de enero).
       */
  }

  static Color getColorPeriodo(Periodo periodo) {
    if (periodo == Periodo.valle) {
      return const Color(0xFF81C784);
    } else if (periodo == Periodo.punta) {
      return const Color(0xFFE57373);
    } else {
      return Colors.amberAccent;
    }
  }

  static Icon getIconPeriodo(Periodo periodo, {double size = 30.0}) {
    IconData icono;
    Color color;
    if (periodo == Periodo.valle) {
      icono = Icons.trending_down;
      color = Colors.green;
    } else if (periodo == Periodo.punta) {
      icono = Icons.trending_up;
      color = Colors.red;
    } else {
      icono = Icons.trending_neutral;
      color = Colors.yellow;
    }
    return Icon(icono, size: size, color: color);
  }

  /*static String getEmojiPeriodo(Periodo periodo) {
    // ☀️ ⛅ ⚡ ❄️
    if (periodo == Periodo.valle) {
      return '☀️';
    } else if (periodo == Periodo.punta) {
      return '❄️';
    } else {
      return '⛅';
    }
  }*/
}
