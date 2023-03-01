import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../fireui.dart';

export 'rebuild.dart';
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
        "authorization": "Bearer ${apiKey}",
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

Uint8List encryptFile(Uint8List data, String password) {
  return data;
}

Uint8List decryptFile(Uint8List data, String password) {
  return data;
}

TextStyle text({double? fontSize, bool bold = false}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontFamily: "Pretendard",
  );
}
