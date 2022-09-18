import 'dart:developer';
import 'dart:io';

import 'package:fire/pages/firetoss.dart';
import 'package:fire/pages/lobby.dart';
import 'package:fire/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:socket_io_client/socket_io_client.dart';

late Socket socket;

void callback(String id, DownloadTaskStatus status, int progress) {
  log("$status $progress");
}

void main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    await FlutterDownloader.initialize(
      debug: true,
      ignoreSsl: true,
    );
    FlutterDownloader.registerCallback(callback);

    socket = io(
      fireDirectServer,
      OptionBuilder().setTransports(['websocket']).build(),
    );
    String deviceId = (await PlatformDeviceId.getDeviceId)!.trim();
    socket.onConnect((_) {
      log("connected!");
      fireDirectConnected = true;
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

    runApp(MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LobbyPage(),
    ));
  }
}
