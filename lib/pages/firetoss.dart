import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:drag_and_drop_windows/drag_and_drop_windows.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire/env.dart';
import 'package:fire/main.dart';
import 'package:fire/utils.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:hovering/hovering.dart';
import 'package:internet_file/internet_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrscan/qrscan.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

void initializeFireToss() {
  socket.on('tossed', (data) async {
    Directory directory;
    if (Platform.isAndroid || Platform.isIOS) {
      directory = (await DownloadsPathProvider.downloadsDirectory)!;
    } else {
      directory = (await getDownloadsDirectory())!;
    }
    final clickedButton = await FlutterPlatformAlert.showCustomAlert(
      windowTitle: '다른 기기에서 파일이 전송되었습니다.',
      text: '파일 이름: (알수없음)',
      positiveButtonTitle: "승인",
      negativeButtonTitle: "거부",
    );
    if (clickedButton == CustomButton.positiveButton) {
      for (var value in data) {
        List<String> spl = value.split('/');
        String name = spl[spl.length - 1];
        name = name.substring(14);
        if (Platform.isAndroid || Platform.isIOS) {
          await FlutterDownloader.enqueue(
            url: "$value",
            savedDir: directory.path,
            fileName: name,
            showNotification: true,
            openFileFromNotification: true,
          );
        } else {
          final Uint8List bytes = await InternetFile.get("$value",
              progress: (receivedLength, contentLength) {});
          File("${directory.path}/$name")
            ..createSync(recursive: true)
            ..writeAsBytesSync(decryptFile(bytes, "awesome password").toList());
        }
      }
    }
  });
}

class FireTossPage extends StatefulWidget {
  final List<String> defaultFiles;

  const FireTossPage({this.defaultFiles = const [], Key? key})
      : super(key: key);

  @override
  State<FireTossPage> createState() => _FireTossPageState();
}

class _FireTossPageState extends State<FireTossPage>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  late StreamSubscription subscription;
  List<String> files = [];
  Map<String, String> devices = {};
  bool isDeviceFound = false;

  @override
  void initState() {
    files.addAll(widget.defaultFiles);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

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
  void dispose() {
    if (Platform.isWindows) {
      subscription.cancel();
    }

    super.dispose();
  }

  List<Bubble> bubbles() {
    List<Bubble> widgets = [];
    devices.forEach((key, value) {
      widgets.add(
        Bubble(
          title: key,
          iconColor: Colors.black,
          bubbleColor: Colors.white,
          icon: Icons.devices,
          titleStyle: const TextStyle(fontSize: 16, color: Colors.black),
          onPress: () async {
            await sendFile(context, value);
            if (!mounted) return;
            Navigator.pop(context);
          },
        ),
      );
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
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
        log(value.toString());
        setState(() {});
      });
      isDeviceFound = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Toss하기")),
      // backgroundColor: Colors.white,
      floatingActionButton: FloatingActionBubble(
        items: [
          ...bubbles(),
          Bubble(
            title: "디바이스 찾기..",
            iconColor: Colors.black,
            bubbleColor: Colors.white,
            icon: Icons.devices,
            titleStyle: const TextStyle(fontSize: 16, color: Colors.black),
            onPress: () async {
              _animationController.reverse();
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
            },
          ),
        ],

        // animation controller
        animation: _animation,

        // On pressed change animation state
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),

        iconColor: Colors.blue,
        iconData: Icons.send,
        backGroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () async {
          FilePickerResult? result =
              await FilePicker.platform.pickFiles(allowMultiple: true);

          if (result != null) {
            setState(() {
              files.addAll(result.paths.map((e) => e!));
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: files.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 700 ? 3 : 7,
              crossAxisSpacing: 0,
            ),
            itemBuilder: (BuildContext context, int index) {
              Widget widget = Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FileIcon(
                    files[index],
                    size: 100,
                  ),
                  Text(
                    File(files[index])
                        .path
                        .replaceAll(File(files[index]).parent.path, "")
                        .substring(1),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
              widget = HoverWidget(
                hoverChild: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    widget,
                    Positioned(
                      top: 30,
                      right: 20,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            files.removeAt(index);
                          });
                        },
                        child: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                onHover: (PointerEnterEvent event) {},
                child: widget,
              );
              // if (index < 10 /*MAX FILES*/) {
              return widget;
              // } else {
              //   return Tooltip(
              //     message: "한번에 최대 10개의 파일을 보낼 수 있습니다.",
              //     child: Stack(
              //       alignment: AlignmentDirectional.center,
              //       children: [
              //         widget,
              //         const Image(
              //           image: Svg(
              //             "assets/icons8-error.svg",
              //             color: Colors.red,
              //           ),
              //           width: 75,
              //         ),
              //       ],
              //     ),
              //   );
              // }
            },
          ),
        ),
      ),
    );
  }

  Future<void> sendFile(BuildContext context, String address) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var dio = Dio();
    List<MultipartFile> uploadFiles = [];
    for (var path in files) {
      File file = File(path);
      uploadFiles.add(MultipartFile.fromBytes(
          encryptFile(file.readAsBytesSync(), "awesome password"),
          filename: file.path.replaceFirst(file.parent.path, "").substring(1)));
    }

    var formData = FormData.fromMap({'files': uploadFiles});
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(
      max: 100,
      msg: 'Sending files...',
    );
    try {
      final response = await dio.post(
        '$fireApiUrl/file',
        data: formData,
        onSendProgress: (rec, total) {},
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
      int endTime = DateTime.now().millisecondsSinceEpoch;
      DateTime time = DateTime.fromMillisecondsSinceEpoch(endTime - startTime);
      log("걸린시간: ${time.hour - 9}시간 ${time.minute}분 ${time.second}초");
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
