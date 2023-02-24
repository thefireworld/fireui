import 'package:flutter/material.dart';

class RebuildController {
  final GlobalKey rebuildKey = GlobalKey();

  void rebuild() {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (rebuildKey.currentContext as Element).visitChildren(rebuild);
  }
}

class RebuildWrapper extends StatelessWidget {
  final RebuildController controller;
  final Widget child;

  const RebuildWrapper(
      {Key? key, required this.controller, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: controller.rebuildKey,
      child: child,
    );
  }
}
