import 'package:flutter/material.dart';

import '../utils/utils.dart';

class FireTextField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const FireTextField({
    this.controller,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<FireTextField> createState() => _FireTextFieldState();
}

class _FireTextFieldState extends State<FireTextField> {
  bool selected = false;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(fontSize: 20);
    return Container(
      width: 250,
      height: 33 + 15,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: FireColors.borderColor, width: borderSize),
        color: Colors.white,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.text,
        child: GestureDetector(
          onTap: () => selected = true,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: TextField(
                controller: widget.controller,
                scrollController: _scrollController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                style: style,
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
