import 'package:flutter/material.dart';

import '../../../../theme/style_app.dart';

class OpenAviso {
  static Future show(BuildContext context, {required Widget widget}) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          child: Container(
            decoration: StyleApp.mainDecoration,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.blue),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: widget,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
