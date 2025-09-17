//import 'package:intl/intl.dart';

import '../utils/horario_verano.dart';

class DatosPVPC {
  //String dia;
  //String hora;
  String precio;
  //DatosPVPC({this.dia, this.hora, this.precio});
  DatosPVPC({required this.precio});

  factory DatosPVPC.fromJson(Map<String, dynamic> json) {
    return DatosPVPC(
      //dia: json['Dia'],
      //hora: json['Hora'],
      precio: json['PCB'],
    );
  }
}

class DatosJson {
  final List<DatosPVPC> datosPVPC;
  DatosJson({required this.datosPVPC});

  factory DatosJson.fromJson(Map<String, dynamic> json) {
    List<dynamic> listaObj = json['PVPC'];
    List<DatosPVPC> listaPVPC = listaObj
        .map((obj) => DatosPVPC.fromJson(obj))
        .toList();
    return DatosJson(datosPVPC: listaPVPC);
  }
}

class JsonPVPC {
  final Map<String, dynamic> objJson;
  String fecha; // yyyy-MM-dd
  JsonPVPC({required this.objJson, required this.fecha});

  List<double> read() {
    List<double> preciosHora = <double>[];
    try {
      var datosJson = DatosJson.fromJson(objJson);
      List<String> listaPrecios = <String>[];
      for (var obj in datosJson.datosPVPC) {
        listaPrecios.add(obj.precio);
      }
      for (var precio in listaPrecios) {
        //var precioDouble = roundDouble((double.tryParse(precio.replaceAll(',', '.'))! / 1000), 5);
        var precioDouble = double.tryParse(precio.replaceAll(',', '.'))! / 1000;
        preciosHora.add(precioDouble);
      }
      if (HorarioVerano.check(fecha)) {
        preciosHora.insert(2, 0);
      }
      return preciosHora;
    } catch (e) {
      return <double>[];
    }
  }
}
