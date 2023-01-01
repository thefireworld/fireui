import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fire/main.dart';
import 'package:fire/utils/server.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../env.dart';

export 'server.dart';
export 'textformatter.dart';

String address = "err";

class FireAccount {
  static FireAccount? _current;

  final String uid;
  String _name;

  FireAccount._(this.uid, this._name);

  static FireAccount? get current => _current;

  String get name => _name;

  set name(String newName) {
    http.post(
      Uri.parse('$fireApiUrl/user/$uid/update/name'),
      body: newName,
      headers: {
        "authorization": "Bearer ${Env.fireApiKey}",
      },
    );
    _name = newName;
  }

  static set current(FireAccount? account) {
    _current = account;
    if (account != null) {
      socket.emit("login", account.uid);
    }
  }

  static Future<FireAccount?> getFromUid(String uid) async {
    dynamic response = await http.get(
      Uri.parse('$fireApiUrl/user/$uid'),
    );
    response = jsonDecode(response.body);
    return FireAccount._(response["uid"], response["name"]);
  }
}

Future<String?> getDeviceName() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.utsname.machine;
  } else if (Platform.isLinux) {
    LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
    return linuxInfo.prettyName;
  } else if (Platform.isMacOS) {
    MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;
    return macOsInfo.computerName;
  } else if (Platform.isWindows) {
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
    return windowsInfo.computerName;
  } else {
    return null;
  }
}

Uint8List encryptFile(Uint8List data, String password) {
  return data;
}

Uint8List decryptFile(Uint8List data, String password) {
  return data;
}

TextStyle text({double? fontSize, bool bold = false}) {
  return GoogleFonts.signikaNegative(
    textStyle: TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}

String? validateEmail(String? value) {
  if (value == null) {
    return '올바른 이메일을 입력해주세요.';
  }

  if (value.endsWith("@gmail.com")) {
    return null;
  } else {
    return '사용이 불가능한 이메일입니다.';
  }
}
