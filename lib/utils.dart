import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';

String address = "err";

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
