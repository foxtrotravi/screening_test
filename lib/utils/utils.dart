import 'dart:html';
import 'package:fluttertoast/fluttertoast.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

void showToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    timeInSecForIosWeb: 3,
  );
}

void goFullScreen() {
  document.documentElement?.requestFullscreen();
}

String showTimer(int time) {
  final hh = (time ~/ 3600);
  final mm = (time % 3600) ~/ 60;
  final ss = ((time % 3600) % 60).toInt();
  return '${twoDigit(hh)}:${twoDigit(mm)}:${twoDigit(ss)}';
}

String twoDigit(int t) {
  return t < 10 ? '0$t' : '$t';
}
