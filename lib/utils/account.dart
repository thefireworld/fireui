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
  service.emit("sendAuthEmail", emailAddress);
  String? authCode;
  service.on("authEmailSent", (data) {
    authCode = data;
    service.off("authEmailSent");
  });
  while (authCode == null);

  return authCode;
}

Future<FireAccount?> login(String authCode, String loginCode) async {
  service.emit("login", {"authCode": authCode, "loginCode": loginCode});
  String? uid;
  service.on("logged in", (data) {
    uid = data;
    service.off("logged in");
  });
  while (uid == null);

  return await FireAccount.getFromUid(uid!);
}
