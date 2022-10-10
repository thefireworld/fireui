import 'dart:developer';
import 'dart:io';

import 'package:fire/pages/firetoss.dart';
import 'package:fire/pages/login.dart';
import 'package:fire/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'firebase_options.dart';

late Socket socket;

void callback(String id, DownloadTaskStatus status, int progress) {
  log("$status $progress");
}

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (Platform.isAndroid || Platform.isIOS) {
  //   await FlutterDownloader.initialize(
  //     debug: true,
  //     ignoreSsl: true,
  //   );
  //   FlutterDownloader.registerCallback(callback);
  // }

  String deviceId = (await PlatformDeviceId.getDeviceId)!.trim();
  socket = io(
    'http://59.11.174.229:3000',
    OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
        .build(),
  );

  socket.onConnect((_) {
    log("connected!");
    fireServerConnected = true;
    socket.emit('login', {"address": deviceId});
  });

  socket.on("new address", (data) {
    address = data;
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

  initializeFireToss();

  await Hive.initFlutter();

  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LoginPage(),
    ));
  } else {
    runApp(MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LoginCodePage(),
    ));
  }
}
