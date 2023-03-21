library fireui;

import 'package:platform_device_id/platform_device_id.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'utils/utils.dart';

export 'titlebar.dart';
export 'widgets/widgets.dart';
export 'utils/utils.dart';

late Socket server;
late Socket service;

typedef dynamic EventHandler<T>(T data);

String? apiKey;

Future<void> initialize({String? newKey}) async {
  apiKey = newKey;
  await connectToFireServer();
}

Future<void> connectToFireServer() async {
  String deviceId = (await PlatformDeviceId.getDeviceId)!.trim();

  server = io(
    'http://$fireServerUrl',
    OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
        .build(),
  );
  service = io(
    'http://localhost:54132',
    OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
        .build(),
  );

  server.onConnect((_) {
    server.emit('connect server', {"address": deviceId});
  });

  server.on("new address", (data) {
    address = data;
  });
  // server.on("connect approved", (data) {
  //   if (FireAccount.current != null) {
  //     server.emit("login", FireAccount.current!.uid);
  //   }
  // });
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
