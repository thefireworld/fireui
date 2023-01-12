import 'dart:convert';

import 'package:fire/env.dart';
import 'package:fire/main.dart';
import 'package:fire/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';

int _step = 0;
final TextEditingController _emailController = TextEditingController();

class _LoggedOut extends StatelessWidget {
  const _LoggedOut({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Text(
          "Fire에 로그인하세요!",
          style: text(fontSize: 23, bold: true),
        ),
        IconButton(
          onPressed: () {
            _step = 1;
            rebuildController.rebuild();
          },
          icon: const Icon(Iconsax.login),
        ),
      ],
    );
  }
}

class _Login extends StatelessWidget {
  const _Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Text(
            "이메일 주소를 입력해주세요. ",
            style: text(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Form(
            autovalidateMode: AutovalidateMode.always,
            child: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null) {
                  return '올바른 이메일을 입력해주세요.';
                }

                if (value.endsWith("@gmail.com") ||
                    value.endsWith("@kakao.com")) {
                  Future.delayed(const Duration(milliseconds: 1), () {
                    _step = 2;
                    rebuildController.rebuild();
                  });
                  return null;
                } else {
                  return '사용이 불가능한 이메일입니다.';
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginIdentify extends StatefulWidget {
  const _LoginIdentify({Key? key}) : super(key: key);

  @override
  State<_LoginIdentify> createState() => _LoginIdentifyState();
}

class _LoginIdentifyState extends State<_LoginIdentify> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "이메일로 전송된 코드를 입력해주세요.",
          style: text(fontSize: 15),
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
      Uri.parse('$fireApiUrl/login/${_emailController.text}'),
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
        } else {
          EasyLoading.showToast("로그인 코드가 잘못되었습니다.");
        }

        rebuildController.rebuild();
        _step = 0;
      },
    );
  }
}

class LoggedOutBody extends StatefulWidget {
  const LoggedOutBody({Key? key}) : super(key: key);

  @override
  State<LoggedOutBody> createState() => _LoggedOutBodyState();
}

class _LoggedOutBodyState extends State<LoggedOutBody> {
  late List<Widget> body;

  @override
  void initState() {
    body = const [
      _LoggedOut(),
      _Login(),
      _LoginIdentify(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: body[_step],
    );
  }
}
