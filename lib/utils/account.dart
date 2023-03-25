import 'dart:convert';

import 'package:http/http.dart' as http;

import '../fireui.dart';

typedef AuthEmailSentCallback = void Function(String authCode);
typedef LoggedInCallback = void Function(FireAccount account);
typedef LoginFailedCallback = void Function();

class FireAccount {
  static FireAccount? current;
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

  static Future<bool> isLoggedIn() async {
    FireService.send("getCurrentAccount", null);
    bool? isLoggedIn;
    service.once("currentAccount", (data) async {
      if (data["status"] == "loggedout") {
        isLoggedIn = false;
      } else if (data["status"] == "loggedin") {
        FireAccount.current = await FireAccount.getFromUid(data["uid"]);
      }
    });
    await Future.doWhile(() {
      if (isLoggedIn != null) {
        return false;
      } else {
        return true;
      }
    });
    return isLoggedIn!;
  }

  static Future<void> logout() async {
    current = null;
    FireService.send("logout", null);
  }
}

Future<void> sendAuthEmail(
    String emailAddress, AuthEmailSentCallback onAuthEmailSent) async {
  service.emit("sendAuthEmail", emailAddress);
  service.once("authEmailSent", (authCode) {
    onAuthEmailSent(authCode);
  });
}

Future<void> login(String authCode, String loginCode,
    LoggedInCallback onLoggedIn, LoginFailedCallback onLoginFailed) async {
  // TODO
  service.emit("login", {"authCode": authCode, "loginCode": loginCode});
  service.once("logged in", (uid) {
    if (uid != null) {
      FireAccount.getFromUid(uid).then((account) {
        onLoggedIn(account!);
      });
    } else {
      onLoginFailed();
    }
  });
}
