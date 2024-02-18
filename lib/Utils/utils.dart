import 'package:flutter/material.dart';

class Utils {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.deepOrangeAccent,
          content: Text(message), duration: const Duration(milliseconds: 500)),
    );
  }
}
