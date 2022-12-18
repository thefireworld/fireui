import 'package:fire/main.dart';
import 'package:fire/pages/login.dart';
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
          InkWell(
            onTap: () {
              FireAccount.current = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginEmailPage(),
                ),
              );
            },
            child: const Icon(Iconsax.logout),
          ),
        ),
        Expanded(
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
        ),
      ],
    );
  }
}
