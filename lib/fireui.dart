library fireui;

import 'dart:async';
import 'dart:developer';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'utils/utils.dart';

export 'pages/initialize.dart';
export 'titlebar.dart';
export 'utils/utils.dart';
export 'widgets/widgets.dart';

late Socket server;
late Socket service;
bool serverConnected = false, serviceConnected = false;

typedef dynamic EventHandler<T>(T data);

String? apiKey;
RebuildController? _rebuildController;

void initialize({String? newKey, RebuildController? rebuildController}) {
  apiKey = newKey;
  _rebuildController = rebuildController;
}

void rebuild() {
  _rebuildController?.rebuild();
}

Future<void> connectToFireServer({BuildContext? context}) async {
  server = io(
    'http://$fireServerUrl',
    OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
        .build(),
  );

  Completer<String> serverConnecting = Completer();

  server.onConnect((_) {
    log("server Connected");
    // String deviceId = (await PlatformDeviceId.getDeviceId)!.trim();
    server.emit('connect server', {"address": "deviceId"});
    serverConnected = true;
    _rebuildController?.rebuild();
    serverConnecting.complete(server.id);
  });
  final snackBar = AnimatedSnackBar.material(
    "Fire Server에 연결할 수 없습니다.",
    type: AnimatedSnackBarType.warning,
    desktopSnackBarPosition: DesktopSnackBarPosition.bottomCenter,
    duration: Duration(hours: 10),
  );
  await serverConnecting.future.timeout(
    Duration(seconds: 5),
    onTimeout: () async {
      if (context != null) {
        snackBar.show(context);
      }
      return await serverConnecting.future;
    },
  );

  snackBar.remove();
  server.on("new address", (data) {
    address = data;
  });
}

Future<void> connectToFireService({BuildContext? context}) async {
  Completer<String> serviceConnecting = Completer();
  service = io(
    'http://localhost:24085',
    OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
        .build(),
  );
  service.onConnect((_) {
    log("service Connected");
    serviceConnected = true;
    _rebuildController?.rebuild();
    serviceConnecting.complete(service.id);
  });

  await serviceConnecting.future.timeout(
    Duration(seconds: 5),
    onTimeout: () async {
      if (context != null) {
        // TODO download and run fire service
      }
      return await serviceConnecting.future;
    },
  );
}

class FireServer {
  static void onReceiveEvent(String event, EventHandler handler) {
    server.on(event, (data) => handler(data));
  }

  static void send(String event, dynamic data) {
    server.emit(event, data);
  }
}

class FireService {
  static void onReceiveEvent(String event, EventHandler handler) {
    service.on(event, (data) => handler(data));
  }

  static void send(String event, dynamic data) {
    service.emit(event, data);
  }
}
