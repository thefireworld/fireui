library fireui;

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:dart_app_data/dart_app_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'utils/utils.dart';

export 'pages/initialize.dart';
export 'titlebar.dart';
export 'utils/utils.dart';
export 'widgets/widgets.dart';

late Socket service;
bool serviceConnected = false;
final dotFireDirectory = AppData.findOrCreate('.fire');

typedef dynamic EventHandler<T>(T data);

String? apiKey;
RebuildController? _rebuildController;

enum InitializeStatus {
  success,
  differentVersion,
}

String FIRE_SETTINGS = "settings";
String FIRE_INSTALLER = "installer";
String FIRE_DINGDONG = "dongdong";
String FIRE_LOGIN = "login";

class FireUI {
  static Version? requiredServiceVersion;
  static Version? currentServiceVersion;

  static Future<InitializeStatus> initialize(List<String> arguments,
      {required String identifier, Version? requiredServiceVersion}) async {
    FireUI.requiredServiceVersion = requiredServiceVersion;

    await WindowsSingleInstance.ensureSingleInstance(arguments, identifier);

    if (requiredServiceVersion != null) {
      ProcessResult result = await Process.run(
        "${dotFireDirectory.directory.path}/service/fireservice.exe",
        ["--version"],
      );
      Version currentServiceVersion =
          Version.fromString(result.stdout.toString());
      FireUI.currentServiceVersion = currentServiceVersion;
      if (currentServiceVersion != requiredServiceVersion) {
        log("Programs and services have different versions.");
        return InitializeStatus.differentVersion;
      }
    }

    return InitializeStatus.success;
  }

  static Future<void> openFireProgram(String id) async {
    await Process.runSync(
      "${dotFireDirectory.directory.path}/$id/$id.exe",
      [],
    );
  }
}

void initialize({String? newKey, RebuildController? rebuildController}) {
  apiKey = newKey;
  _rebuildController = rebuildController;
}

void rebuild() {
  _rebuildController?.rebuild();
}

// Future<void> connectToFireServer({BuildContext? context}) async {
//   server = io(
//     'http://$fireServerUrl',
//     OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
//         .build(),
//   );

//   Completer<String> serverConnecting = Completer();

//   server.onConnect((_) async {
//     log("server Connected");
//     serverConnecting.complete(server.id);
//     // String deviceId = (await PlatformDeviceId.getDeviceId)!.trim();
//     server.emit('connect server', {"address": "deviceId"});
//     serverConnected = true;
//     _rebuildController?.rebuild();

//     if (serviceConnected) {
//       await FireAccount.isLoggedIn();
//       log(FireAccount.current.toString());
//       if (FireAccount.current != null) {
//         FireServer.send("login", FireAccount.current!.uid);
//       }
//     }
//   });
//   final snackBar = AnimatedSnackBar.material(
//     "Fire Server에 연결할 수 없습니다.",
//     type: AnimatedSnackBarType.warning,
//     desktopSnackBarPosition: DesktopSnackBarPosition.bottomCenter,
//     duration: Duration(hours: 10),
//   );
//   bool snackBarShown = false;
//   await serverConnecting.future.timeout(
//     Duration(seconds: 5),
//     onTimeout: () async {
//       if (context != null) {
//         snackBar.show(context);
//         snackBarShown = true;
//       }
//       return await serverConnecting.future;
//     },
//   );

//   if (snackBarShown) {
//     snackBar.remove();
//   }

//   server.on("new address", (data) {
//     address = data;
//   });
// }

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

    if (!serviceConnecting.isCompleted) serviceConnecting.complete(service.id);
  });

  service.on("version", (data) {
    FireUI.currentServiceVersion = Version.fromString(data);
  });

  service.on("serverConnected", (data) async {
    await FireAccount.isLoggedIn();
    if (FireAccount.current != null) {
      FireServer.send("login", FireAccount.current!.uid);
    }
  });

  await serviceConnecting.future.timeout(
    Duration(seconds: 3),
    onTimeout: () async {
      Process.start("${dotFireDirectory.directory.path}/service/start.bat", []);
      return await serviceConnecting.future;
    },
  );
}

class FireServer {
  static void onReceiveEvent(String event, EventHandler handler) {
    service.emit("serverOn", event);
    service.off("recieveEvent#$event");
    service.on("recieveEvent#$event", handler);
  }

  static void onReceiveEventOnce(String event, EventHandler handler) {
    service.emit("serverOnce", event);
    service.off("recieveEvent#$event");
    service.once("recieveEvent$event", handler);
  }

  static void send(String event, dynamic data) {
    service.emit("sendEventToServer", {"event": event, "data": data});
  }
}

class FireService {
  static void onConnected(EventHandler handler) {
    service.onConnect(handler);
  }

  static void onReceiveEvent(String event, EventHandler handler) {
    service.on(event, handler);
  }

  static void send(String event, dynamic data) {
    service.emit(event, data);
  }
}
