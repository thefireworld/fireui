import 'package:fire/main.dart';
import 'package:fire/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../lobby.dart';
import 'loggedOut.dart';

class _AccountInfoBody extends StatefulWidget {
  const _AccountInfoBody({Key? key}) : super(key: key);

  @override
  State<_AccountInfoBody> createState() => _AccountInfoBodyState();
}

class _AccountInfoBodyState extends State<_AccountInfoBody> {
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

class AccountTile extends StatefulWidget {
  const AccountTile({Key? key}) : super(key: key);

  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {
  late List<Widget> body;

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
        if (FireAccount.current != null) const _AccountInfoBody(),
        if (FireAccount.current == null) const LoggedOutBody(),
      ],
    );
  }
}
