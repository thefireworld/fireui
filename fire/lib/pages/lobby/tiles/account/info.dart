import 'package:fire/utils/utils.dart';
import 'package:flutter/material.dart';

class AccountInfoBody extends StatefulWidget {
  const AccountInfoBody({Key? key}) : super(key: key);

  @override
  State<AccountInfoBody> createState() => _AccountInfoBodyState();
}

class _AccountInfoBodyState extends State<AccountInfoBody> {
  bool isRenaming = false;
  TextEditingController renameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
  }
}
