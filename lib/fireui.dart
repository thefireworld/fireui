library fireui;

import 'dart:async';
import 'dart:developer';

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

Future<void> initialize(
    {String? newKey, RebuildController? rebuildController}) async {
  apiKey = newKey;
  _rebuildController = rebuildController;

  await connectToFireServer();
}

Future<void> connectToFireServer() async {
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
  await serverConnecting.future;

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
  await serviceConnecting.future;

  server.on("new address", (data) {
    address = data;
  });
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
