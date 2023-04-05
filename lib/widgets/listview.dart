import 'package:flutter/material.dart';

import 'bouncing.dart';
import 'listview_item.dart';

export 'listview_item.dart';

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

            Widget child = item.build(context, index == i);
            return item.isPressable
                ? BouncingWidget(
                    child: child,
                    onTap: () {
                      item.onTap?.call(() {
                        setState(() {
                          index = i;
                          if (widget.callback != null) widget.callback!(i);
                        });
                      });
                    },
                  )
                : child;
          },
        ),
      ),
    );
  }
}
