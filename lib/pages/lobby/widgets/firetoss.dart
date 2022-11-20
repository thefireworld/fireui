import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:drag_and_drop_windows/drag_and_drop_windows.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire/utils/utils.dart';
import 'package:fire/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
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
      http
          .get(Uri.parse(
              '$fireApiUrl/user/${FireAccount.current?.uid}/device/list'))
          .then((value) {
        dynamic body = jsonDecode(value.body);
        for (var body in body["devices"]) {
          if (address != body["address"]) {
            devices[body["name"]] = body["address"];
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
          trailing: IconButton(
            onPressed: () {
              setState(() {
                files.remove(value);
              });
            },
            icon: const Icon(Iconsax.minus_cirlce),
          ),
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
    var requestMultipart = http.MultipartRequest("POST", Uri.parse('uri'));
    for (var path in files) {
      File file = File(path);
      requestMultipart.files.add(
        http.MultipartFile.fromBytes(
          path,
          encryptFile(file.readAsBytesSync(), "awesome password"),
          filename: file.path.replaceFirst(file.parent.path, "").substring(1),
        ),
      );
    }

    EasyLoading.showProgress(0, status: "Uploading files..");

    final url = '$fireApiUrl/api/file';
    final httpClient = HttpClient();
    final request = await httpClient.postUrl(Uri.parse(url));
    double byteCount = 0;
    var msStream = requestMultipart.finalize();
    var totalByteLength = requestMultipart.contentLength;
    request.contentLength = totalByteLength;

    Stream<List<int>> streamUpload = msStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);

          byteCount += data.length;

          EasyLoading.showProgress(byteCount / totalByteLength,
              status: "Uploading files.. ${byteCount / totalByteLength}");
          log("${byteCount / totalByteLength}");
        },
        handleError: (error, stack, sink) {
          throw error;
        },
        handleDone: (sink) {
          sink.close();
          // UPLOAD DONE;
        },
      ),
    );

    await request.addStream(streamUpload);

    await request.close();
  }
}
