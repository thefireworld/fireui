import 'dart:io';
import 'dart:typed_data';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:fire/pages/firetoss.dart';
import 'package:fire/pages/lobby.dart';
import 'package:fire/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:internet_file/internet_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

late Socket socket;

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: ".env");

  socket = io(
    'http://59.11.174.229:3000',
    OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
        .build(),
  );

  String address = await getAddress();
  socket.onConnect((_) {
    socket.emit('login', {"address": address});
  });

  socket.on('duplicate address', (data) async {
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: const Text("경고!"),
    //       content: const SingleChildScrollView(
    //         child: Text("다른 기기에서 사용하고있는 주소입니다. 주소를 변경합니다."),
    //       ),
    //       actions: <Widget>[
    //         ElevatedButton(
    //           child: const Text('OK'),
    //           onPressed: () async {
    //             Navigator.pop(context);
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
    socket.disconnect();
    address = await getAddress(reset: true);
    socket.connect();
  });

  if (arguments.isNotEmpty) {
    if (arguments[0] == "toss") {
      if (arguments.length > 1) {
        runApp(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
            ),
            home: FireTossPage(
              defaultFiles: [
                arguments[1],
              ],
            ),
          ),
        );
        return;
      }
    }
  }

  socket.on('tossed', (data) async {
    Directory directory;
    if (Platform.isAndroid || Platform.isIOS) {
      directory = (await DownloadsPathProvider.downloadsDirectory)!;
    } else {
      directory = (await getDownloadsDirectory())!;
    }
    List<String> spl = data[0].split('/');
    String name = spl[spl.length - 1];
    name = name.substring(0, name.length - 13);
    final clickedButton = await FlutterPlatformAlert.showCustomAlert(
      windowTitle: '다른 기기에서 파일이 전송되었습니다.',
      text: '파일 이름: $name',
      positiveButtonTitle: "승인",
      negativeButtonTitle: "거부",
    );
    if (clickedButton == CustomButton.positiveButton) {
      final Uint8List bytes = await InternetFile.get("http://${data[0]}",
          progress: (receivedLength, contentLength) {
        final percentage = receivedLength / contentLength * 100;
      });
      File("${directory.path}/$name")
        ..createSync(recursive: true)
        ..writeAsBytesSync(decryptFile(bytes, "awesome password").toList());
    }
  });

  runApp(
    MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LobbyPage(),
    ),
  );

  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}
