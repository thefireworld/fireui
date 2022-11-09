import 'package:fire/main.dart';
import 'package:fire/pages/lobby/widgets/account.dart';
import 'package:fire/pages/lobby/widgets/firetoss.dart';
import 'package:fire/utils.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 25,
                runSpacing: 25,
                alignment: WrapAlignment.center,
                children: [
                  make(const AccountWidget()),
                  make(const FireTossWidget()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget make(Widget w) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: w,
    );
  }
}

class TitleBar extends StatelessWidget {
  final String title;
  final Widget leading;
  final Widget? trailing;

  const TitleBar(this.title, this.leading, this.trailing, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(fontSize: 27),
        ),
        trailing: trailing,
      ),
    );
  }
}
