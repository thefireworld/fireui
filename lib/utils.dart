import 'dart:io';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

Future<String> getAddress() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey("address")) {
    String addressBuilder = "";
    if (Platform.isAndroid) {
      addressBuilder += "ARD";
    } else if (Platform.isFuchsia) {
      addressBuilder += "FSA";
    } else if (Platform.isIOS) {
      addressBuilder += "IOS";
    } else if (Platform.isLinux) {
      addressBuilder += "LNX";
    } else if (Platform.isMacOS) {
      addressBuilder += "MAC";
    } else if (Platform.isWindows) {
      addressBuilder += "WDS";
    }

    addressBuilder += "-";
    addressBuilder += (Random().nextInt(8999) + 1000).toString();
    addressBuilder += "-";
    addressBuilder += String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.codeUnitAt(Random().nextInt(26)),
      ),
    );
    prefs.setString("address", addressBuilder);
  }
  String address = prefs.getString("address")!;
  return address;
}
