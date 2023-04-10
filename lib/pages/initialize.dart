import 'dart:io';

import 'package:fireui/fireui.dart';
import 'package:flutter/material.dart';

class FireInitializePage extends StatefulWidget {
  final String fireApiKey;
  final RebuildController? rebuildController;
  final bool dontConnectToFireServer, dontConnectToFireService;
  final InitializeStatus initializeStatus;
  final Widget? next;

  const FireInitializePage({
    required this.fireApiKey,
    required this.initializeStatus,
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

    Future.delayed(Duration(milliseconds: 1), () async {
      if (widget.initializeStatus == InitializeStatus.differentVersion) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              title: Column(
                children: const [
                  Text("Fire가 오래되었습니다."),
                ],
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Fire를 업데이트해주세요.",
                    style: FireStyles.smallHeaderStyle,
                  ),
                  const Text(
                    "업데이트를 누르면 업데이트됩니다.",
                    style: FireStyles.smallHeaderStyle,
                  ),
                  Text(
                    "필요한 FireService 버전: ${FireUI.requiredServiceVersion}",
                    style: FireStyles.smallHeaderStyle,
                  ),
                  Text(
                    "현재 FireService 버전: ${FireUI.currentServiceVersion}",
                    style: FireStyles.smallHeaderStyle,
                  ),
                ],
              ),
              actions: [
                FireButton(
                  onPressed: () {
                    // TODO Open Installer
                    exit(0);
                  },
                  text: "업데이트",
                ),
                FireButton(
                  onPressed: () {
                    exit(0);
                  },
                  text: "종료",
                ),
              ],
            );
          },
        );
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
        Text(loadingText, style: FireStyles.smallHeaderStyle),
      ],
    );
  }
}
