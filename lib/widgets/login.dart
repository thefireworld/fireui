import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

import '../env.dart';
import '../pages/lobby/lobby.dart';
import '../utils/utils.dart';

class LoginCode extends StatefulWidget {
  final String emailAddress;

  const LoginCode(this.emailAddress, {Key? key}) : super(key: key);

  @override
  State<LoginCode> createState() => _LoginCodeState();
}

class _LoginCodeState extends State<LoginCode> {
  final _loginCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
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
              if (snapshot.data != null) {
                return codeInput(snapshot.data);
              } else {
                return const Text("Error");
              }
            }
          },
        ),
      ],
    );
  }

  Future<String?> _sendMail() async {
    final response = await http.post(
      Uri.parse('$fireApiUrl/login/${widget.emailAddress}'),
      headers: {
        "Authorization": "Bearer ${Env.fireApiKey}",
      },
    );
    return jsonDecode(response.body)["authCode"];
  }

  Widget codeInput(String authCode) {
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
          response = await http.get(
            Uri.parse('$fireApiUrl/login/$authCode/$code'),
            headers: {
              "authorization": "Bearer ${Env.fireApiKey}",
            },
          );
        } catch (e) {
          EasyLoading.showToast("서버와 연결할 수 없어요.");
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
}
