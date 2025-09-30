import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/nav/snack_bar_helper.dart';

class LaunchUrl {
  static Future<void> init(BuildContext context, {required String url}) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      if (!context.mounted) return;
      SnackBarHelper.show(context, 'Could not launch $url');
      /*ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));*/
    }
  }
}
