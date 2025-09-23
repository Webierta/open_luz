import 'package:flutter/material.dart';

import '../../theme/style_app.dart';
import '../../utils/read_file.dart';
import 'widgets/head_screen.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: SafeArea(
        child: Container(
          decoration: StyleApp.mainDecoration,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const HeadScreen(),
                Divider(color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(height: 10.0),
                const ReadFile(archivo: 'assets/files/info.txt'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
