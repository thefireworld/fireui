import 'dart:convert';

import 'package:http/http.dart' as http;

import '../fireui.dart';

class FireAccount {
  final String uid;
  String _name;

  FireAccount._(this.uid, this._name);

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

  static Future<FireAccount?> getFromUid(String uid) async {
    dynamic response = await http.get(
      Uri.parse('$fireApiUrl/user/$uid'),
    );
    response = jsonDecode(response.body);
    return FireAccount._(response["uid"], response["name"]);
  }
}

Future<String?> sendAuthEmail(String emailAddress) async {
  // TODO
  service.emit("sendAuthEmail", emailAddress);
  String? authCode;
  service.once("authEmailSent", (data) {
    authCode = data;
  });

  return authCode;
}

Future<FireAccount?> login(String authCode, String loginCode) async {
  // TODO
  service.emit("login", {"authCode": authCode, "loginCode": loginCode});
  String? uid;
  service.once("logged in", (data) {
    uid = data;
  });

  return await FireAccount.getFromUid(uid!);
}
