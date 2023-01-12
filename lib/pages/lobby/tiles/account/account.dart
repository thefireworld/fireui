import 'package:fire/main.dart';
import 'package:fire/pages/lobby/lobby.dart';
import 'package:fire/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'info.dart';
import 'loggedOut.dart';

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
        if (FireAccount.current != null) const AccountInfoBody(),
        if (FireAccount.current == null) const LoggedOutBody(),
      ],
    );
  }
}
