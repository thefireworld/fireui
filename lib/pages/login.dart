import 'dart:convert';
import 'dart:developer';

import 'package:fire/env.dart';
import 'package:fire/pages/lobby/lobby.dart';
import 'package:fire/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

class LoginIdentifyPage extends StatefulWidget {
  final String emailAddress;

  const LoginIdentifyPage(this.emailAddress, {Key? key}) : super(key: key);

  @override
  State<LoginIdentifyPage> createState() => _LoginIdentifyPageState();
}

class _LoginIdentifyPageState extends State<LoginIdentifyPage> {
  final _loginCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "이메일로 전송된 코드를 입력해주세요.",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: _sendMail(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  );
                } else {
                  return codeInput();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget codeInput() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(232, 232, 232, 1.0)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return Pinput(
      controller: _loginCodeController,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
        borderRadius: BorderRadius.circular(8),
      ),
      submittedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          color: const Color.fromRGBO(234, 239, 243, 1),
        ),
      ),
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: false,
      autofocus: true,
      inputFormatters: [
        UpperCaseTextFormatter(),
      ],
      onCompleted: (code) async {
        EasyLoading.show();
        http.Response response;
        try {
          response = await http.post(
            Uri.parse('$fireApiUrl/logincode/$code'),
            headers: {
              "authorization": "Bearer ${Env.fireApiKey}",
            },
          );
        } catch (e) {
          EasyLoading.showToast("서버와 연결할 수 없어요.");
          log(e.toString());
          return;
        }

        dynamic body = jsonDecode(response.body);
        if (body["userUid"] != null) {
          FireAccount.current = await FireAccount.getFromUid(body["userUid"]);
          if (FireAccount.current == null) {
            EasyLoading.showToast("서버와 연결할 수 없어요.");
            return;
          }
          EasyLoading.showToast("로그인 완료: ${FireAccount.current!.name}");
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LobbyPage(),
            ),
          );
        } else {
          _loginCodeController.clear();
          EasyLoading.showToast("로그인 코드가 잘못되었습니다.");
        }
      },
    );
  }

  Future<String> _sendMail() async {
    final response = await http.post(
      Uri.parse('$fireApiUrl/login/${widget.emailAddress}'),
    );
    return jsonDecode(response.body)["authCode"];
  }
}

class LoginEmailPage extends StatefulWidget {
  const LoginEmailPage({Key? key}) : super(key: key);

  @override
  State<LoginEmailPage> createState() => _LoginEmailPageState();
}

class _LoginEmailPageState extends State<LoginEmailPage> {
  final emailField = TextEditingController();

  String? validateEmail(String? value) {
    bool can = false;
    if (value == null) {
      return '올바른 이메일을 입력해주세요.';
    }

    if (value.endsWith("@gmail.com")) {
      Future.delayed(const Duration(milliseconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginIdentifyPage(value),
          ),
        );
      });
      return null;
    } else {
      return '이메일은 @gmail.com으로 끝나야합니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "이메일 주소를 입력해주세요. ",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: Form(
                    autovalidateMode: AutovalidateMode.always,
                    child: TextFormField(
                      controller: emailField,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => validateEmail(value),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
