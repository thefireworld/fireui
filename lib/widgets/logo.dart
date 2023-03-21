import 'package:flutter/material.dart';

class FireLogo extends StatelessWidget {
  final LogoType type;
  final double size;

  const FireLogo({this.type = LogoType.logo, this.size = 50, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/${type.name}.png",
      height: size,
    );
  }
}

enum LogoType { logo, icon }
