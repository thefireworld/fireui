import 'package:fire/main.dart';
import 'package:fire/pages/lobby/widgets/account.dart';
import 'package:fire/pages/lobby/widgets/firetoss.dart';
import 'package:fire/utils/utils.dart';
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
      appBar: AppBar(
        title: Text(
          "Fire",
          style: text(fontSize: 35, bold: true),
        ),
      ),
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const MessageHomePage(),
      //       ),
      //     );
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Iconsax.message),
      // ),
      body: SafeArea(
        child: SizedBox.expand(
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
    );
  }

  Widget make(Widget w) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
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
  final Widget? trailing;

  const TitleBar(this.title, this.trailing, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 300,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(title, style: text(fontSize: 27)),
            Positioned(
              right: 10,
              child: trailing!,
            ),
          ],
        ),
      ),
    );
  }
}
