import 'package:flutter/material.dart';

import '../home_screen/home_screen.dart';

class PopScopeHelper {
  static void Function(bool didPop, Object? result) onPopInvoked(
    BuildContext context,
  ) => (bool didPop, Object? result) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(isFirstLaunch: false),
      ),
    );
  };
}
