import 'package:fire/utils.dart';
import 'package:flutter/material.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleBar(
          "Account",
          Icon(Icons.account_circle),
          null,
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
              ListTile(
                leading: const Text("기기 ID"),
                title: Text(address),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
