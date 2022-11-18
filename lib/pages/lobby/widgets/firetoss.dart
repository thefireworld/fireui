import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drag_and_drop_windows/drag_and_drop_windows.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire/env.dart';
import 'package:fire/main.dart';
import 'package:fire/utils/utils.dart';
import 'package:fire/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:iconsax/iconsax.dart';
import 'package:qrscan/qrscan.dart';

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
            sendFile(context, value);
            files.clear();
          },
        ),
      );
    });
    widgets.add(
      PopupMenuItem(
        child: const Text("디바이스 찾기.."),
        onTap: () async {
          TextEditingController textField = TextEditingController();
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('주소를 입력해주세요.'),
                content: TextField(
                  controller: textField,
                  decoration: const InputDecoration(
                    labelText: "Address",
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: Platform.isAndroid || Platform.isIOS
                        ? () async {
                            String? code = await scan();
                            textField.text = code ?? "";
                          }
                        : null,
                    child: const Text('QR코드 스캔하기'),
                  ),
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () async {
                      Navigator.pop(ctx);

                      await sendFile(context, textField.text);
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );

          sendFile(context, textField.text);
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

  Future<void> sendFile(BuildContext context, String address) async {
    var dio = Dio();
    List<MultipartFile> uploadFiles = [];
    for (var path in files) {
      File file = File(path);
      uploadFiles.add(MultipartFile.fromBytes(
          encryptFile(file.readAsBytesSync(), "awesome password"),
          filename: file.path.replaceFirst(file.parent.path, "").substring(1)));
    }

    var formData = FormData.fromMap({'files': uploadFiles});
    EasyLoading.showProgress(0, status: "Uploading files..");
    try {
      final response = await dio.post(
        '$fireApiUrl/file',
        data: formData,
        onSendProgress: (rec, total) {
          EasyLoading.showProgress(rec / total, status: "Uploading files..");
        },
        options: Options(
          headers: {
            "authorization": "Bearer ${Env.fireApiKey}",
          },
        ),
      );
      if (response.statusCode == 401) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("ERROR"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
      socket.emit("toss", {
        "files": response.data["files"],
        "to": address,
      });
    } catch (e) {
      if (e is DioError) {
        if (e.response!.data["status"] == "err") {
          switch (e.response!.data["code"]) {
            case "file_too_large":
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("잠시만요!"),
                  content: const Text("파일이 너무 커요. 한 파일당 최대 용량은 1GB에요."),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("okay"),
                    ),
                  ],
                ),
              );
              break;
            default:
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("잠시만요!"),
                  content:
                      Text("오류가 발생했어요. (메시지: ${e.response!.data["message"]})"),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("okay"),
                    ),
                  ],
                ),
              );
              break;
          }
        }
      }
    }
  }
}
