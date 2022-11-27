import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fire/main.dart';
import 'package:fire/utils/server.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      Uri.parse('$fireApiUrl/user/$uid/name'),
      body: {"newName": newName},
      headers: {
        "authorization": "Bearer ${Env.fireApiKey}",
      },
    );
    _name = newName;
  }

  static set current(FireAccount? account) {
    _current = account;
    socket.emit("login", account?.uid);
  }

  static Future<FireAccount?> getFromUid(String uid) async {
    dynamic response = await http.get(
      Uri.parse('$fireApiUrl/user/$uid'),
    );
    response = jsonDecode(response.body);
    return FireAccount._(response["uid"], response["name"]);
  }
}

Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
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

void showLoginCode(BuildContext context, String uid) async {
  EasyLoading.show();
  String code = await getNewLoginCode(uid);
  EasyLoading.dismiss();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("데스크톱에서 로그인"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text("로그인코드: $code"),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () async {
              Navigator.pop(context);
              await http.delete(
                Uri.parse('$fireApiUrl/logincode/$code'),
              );
            },
          ),
        ],
      );
    },
  );
}

Future<String> getNewLoginCode(String uid) async {
  final response = await http.get(
    Uri.parse('$fireApiUrl/logincode/create/$uid'),
  );
  return jsonDecode(response.body)["code"];
}

TextStyle text({double? fontSize, bool bold = false}) {
  return GoogleFonts.signikaNegative(
    textStyle: TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  );
}
