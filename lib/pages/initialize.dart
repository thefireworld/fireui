import 'package:fireui/fireui.dart';
import 'package:flutter/material.dart';

class FireInitializePage extends StatefulWidget {
  final String fireApiKey;
  final RebuildController? rebuildController;
  final Widget? next;

  const FireInitializePage(
      {required this.fireApiKey, this.rebuildController, this.next, Key? key})
      : super(key: key);

  @override
  State<FireInitializePage> createState() => _FireInitializePageState();
}

class _FireInitializePageState extends State<FireInitializePage> {
  @override
  void initState() {
    super.initState();

    initialize(
      newKey: widget.fireApiKey,
      rebuildController: widget.rebuildController,
    ).then((value) {
      if (widget.next == null) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.next!),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FireLogo(size: 100),
        const SizedBox(height: 50),
        CircularProgressIndicator(),
        const SizedBox(height: 10),
        Text("서버에 연결하는중..", style: FireStyles.smallHeaderStyle),
      ],
    );
  }
}
