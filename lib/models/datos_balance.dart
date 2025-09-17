typedef Balance = ({
  bool renovable,
  String name,
  String fecha,
  double generacion,
});

class GeneracionData {
  DateTime fecha;
  List<Balance> balances;
  GeneracionData({required this.fecha, required this.balances});
}

class JsonBalance {
  final Map<String, dynamic> objJson;
  String fecha1;
  String fecha2;

  JsonBalance({
    required this.objJson,
    required this.fecha1,
    required this.fecha2,
  });

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  List<GeneracionData> read() {
    List<GeneracionData> generacion = [];
    List<Balance> balances = [];

    try {
      var included = objJson['included'];
      for (var item in included) {
        var content = item['attributes']['content'];
        for (var c in content) {
          if (item['type'] != 'Renovable' && item['type'] != 'No-Renovable') {
            continue;
          }
          bool isRenovable = item['type'] == 'Renovable' ? true : false;
          var name = c['type'].toString();
          var valores = c['attributes']['values'];
          for (var valor in valores) {
            var total = valor['value'].toDouble();
            var fecha = valor['datetime'].toString();
            // "2021-07-28T00:00:00.000+02:00"
            ({bool renovable, String name, String fecha, double generacion})
            balance = (
              renovable: isRenovable,
              name: name,
              fecha: fecha,
              generacion: total,
            );
            balances.add(balance);
          }
        }
      }
    } catch (e) {}

    if (balances.isEmpty) {
      return generacion;
    }

    DateTime date1 = DateTime.parse(fecha1).toLocal();
    DateTime date2 = DateTime.parse(fecha2).toLocal();
    List<DateTime> days = getDaysInBetween(date1, date2);
    for (var dia in days) {
      //print(dia); 2023-07-10 00:00:00.000
      for (var balance in balances) {
        DateTime date = DateTime.parse(balance.fecha).toLocal();
        if (dia == date) {
          generacion.add(GeneracionData(fecha: date, balances: [balance]));
        }
      }
    }

    return generacion;
  }
}
