import 'package:flutter/material.dart';

import '../utils/utils.dart';

typedef SelectedItemChangedCallback = void Function(int index);

abstract class AbstractListViewItem {
  Widget build(BuildContext context, bool isSelected, VoidCallback onSelected);
}

class ListViewTitle extends AbstractListViewItem {
  Widget? icon;
  String title;
  Widget? trailing;

  ListViewTitle({this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context, bool isSelected, VoidCallback onSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 10),
      child: Column(
        children: [
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            leading: icon,
            title: Text(
              title,
              style: FireStyles.titleStyle,
            ),
            trailing: trailing,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: FireColors.borderColor,
            ),
            width: MediaQuery.of(context).size.width - 20,
            height: .5,
          ),
        ],
      ),
    );
  }
}

class ListViewItem extends AbstractListViewItem {
  Widget? icon;
  String title;
  VoidCallback? customCallback;
  bool isSelectable;

  ListViewItem(
      {this.icon,
      required this.title,
      this.customCallback,
      this.isSelectable = true});

  @override
  Widget build(BuildContext context, bool isSelected, VoidCallback onSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, right: 10),
      child: Stack(
        children: [
          if (isSelected)
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
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            leading: icon,
            title: Text(
              title,
              style: FireStyles.headerStyle,
            ),
            enabled: isSelectable,
            hoverColor: !isSelected ? FireColors.hoverColor : Colors.white,
            splashColor: Colors.transparent,
            onTap: () {
              if (customCallback == null) {
                if (isSelectable) {
                  onSelected();
                }
              } else {
                customCallback!();
              }
            },
          )
        ],
      ),
    );
  }
}

class ListViewOption extends AbstractListViewItem {
  Widget? icon;
  String title;
  Widget? trailing;

  ListViewOption({this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context, bool isSelected, VoidCallback onSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, right: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        leading: icon,
        title: Text(
          title,
          style: FireStyles.headerStyle.copyWith(color: Colors.black),
        ),
        trailing: trailing,
      ),
    );
  }
}

class ListViewSpacer extends AbstractListViewItem {
  @override
  Widget build(BuildContext context, bool isSelected, VoidCallback onSelected) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 10, top: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: FireColors.borderColor,
        ),
        width: MediaQuery.of(context).size.width - 20,
        height: 3,
      ),
    );
  }
}

class FireListView extends StatefulWidget {
  final List<AbstractListViewItem> items;
  final SelectedItemChangedCallback? callback;

  const FireListView({
    required this.items,
    this.callback,
    Key? key,
  }) : super(key: key);

  @override
  State<FireListView> createState() => _FireListViewState();
}

class _FireListViewState extends State<FireListView> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10),
      child: SizedBox(
        width: 250,
        height: double.infinity,
        child: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, i) {
            AbstractListViewItem item = widget.items[i];
            return item.build(context, index == i, () {
              setState(() {
                index = i;
                if (widget.callback != null) widget.callback!(i);
              });
            });
          },
        ),
      ),
    );
  }
}
