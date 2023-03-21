import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/utils.dart';

class FireButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool disabled;
  final bool primary;
  final String text;

  const FireButton({
    required this.onPressed,
    this.disabled = false,
    this.primary = false,
    this.text = "Button",
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle style = const TextStyle(fontSize: 25);
    Size textSize = calcTextSize(text, style);
    return Container(
      width: max(textSize.width + 40, 130),
      height: textSize.height + 10,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: FireColors.borderColor, width: borderSize),
        color: Colors.white,
        image: primary
            ? const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/fire_gradient.png"),
              )
            : null,
      ),
      child: Stack(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (disabled) return;

                onPressed();
              },
              child: Center(
                child: Text(
                  text,
                  style: style,
                ),
              ),
            ),
          ),
          if (disabled)
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: FireColors.disabledFilterColor,
              ),
            ),
        ],
      ),
    );
  }
}
