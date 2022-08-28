import 'package:fire/main.dart';
import 'package:fire/pages/firetoss.dart';
import 'package:fire/utils.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({Key? key}) : super(key: key);

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  String? address;
  String? deviceName;

  @override
  void initState() {
    getAddress().then((value) {
      setState(() {
        address = value;
      });
    });
    getDeviceName().then((value) {
      setState(() {
        deviceName = value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: address == null
          ? Container()
          : IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("이 기기의 주소"),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: QrImage(
                                data: address!,
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                            Text(address!),
                            Text(deviceName != null ? deviceName! : ""),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('OK'),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.qr_code_2),
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
