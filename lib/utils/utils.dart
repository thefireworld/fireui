import 'dart:typed_data';

import 'package:flutter/material.dart';

export 'rebuild.dart';
export 'server.dart';
export 'textformatter.dart';
export 'theme.dart';
export 'account.dart';

String address = "err";

Uint8List encryptFile(Uint8List data, String password) {
  return data;
}

Uint8List decryptFile(Uint8List data, String password) {
  return data;
}

TextStyle text({double? fontSize, bool bold = false}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    fontFamily: "Pretendard",
  );
}

Size calcTextSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}
