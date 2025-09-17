import 'package:flutter/material.dart';

import '../../../../../theme/style_app.dart';

class FuenteREE extends StatelessWidget {
  const FuenteREE({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Divider(color: StyleApp.onBackgroundColor.withAlpha(50)),
          Text(
            'Fuente: REE (e·sios y REData)',
            style: TextStyle(color: StyleApp.onBackgroundColor.withAlpha(100)),
          ),
          Divider(color: StyleApp.onBackgroundColor.withAlpha(50)),
        ],
      ),
    );
  }
}
