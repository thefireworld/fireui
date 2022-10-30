import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fire/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String address = "err";

String fireServerUrl = "pc.iamsihu.wtf:3000";
bool fireServerConnected = false;

class FireAccount {
  static FireAccount? _current;

  String uid;
  String name;

  FireAccount._(this.uid, this.name);

  static FireAccount? get current => _current;

  static set current(FireAccount? account) {
    _current = account;
    socket.emit("login", account?.uid);
  }

  static Future<FireAccount?> getFromUid(String uid) async {
    try {
      var dio = Dio();
      final response = await dio.get(
        'http://$fireServerUrl/user/$uid',
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
