import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fire/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'env.dart';

String address = "err";

String fireApiUrl = "http://pc.iamsihu.wtf:3000";
String fireServerUrl = "pc.iamsihu.wtf:4000";
bool fireServerConnected = false;

class FireAccount {
  static FireAccount? _current;

  final String uid;
  String _name;

  FireAccount._(this.uid, this._name);

  static FireAccount? get current => _current;

  String get name => _name;

  set name(String newName) {
    var dio = Dio();
    dio
        .post(
          '$fireApiUrl/user/$uid/name',
          data: {"newName": newName},
          options: Options(
            sendTimeout: 5000,
            headers: {
              "authorization": "Bearer ${Env.fireApiKey}",
            },
          ),
        )
        .then((value) {});
    _name = newName;
  }

  static set current(FireAccount? account) {
    _current = account;
    socket.emit("login", account?.uid);
  }

  static Future<FireAccount?> getFromUid(String uid) async {
    try {
      var dio = Dio();
      final response = await dio.get(
        '$fireApiUrl/user/$uid',
        options: Options(sendTimeout: 5000),
      );
      return FireAccount._(response.data["uid"], response.data["name"]);
    } catch (e) {
      if (e is DioError) {
        if (e.type == DioErrorType.sendTimeout) {
          return null;
        }
      }
    }
    return null;
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
  var dio = Dio();
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
              await dio.delete(
                '$fireApiUrl/logincode/$code',
                options: Options(
                  headers: {
                    "authorization": "Bearer ${Env.fireApiKey}",
                  },
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

Future<String> getNewLoginCode(String uid) async {
  var dio = Dio();
  final response = await dio.post(
    '$fireApiUrl/logincode/create/$uid',
    options: Options(
      headers: {
        "authorization": "Bearer ${Env.fireApiKey}",
      },
    ),
  );
  return response.data["code"];
}
