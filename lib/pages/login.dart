import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fire/env.dart';
import 'package:fire/pages/lobby/lobby.dart';
import 'package:fire/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pinput/pinput.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginCodePage extends StatefulWidget {
  const LoginCodePage({Key? key}) : super(key: key);

  @override
  State<LoginCodePage> createState() => _LoginCodePageState();
}

class _LoginCodePageState extends State<LoginCodePage> {
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
              "로그인 코드를 입력해주세요.",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 10),
            codeInput(),
            const SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      title: const Text("어떻게 로그인하나요?"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("1. 스마트폰, Mac에서 Fire를 설치한 후 로그인합니다."),
                          Text("2. Account 위젯에 오른쪽 상단 로그인 버튼을 누릅니다."),
                          Text("3. 화면에 표시되는 코드를 입력해주세요."),
                        ],
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text("확인"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("어떻게 로그인하나요?"),
            ),
            MaterialButton(
              onPressed: () async {
                if (!await launchUrl(Uri.parse("thefire-world.web.app"))) {
                  EasyLoading.showError("웹페이지를 여는데 실패했습니다.");
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("웹에서 코드 받기"),
                  Chip(
                    padding: EdgeInsets.all(0),
                    label: Text(
                      'Beta',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
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
      onCompleted: (code) async {
        EasyLoading.show();
        Response response;
        try {
          response = await Dio().post(
            '$fireApiUrl/logincode/$code',
            options: Options(
              headers: {
                "authorization": "Bearer ${Env.fireApiKey}",
              },
              sendTimeout: 1000,
            ),
          );
        } catch (e) {
          EasyLoading.showToast("서버와 연결할 수 없어요.");
          log(e.toString());
          return;
        }

        if (response.data["userUid"] != null) {
          FireAccount.current =
              await FireAccount.getFromUid(response.data["userUid"]);
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

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 254,
          child: SocialLoginButton(
            buttonType: SocialLoginButtonType.google,
            onPressed: () async {
              EasyLoading.show();

              final credential = await signInWithGoogle();
              if (credential.credential != null) {
                if (kIsWeb) {
                  if (!mounted) return;
                  showLoginCode(context, credential.user!.uid);
                  return;
                }

                FireAccount.current =
                    await FireAccount.getFromUid(credential.user!.uid);

                if (FireAccount.current == null) {
                  EasyLoading.showToast("서버와 연결할 수 없어요.");
                } else {
                  EasyLoading.showToast("로그인 완료: ${FireAccount.current!.name}");
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LobbyPage(),
                    ),
                  );
                }
                return;
              }
              EasyLoading.showToast("로그인에 실패했습니다.");
            },
          ),
        ),
      ),
    );
  }
}
