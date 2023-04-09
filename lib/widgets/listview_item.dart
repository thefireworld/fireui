import 'package:fireui/fireui.dart';
import 'package:flutter/material.dart';

typedef SelectedItemChangedCallback = void Function(int index);
typedef OnTapCallback = void Function(VoidCallback onSelected);

abstract class AbstractListViewItem {
  bool isPressable = false;
  OnTapCallback? onTap;

  AbstractListViewItem(this.isPressable, this.onTap);

  Widget build(BuildContext context, bool isSelected);
}

class ListViewTitle extends AbstractListViewItem {
  Widget? icon;
  String title;
  Widget? trailing;

  ListViewTitle({this.icon, required this.title, this.trailing})
      : super(false, (_) {});

  @override
  Widget build(BuildContext context, bool isSelected) {
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

  ListViewItem({
    this.icon,
    required this.title,
    this.customCallback,
    this.isSelectable = true,
    bool isPressable = false,
  }) : super(isPressable, (VoidCallback onSelected) {
          if (customCallback != null) {
            customCallback();
          }
          if (isSelectable) {
            onSelected();
          }
        });

  @override
  Widget build(BuildContext context, bool isSelected) {
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

  ListViewOption({
    this.icon,
    required this.title,
    this.trailing,
    bool isPressable = false,
  }) : super(isPressable, (_) {});

  @override
  Widget build(BuildContext context, bool isSelected) {
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
  ListViewSpacer() : super(false, (_) {});

  @override
  Widget build(BuildContext context, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: FireColors.borderColor,
        ),
        width: MediaQuery.of(context).size.width - 20,
        height: 2,
      ),
    );
  }
}
