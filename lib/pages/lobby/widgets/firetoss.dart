import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drag_and_drop_windows/drag_and_drop_windows.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire/utils/utils.dart';
import 'package:fire/widgets.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../lobby.dart';

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
    return Column(
      children: [
        TitleBar(
          "FireToss",
          PopupMenu(
            menuList: bubbles(),
            child: const Icon(Iconsax.send_2),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: fileListWidget()),
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry> bubbles() {
    List<PopupMenuEntry> widgets = [];
    devices.forEach((key, value) {
      widgets.add(
        PopupMenuItem(
          child: Text(key),
          onTap: () async {
            //TODO 파일 전송
            files.clear();
          },
        ),
      );
    });
    widgets.add(
      PopupMenuItem(
        child: const Text("디바이스 찾기.."),
        onTap: () async {
          //TODO 디바이스 찾기
          //TODO 파일 전송
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
