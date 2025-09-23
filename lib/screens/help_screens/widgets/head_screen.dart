import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_luz/utils/constantes.dart';

import '../../../theme/style_app.dart';
import '../../../utils/launch_url.dart';

class HeadScreen extends StatelessWidget {
  const HeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              spacing: 20.0,
              runSpacing: 10.0,
              //runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ic_launcher.png',
                  //width: 192,
                  //height: 250,
                  //fit: BoxFit.fill,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Open Luz',
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(
                            fontWeight: FontWeight.w100,
                            color: StyleApp.accentColor,
                            fontSize: 30,
                          ),
                    ),
                    Text(
                      kVersion,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),

                    const SizedBox(height: 50),
                    ActionChip(
                      backgroundColor: Colors.blueAccent,
                      /*color: WidgetStateProperty.resolveWith((states) {
                        return Colors.blueAccent;
                      }),*/
                      avatar: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: SvgPicture.asset(
                          'assets/images/logo-github.svg',
                          semanticsLabel: 'GitHub Logo',
                        ),
                      ),
                      label: Text(
                        'Código y soporte',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      onPressed: () => LaunchUrl.init(context, url: kGitHub),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Copyleft 2020-2025. Jesús Cuerda (Webierta).',
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w300),
          ),
          Text(
            'All Wrongs Reserved. Licencia GPLv3.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
