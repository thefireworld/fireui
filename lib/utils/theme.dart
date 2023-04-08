import 'package:flutter/material.dart';

class FireColors {
  static const borderColor = Color(0xFFBEBEBE);
  static const disabledFilterColor = Color(0xB3D9D9D9);
  static const hoverColor = Color(0xffdfdfdf);
}

class FireStyles {
  static const TextStyle titleStyle = const TextStyle(
    fontFamily: "Pretendard",
    fontSize: 30,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle headerStyle = const TextStyle(
    fontFamily: "Pretendard",
    fontSize: 25,
    color: Colors.black,
  );
  static const TextStyle smallHeaderStyle = const TextStyle(
    fontFamily: "Pretendard",
    fontSize: 20,
    color: Colors.black,
  );
  static const TextStyle hintStyle = const TextStyle(
    fontFamily: "Pretendard",
    fontSize: 20,
  );
  static const TextStyle contentStyle = const TextStyle(
    fontFamily: "Pretendard",
    fontSize: 15,
    color: Colors.black,
  );
}

final borderRadius = const BorderRadius.all(Radius.circular(20));

double borderSize = 1;
