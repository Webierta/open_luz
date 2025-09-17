import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as httpdio;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import '../utils/estados.dart';
import 'datos_balance.dart';
import 'datos_pvpc.dart';

const String urlIndicator1001 = 'https://api.esios.ree.es/indicators/1001';
const String urlArchive70 =
    'https://api.esios.ree.es/archives/70/download_json';
const String urlBalance =
    'https://apidatos.ree.es/es/datos/balance/balance-electrico';
const dirPVPC = 'PVPC';

class RequestRee {
  String fechaRequest = '';
  Status status = Status.none;
  StatusGeneracion statusGeneracion = StatusGeneracion.error;

  Map<String, List<double>> mapFechaPrecios = {};

  List<Balance> balances = [];
  List<Balance> get balanceRenovables =>
      balances.where((b) => b.renovable == true).toList();
  List<Balance> get balanceNoRenovables =>
      balances.where((b) => b.renovable == false).toList();

  //String token = '';

  /*initToken() async {
    token = await getToken();
  }

  Future<String> getToken() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }*/

  Map<String, String> get headersApiEsios => {
    'Accept': 'application/json; application/vnd.esios-api-v1+json',
    'Content-Type': 'application/json',
    'Host': 'api.esios.ree.es',
    //'x-api-key': token,
  };

  Map<String, String> get headersApiDatos => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Host': 'apidatos.ree.es',
  };

  /*Future<void> datePVPCToken(String? fecha) async {
    //fecha formato = 2025-04-25
    String url = fecha != null
        ? '$urlIndicator1001?date=${fecha}T00:00'
        : urlIndicator1001;
    try {
      var response = await http.get(Uri.parse(url), headers: headersApiEsios);
      if (response.body.contains('Access denied')) {
        status = Status.accessDenied;
      } else if (response.statusCode == 200) {
        Map<String, dynamic> objJson = jsonDecode(response.body);
        // TODO: datos from json
      } else {
        status = Status.noAcceso;
      }
    } on TimeoutException catch (_) {
      status = Status.tiempoExcedido;
    } on SocketException {
      status = Status.noInternet;
    } on Error {
      status = Status.error;
    }
  }*/

  Future<List<double>> datePVPC(String? fecha) async {
    // 2024-03-15
    String url = fecha != null ? '$urlArchive70?date=$fecha' : urlArchive70;

    try {
      var response = await http.get(Uri.parse(url), headers: headersApiEsios);
      if (response.statusCode == 200) {
        Map<String, dynamic> objJson = jsonDecode(response.body);
        // TODO: datos from json
        if (fecha == null) {
          List<dynamic> listaPVPC = objJson['PVPC'];
          fecha = listaPVPC.first['Dia']; //15/03/2024
          var date = DateTime.parse(fecha!).toLocal();
          fecha = DateFormat('yyyy-MM-dd').format(date);
          fechaRequest = fecha;
        }
        var preciosHora = JsonPVPC(objJson: objJson, fecha: fecha).read();

        if (preciosHora.isEmpty || preciosHora.length != 24) {
          status = Status.error;
          return [];
        }
        //status = preciosHora.length == 24 ? Status.ok : Status.error;
        status = Status.ok;
        return preciosHora;
        //return JsonPVPC(objJson: objJson, fecha: fecha!).read();

        /*var datosJson = DatosJson.fromJson(objJson);
        List<String> listaPrecios = <String>[];
        for (var obj in datosJson.datosPVPC) {
          listaPrecios.add(obj.precio);
        }
        for (var precio in listaPrecios) {
          //var precioDouble = roundDouble((double.tryParse(precio.replaceAll(',', '.'))! / 1000), 5);
          var precioDouble =
              double.tryParse(precio.replaceAll(',', '.'))! / 1000;
          preciosHora.add(precioDouble);
        }
        var dateDT = DateFormat('dd-MM-yyyy').parse(fecha!);
        var fechaString = DateFormat('yyyy-MM-dd').format(dateDT);
        if (HorarioVerano.check(fechaString)) {
          preciosHora.insert(2, 0);
        }
        status = preciosHora.length == 24 ? Status.ok : Status.error;*/
        //return preciosHora;
      } else {
        status = Status.noAcceso;
      }
    } on TimeoutException catch (_) {
      status = Status.tiempoExcedido;
    } on SocketException {
      status = Status.noInternet;
    } on Error {
      status = Status.error;
    }
    return [];
  }

  Future<httpdio.Response> rangePVPCDownload(
    String fecha1,
    String fecha2,
  ) async {
    String url =
        '$urlArchive70?start_date=${fecha1}T00:00&end_date=${fecha2}T23:59&date_type=datos';
    final dio = httpdio.Dio();
    final dirTemp = await getTemporaryDirectory();
    if (fecha1 != fecha2) {
      final String fileName = '$fecha1-$fecha2.zip';
      return await dio.download(url, path.join(dirTemp.path, fileName));
    } else {
      final Directory dirTempPVPC = Directory(path.join(dirTemp.path, dirPVPC));
      var dirTempPVPCPath = (await dirTempPVPC.exists())
          ? dirTempPVPC.path
          : (await dirTempPVPC.create(recursive: true)).path;
      final String fileName = '${fecha1.replaceAll('-', '')}.json';
      return await dio.download(url, path.join(dirTempPVPCPath, fileName));
    }
  }

  Future<List<GeneracionData>> dataBalance({
    required String fecha1,
    String? fecha2,
  }) async {
    fecha2 = fecha2 ?? fecha1;
    //print(fecha2);2022-12-20
    String url =
        '$urlBalance?start_date=${fecha1}T00:00&end_date=${fecha2}T23:59&time_trunc=day';

    try {
      var response = await http
          .get(Uri.parse(url), headers: headersApiDatos)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> objJson = jsonDecode(response.body);
        // TODO: datos from json
        var jsonBalance = JsonBalance(
          objJson: objJson,
          fecha1: fecha1,
          fecha2: fecha2,
        ).read();
        if (jsonBalance.isEmpty) {
          statusGeneracion = StatusGeneracion.error;
          return [];
        }
        statusGeneracion = StatusGeneracion.ok;
        return jsonBalance;
      } else {
        statusGeneracion = StatusGeneracion.error;
        return [];
      }
    } catch (e) {
      statusGeneracion = StatusGeneracion.error;
      return [];
    }
  }

  // rangeBalance(String fecha1, String fecha2) async {}
}
