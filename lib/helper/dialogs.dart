import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,style: const TextStyle(color: Colors.black),),
        backgroundColor: Colors.greenAccent.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }

  static void showErrorSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg,style: const TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepOrange.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
