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
        if (constraints.maxWidth >= 1500) {
          return DesktopLayout(
            parentConstraints: constraints,
            boxData: boxData,
          );
        } else if (constraints.maxWidth >= 900) {
          return TabletLayout(parentConstraints: constraints, boxData: boxData);
        } else {
          return MobileLayout(parentConstraints: constraints, boxData: boxData);
        }
      },
    );
  }
}
