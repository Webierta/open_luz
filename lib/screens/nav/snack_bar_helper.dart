import 'package:flutter/material.dart';

class SnackBarHelper {
  static void show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    final snackbar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
