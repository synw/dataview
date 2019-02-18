import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void popOkMessage(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}

void popErrorMessage(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
