import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getFormattedDateTime(num dt, {String pattern = 'MMM dd yyyy'}) =>
    DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));


Future<bool> setTempUnitStatus(bool status) async {
  final pref = await SharedPreferences.getInstance();
  return pref.setBool('status', status);
}

Future<bool> getTempUnitStatus() async {
  final pref = await SharedPreferences.getInstance();
  return pref.getBool('status') ?? false;
}

showMsg(BuildContext context, String msg) =>
    ScaffoldMessenger
    .of(context)
    .showSnackBar(SnackBar(content: Text(msg)));