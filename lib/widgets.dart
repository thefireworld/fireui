import 'package:flutter/material.dart';

class PopupMenu extends StatelessWidget {
  final List<PopupMenuEntry> menuList;
  final Widget child;

  const PopupMenu({
    Key? key,
    required this.menuList,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      color: Colors.grey[300],
      offset: const Offset(0, 30),
      iconSize: 50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      itemBuilder: (context) => menuList,
      child: child,
    );
  }
}
