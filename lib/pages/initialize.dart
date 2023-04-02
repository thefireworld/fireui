import 'package:fireui/fireui.dart';
import 'package:flutter/material.dart';

class FireInitializePage extends StatefulWidget {
  final String fireApiKey;
  final RebuildController? rebuildController;
  final bool dontConnectToFireServer, dontConnectToFireService;
  final Widget? next;

  const FireInitializePage({
    required this.fireApiKey,
    this.rebuildController,
    this.dontConnectToFireServer = false,
    this.dontConnectToFireService = false,
    this.next,
    Key? key,
  }) : super(key: key);

  @override
  State<FireInitializePage> createState() => _FireInitializePageState();
}

class _FireInitializePageState extends State<FireInitializePage> {
  String loadingText = "Loading...";

  @override
  void initState() {
    super.initState();

    initialize(
      newKey: widget.fireApiKey,
      rebuildController: widget.rebuildController,
    );

    () async {
      if (!widget.dontConnectToFireServer) {
        setState(() => loadingText = "Fire Server에 연결하는중...");
        await connectToFireServer(context: context);
      }

      if (!widget.dontConnectToFireService) {
        setState(() => loadingText = "Fire Service에 연결하는중...");
        await connectToFireService(context: context);
      }

      setState(() => loadingText = "Fire가 준비되었습니다!");

      if (widget.next == null) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.next!),
      );
    }();
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
        Text(loadingText, style: FireStyles.smallHeaderStyle),
      ],
    );
  }
}
