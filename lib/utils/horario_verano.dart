// 2:00 → 3:00

class HorarioVerano {
  //final String fecha;

  //HorarioVerano({required this.fecha});

  static bool check(String fecha) {
    if (fecha == '2022-03-27' ||
        fecha == '2023-03-26' ||
        fecha == '2024-03-31' ||
        fecha == '2025-03-30' ||
        fecha == '2026-03-29' ||
        fecha == '2027-03-28') {
      // 2028-03-26
      return true;
    }
    return false;
  }
}
