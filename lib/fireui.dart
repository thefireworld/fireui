library fireui;

import 'package:platform_device_id/platform_device_id.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'utils/utils.dart';

export 'titlebar.dart';
export 'utils/utils.dart';

late Socket socket;

typedef dynamic EventHandler<T>(T data);

String? apiKey;

void initialize({String? newKey}) {
  apiKey = newKey;
}

Future<void> connectToFireServer() async {
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

void onReceiveEvent(String event, EventHandler handler) {
  socket.on(event, (data) => handler(data));
}
