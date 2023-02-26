import 'package:flutter/material.dart';

import 'utils/utils.dart';

class TitleBar extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const TitleBar(this.title, {Key? key, this.trailing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(title, style: text(fontSize: 27)),
            Positioned(
              right: 10,
              child: trailing ?? Container(),
            ),
          ],
        ),
      ),
    );
  }
}
