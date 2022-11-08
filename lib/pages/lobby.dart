import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drag_and_drop_windows/drag_and_drop_windows.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire/main.dart';
import 'package:fire/utils.dart';
import 'package:fire/widgets.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  String? deviceName;

  @override
  void initState() {
    getDeviceName().then((value) {
      setState(() {
        deviceName = value;
      });
    });

    socket.onConnect((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9adbfd),
      floatingActionButton: IconButton(
        onPressed: () async {
          showLoginCode(context, FireAccount.current!.uid);
        },
        icon: const Icon(Icons.account_circle),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: const [
              FireTossWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleBar extends StatelessWidget {
  final title;
  final trailing;

  const TitleBar(this.title, this.trailing, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: trailing,
    );
  }
}

class FireTossWidget extends StatefulWidget {
  const FireTossWidget({Key? key}) : super(key: key);

  @override
  State<FireTossWidget> createState() => _FireTossWidgetState();
}

class _FireTossWidgetState extends State<FireTossWidget> {
  List<String> files = [];
  late StreamSubscription subscription;
  Map<String, String> devices = {};
  bool isDeviceFound = false;

  @override
  void initState() {
    if (!isDeviceFound) {
      var dio = Dio();
      dio
          .get('$fireApiUrl/user/${FireAccount.current?.uid}/device/list',
              options: Options(sendTimeout: 5000))
          .then((value) {
        for (var value in jsonDecode(value.toString())["devices"]) {
          if (address != value["address"]) {
            devices[value["name"]] = value["address"];
          }
        }
        setState(() {});
      });
      isDeviceFound = true;
    }

    if (Platform.isWindows) {
      subscription = dropEventStream.listen((paths) {
        setState(() {
          files.addAll(paths);
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Container(
        width: 350,
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            TitleBar(
              "FireToss",
              PopupMenu(
                menuList: bubbles(),
                child: const Icon(Icons.send),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: fileListWidget()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry> bubbles() {
    List<PopupMenuEntry> widgets = [];
    devices.forEach((key, value) {
      widgets.add(
        PopupMenuItem(
          child: Text(key),
          onTap: () async {
            // await sendFile(context, value);
            files.clear();
          },
        ),
      );
    });
    widgets.add(
      PopupMenuItem(
        child: const Text("디바이스 찾기.."),
        onTap: () async {
          // await sendFile(context, value);
        },
      ),
    );
    return widgets;
  }

  List<Widget> fileListWidget() {
    List<Widget> widgets = [];
    for (var value in files) {
      List<String> spl = value.split("\\");
      String filename = spl[spl.length - 1];
      widgets.add(
        ListTile(
          leading: FileIcon(filename),
          title: Text(filename),
          subtitle: Text(value.replaceAll(filename, "")),
        ),
      );
    }
    widgets.add(
      Center(
        child: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            FilePickerResult? result =
                await FilePicker.platform.pickFiles(allowMultiple: true);

            if (result != null) {
              setState(() {
                files.addAll(result.paths.map((e) => e!));
              });
            }
          },
        ),
      ),
    );
    return widgets;
  }
}
