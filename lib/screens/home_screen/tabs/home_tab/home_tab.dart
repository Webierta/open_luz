import 'package:flutter/material.dart';

import '../../../../database/box_data.dart';
import 'layouts/desktop_layout.dart';
import 'layouts/mobile_layout.dart';
import 'layouts/tablet_layout.dart';

class HomeTab extends StatelessWidget {
  final BoxData boxData;
  const HomeTab({super.key, required this.boxData});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          //print('DesktopLayout');
          return DesktopLayout(
            parentConstraints: constraints,
            boxData: boxData,
          );
        } else if (constraints.maxWidth >= 600) {
          //print('TabletLayout');
          return TabletLayout(parentConstraints: constraints, boxData: boxData);
        } else {
          //print('MobileLayout');
          return MobileLayout(parentConstraints: constraints, boxData: boxData);
        }
      },
    );
  }
}
