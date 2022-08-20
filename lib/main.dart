import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:fire/pages/firetoss.dart';
import 'package:fire/pages/lobby.dart';
import 'package:fire/utils.dart';
import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

late Socket socket;

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  socket = io(
    'http://59.11.174.229:3000',
    OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
        .build(),
  );

  String address = await getAddress();
  socket.onConnect((_) {
    socket.emit('login', {"address": address});
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
    for (var value in data) {
      // await FlutterDownloader.enqueue(
      //   url: value,
      //   savedDir: directory.path,
      //   showNotification: true,
      //   openFileFromNotification: true,
      // );
      final Uint8List bytes = await InternetFile.get(
        "http://$value",
        progress: (receivedLength, contentLength) {
          final percentage = receivedLength / contentLength * 100;
        },
      );
      List<String> spl = value.split('/');
      String name = spl[spl.length - 1];
      name = name.substring(0, name.length - 13);
      File("${directory.path}/$name")
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes.toList());
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
