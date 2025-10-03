import 'dart:collection';

import 'package:flutter/material.dart';

typedef YearEntry = DropdownMenuEntry<PrecioPotenciaPVPC>;

enum PrecioPotenciaPVPC {
  // BOE-A-2024-27289     BOE-A-2024-26218
  year2025(
    label: '2025',
    peajePunta: 22.958932,
    peajeValle: 0.442165,
    cargoPunta: 3.971618,
    cargoValle: 0.255423,
  ),
  // BOE-A-2023-26251     BOE-A-2024-2774
  year2024(
    label: '2024',
    peajePunta: 22.401746,
    peajeValle: 0.776564,
    cargoPunta: 2.989915,
    cargoValle: 0.192288,
  ),
  // BOE-A-2022-21799     BOE-A-2022-23737
  year2023(
    label: '2023',
    peajePunta: 22.393140,
    peajeValle: 1.150425,
    cargoPunta: 2.989915,
    cargoValle: 0.192288,
  ),
  // BOE-A-2021-21208     BOE-A-2021-21794
  year2022(
    label: '2022',
    peajePunta: 22.988256,
    peajeValle: 0.938890,
    cargoPunta: 4.970533,
    cargoValle: 0.319666,
  ),
  // BOE-A-2021-6390      BOE-A-2021-4565
  year2021(
    label: '2021',
    peajePunta: 23.469833,
    peajeValle: 0.961130,
    cargoPunta: 7.202827,
    cargoValle: 0.463229,
  );

  final String label;
  final double peajePunta;
  final double peajeValle;
  final double cargoPunta;
  final double cargoValle;

  const PrecioPotenciaPVPC({
    required this.label,
    required this.peajePunta,
    required this.peajeValle,
    required this.cargoPunta,
    required this.cargoValle,
  });

  static final List<YearEntry> entries = UnmodifiableListView<YearEntry>(
    values.map<YearEntry>(
      (PrecioPotenciaPVPC year) => YearEntry(value: year, label: year.label),
    ),
  );

  double get precioDiaPunta => (peajePunta / 365) + (cargoPunta / 365);
  double get precioDiaValle => (peajeValle / 365) + (cargoValle / 365);
}
