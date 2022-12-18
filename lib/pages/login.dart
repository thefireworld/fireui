import 'package:fire/widgets/login.dart';
import 'package:flutter/material.dart';

class LoginIdentifyPage extends StatefulWidget {
  final String emailAddress;

  const LoginIdentifyPage(this.emailAddress, {Key? key}) : super(key: key);

  @override
  State<LoginIdentifyPage> createState() => _LoginIdentifyPageState();
}

class _LoginIdentifyPageState extends State<LoginIdentifyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoginCode(widget.emailAddress),
      ),
    );
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
      return '사용이 불가능한 이메일입니다.';
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
