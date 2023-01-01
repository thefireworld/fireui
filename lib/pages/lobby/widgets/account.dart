import 'package:fire/main.dart';
import 'package:fire/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../lobby.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({Key? key}) : super(key: key);

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  bool isRenaming = false;
  TextEditingController renameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    socket.on("new address", (data) {
      setState(() {
        address = data;
      });
    });
  }

  @override
  void dispose() {
    socket.off("new address");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleBar(
          "Account",
          trailing: InkWell(
            onTap: () {
              setState(() {
                FireAccount.current = null;
              });
            },
            child: const Icon(Iconsax.logout),
          ),
        ),
        body(),
      ],
    );
  }

  Widget body() {
    if (FireAccount.current != null) {
      return Expanded(
        child: Column(
          children: [
            ListTile(
              leading: const Text("Name"),
              title: isRenaming
                  ? TextField(controller: renameController)
                  : Text(FireAccount.current!.name),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    if (isRenaming) {
                      FireAccount.current!.name = renameController.text;
                      isRenaming = false;
                    } else {
                      renameController.text = FireAccount.current!.name;
                      isRenaming = true;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Expanded(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              "Fire에 로그인하세요!",
              style: text(fontSize: 23, bold: true),
            ),
            IconButton(
              onPressed: () {}, // TODO: 로그인 기능
              icon: const Icon(Iconsax.login),
            ),
          ],
        ),
      );
    }
  }
}
