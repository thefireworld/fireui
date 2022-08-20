import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drag_and_drop_windows/drag_and_drop_windows.dart';
import 'package:file_icon/file_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fire/main.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/completed.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Toss하기")),
      // backgroundColor: Colors.white,
      floatingActionButton: FloatingActionBubble(
        items: [
          Bubble(
            title: "Sihu's Awesome Computer",
            iconColor: Colors.black,
            bubbleColor: Colors.white,
            icon: Icons.phone_android,
            titleStyle: const TextStyle(fontSize: 16, color: Colors.black),
            onPress: () {
              _animationController.reverse();
              List<String> fileData = [];
              for (var file in files) {
                base64Encode(File(file).readAsBytesSync().toList());
              }
            },
          ),
          Bubble(
            title: "Sihu's Awesome Phone",
            iconColor: Colors.black,
            bubbleColor: Colors.white,
            icon: Icons.phone_android,
            titleStyle: const TextStyle(fontSize: 16, color: Colors.black),
            onPress: () async {
              _animationController.reverse();
              await sendFile(context);
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
              return Center(
                child: Column(
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
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> sendFile(BuildContext context) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    List<String> fileData = [];
    for (int i = 1; i <= files.length; i++) {
      String filePath = files[i - 1];
      var dio = Dio();
      var formData =
          FormData.fromMap({'file': await MultipartFile.fromFile(filePath)});
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(
        max: 100,
        msg: 'Sending files... ($i/${files.length})',
        completed: Completed(
          completedMsg: "Sending Completed! ($i/${files.length})",
          closedDelay: i == files.length ? 2500 : 0,
        ),
      );
      try {
        final response = await dio.post(
          'http://pc.iamsihu.wtf:3000/upload',
          data: formData,
          onSendProgress: (rec, total) {
            pd.update(value: ((rec.toDouble() / total) * 100).toInt());
          },
        );
        fileData.add(response.data["url"]);
        await Future.delayed(
            Duration(milliseconds: i == files.length ? 2500 : 0));
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
                    content: Text(
                        "오류가 발생했어요. (메시지: ${e.response!.data["message"]})"),
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
    socket.emit("toss", {
      "files": fileData,
      "receiverUserId": "a",
      "receiverDeviceName": "Sihu's Awesome Phone"
    });
    int endTime = DateTime.now().millisecondsSinceEpoch;
    DateTime time =
        DateTime.fromMillisecondsSinceEpoch(endTime - startTime - 2500);
    log("걸린시간: ${time.hour - 9}시간 ${time.minute}분 ${time.second}초");

    if (!mounted) return;
    Navigator.pop(context);
  }
}
