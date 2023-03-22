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
    Size textSize = calcTextSize(text, FireStyles.smallHeaderStyle);
    return Container(
      width: max(textSize.width + 40, 100),
      height: textSize.height + 10,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: FireColors.borderColor, width: .5),
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
                  style: FireStyles.smallHeaderStyle,
                ),
              ),
            ),
          ),
          if (disabled)
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: FireColors.disabledFilterColor,
              ),
            ),
        ],
      ),
    );
  }
}
