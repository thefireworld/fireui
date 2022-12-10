import 'dart:io';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:fire/pages/login.dart';
import 'package:fire/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:internet_file/internet_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:socket_io_client/socket_io_client.dart';

late Socket socket;

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (arguments.isNotEmpty) {
  //   if (arguments[0] == "toss") {
  //     if (arguments.length > 1) {
  //       runApp(
  //         MaterialApp(
  //           theme: ThemeData(
  //             useMaterial3: true,
  //           ),
  //           home: FireTossPage(
  //             defaultFiles: [
  //               arguments[1],
  //             ],
  //           ),
  //         ),
  //       );
  //       return;
  //     }
  //   }
  // }

  if (!kIsWeb) {
    await initializeSocket();
    initializeFireToss();
  }

  await Hive.initFlutter();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
    ),
    home: const LoginEmailPage(),
    builder: EasyLoading.init(),
  ));
}

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

Future<void> initializeSocket() async {
  String deviceId = (await PlatformDeviceId.getDeviceId)!.trim();

  socket = io(
    'http://$fireServerUrl',
    OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
        .build(),
  );

  socket.onConnect((_) {
    socket.emit('connect server', {"address": deviceId});
  });

  socket.on("new address", (data) {
    address = data;
  });
  socket.on("connect approved", (data) {
    if (FireAccount.current != null) {
      socket.emit("login", FireAccount.current!.uid);
    }
  });
}
