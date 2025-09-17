import 'package:flutter/material.dart';

import '../../../theme/style_app.dart';

class HeadScreen extends StatelessWidget {
  const HeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: FittedBox(
              child: Text(
                'Open Luz',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w100,
                  color: StyleApp.accentColor,
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: const FittedBox(
              child: Text('Open Source de la Tarifa Eléctrica Regulada'),
            ),
          ),
        ],
      ),
    );
  }
}
