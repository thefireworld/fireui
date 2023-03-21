import 'package:flutter/material.dart';

import '../utils/utils.dart';

class SidebarItem {
  Widget? icon;
  String title;

  SidebarItem({this.icon, required this.title});
}

class FireSidebar extends StatefulWidget {
  final List<SidebarItem> items;

  const FireSidebar({required this.items, Key? key}) : super(key: key);

  @override
  State<FireSidebar> createState() => _FireSidebarState();
}

class _FireSidebarState extends State<FireSidebar> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(fontSize: 25);
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10),
      child: Row(
        children: [
          Container(
            width: 150,
            height: double.infinity,
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, i) {
                SidebarItem item = widget.items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5, right: 10),
                  child: Stack(
                    children: [
                      if (index == i)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 7),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              color: Color(0xFFB9CDFF),
                            ),
                            width: 3,
                            height: 30,
                          ),
                        ),
                      ListTile(
                        shape:
                            RoundedRectangleBorder(borderRadius: borderRadius),
                        leading: item.icon,
                        title: Text(
                          item.title,
                          style: style.copyWith(color: Colors.black),
                        ),
                        enabled: index != i,
                        hoverColor:
                            index != i ? FireColors.hoverColor : Colors.white,
                        splashColor: Colors.transparent,
                        onTap: () {},
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            width: .5,
            height: double.infinity,
            color: FireColors.borderColor,
          )
        ],
      ),
    );
  }
}
