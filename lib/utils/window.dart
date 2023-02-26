import 'package:window_manager/window_manager.dart';

class FireWindowListener with WindowListener {
  @override
  void onWindowBlur() {
    windowManager.hide();
  }
}
