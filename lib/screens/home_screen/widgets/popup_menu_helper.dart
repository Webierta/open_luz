import 'package:flutter/material.dart';

typedef PopupMenuCallback = void Function(OptionsMenu value);

enum OptionsMenu {
  fecha('Seleccionar fecha', Icons.today),
  intervalo('Seleccionar intervalo', Icons.date_range),
  divider(),
  delete('Eliminar registro', Icons.delete);

  final String? texto;
  final IconData? icon;
  const OptionsMenu([this.texto, this.icon]);
}

class PopupMenuHelper {
  static PopupMenuButton<OptionsMenu> buildPopupMenu(
    BuildContext context, {
    required PopupMenuCallback onSelected,
    required List<OptionsMenu> optionsList,
  }) {
    return PopupMenuButton<OptionsMenu>(
      onSelected: onSelected,
      itemBuilder: (BuildContext context) {
        return List.generate(optionsList.length, (index) {
          if (optionsList[index] == OptionsMenu.divider) {
            return PopupMenuDivider();
          }
          return PopupMenuItem<OptionsMenu>(
            value: optionsList[index],
            child: ListTile(
              //contentPadding: EdgeInsets.symmetric(horizontal: 2),
              leading: Icon(optionsList[index].icon!),
              title: Text(optionsList[index].texto!),
            ),
          );
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: const Icon(Icons.more_vert),
      ),
    );
  }
}
