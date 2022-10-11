import 'package:fire/main.dart';
import 'package:fire/pages/firetoss.dart';
import 'package:fire/utils.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:dio/dio.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  String? deviceName;

  @override
  void initState() {
    getDeviceName().then((value) {
      setState(() {
        deviceName = value;
      });
    });

    socket.onConnect((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: () async {
          var dio = Dio();
          final response = await dio.post(
            'http://$fireServerUrl/logincode/$userUid',
            options: Options(
              headers: {
                "authorization": "Basic 6BB6EEF72AD57F14F4B59F2C1AE2F",
              },
            ),
          );
          int code = response.data["code"];
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("데스크톱에서 로그인"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("로그인코드: $code"),
                    ],
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () async {
                      Navigator.pop(context);
                      await dio.delete(
                        'http://$fireServerUrl/logincode/$code',
                        options: Options(
                          headers: {
                            "authorization":
                                "Basic 6BB6EEF72AD57F14F4B59F2C1AE2F",
                          },
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.account_circle),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FireTossPage(),
                  ),
                );
              },
              child: SizedBox(
                height: 272,
                width: 215,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: Colors.blue),
                      child: const Icon(
                        Icons.file_copy,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                    const Text(
                      "FireToss",
                      style: TextStyle(fontSize: 45),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
