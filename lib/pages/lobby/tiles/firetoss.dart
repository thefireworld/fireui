import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:drag_and_drop_windows/drag_and_drop_windows.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

import '../lobby.dart';

Future<void> sendFile(BuildContext context, String address) async {
  var requestMultipart = http.MultipartRequest("POST", Uri.parse('uri'));
  for (var path in _FileListWidget.files) {
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

class _FileListWidget extends StatefulWidget {
  static const List<String> files = [];

  const _FileListWidget({Key? key}) : super(key: key);

  @override
  State<_FileListWidget> createState() => _FileListWidgetState();
}

class _FileListWidgetState extends State<_FileListWidget> {
  late StreamSubscription subscription;

  @override
  void initState() {
    if (Platform.isWindows) {
      subscription = dropEventStream.listen((paths) {
        setState(() {
          _FileListWidget.files.addAll(paths);
        });
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (var value in _FileListWidget.files) {
      List<String> spl = value.split("\\");
      String filename = spl[spl.length - 1];
      widgets.add(
        ListTile(
          leading: FileIcon(filename),
          title: SizedBox(
            height: 25,
            child: FittedBox(child: Text(filename)),
          ),
          subtitle: SizedBox(
            height: 20,
            child: FittedBox(child: Text(value.replaceAll(filename, ""))),
          ),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                _FileListWidget.files.remove(value);
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
                _FileListWidget.files.addAll(result.paths.map((e) => e!));
              });
            }
          },
        ),
      ),
    );
    return SingleChildScrollView(
      child: Column(children: widgets),
    );
  }
}

class _ToAccountWidget extends StatefulWidget {
  static String? toAddress;

  const _ToAccountWidget({Key? key}) : super(key: key);

  @override
  State<_ToAccountWidget> createState() => _ToAccountWidgetState();
}

class _ToAccountWidgetState extends State<_ToAccountWidget> {
  final TextEditingController _emailField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Text(
          "보낼 계정을 입력해주세요.",
          style: text(fontSize: 15),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              controller: _emailField,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              // validator: (value) => validateEmail(value),
            ),
          ),
        ),
      ],
    );
  }
}

class _FindDeviceWidget extends StatefulWidget {
  static String? toAddress;

  const _FindDeviceWidget({Key? key}) : super(key: key);

  @override
  State<_FindDeviceWidget> createState() => _FindDeviceWidgetState();
}

class _FindDeviceWidgetState extends State<_FindDeviceWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [], // TODO 디바이스 리스트 표시
    );
  }
}

class FireTossTile extends StatefulWidget {
  const FireTossTile({Key? key}) : super(key: key);

  @override
  State<FireTossTile> createState() => _FireTossTileState();
}

class _FireTossTileState extends State<FireTossTile> {
  late List<Widget> contents;
  int step = 0;

  @override
  void initState() {
    contents = [
      const _FileListWidget(),
      const _ToAccountWidget(),
      const _FindDeviceWidget(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          "FireToss",
          trailing: IconButton(
              onPressed: () {
                setState(() {
                  step++;
                  if (step == 3) {
                    sendFile(context, _FindDeviceWidget.toAddress!);
                  }
                });
              },
              icon: const Icon(Iconsax.send_2)),
        ),
        Expanded(
          child: contents[step],
        ),
      ],
    );
  }
}
