import 'package:flutter/material.dart';

class DialogUtils {
  static void showErrorDialog(BuildContext context, String title, String message, {String buttonText = 'OK'}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  static void showConfirmationDialog(
      BuildContext context,
      String title,
      String message, {
        required VoidCallback onConfirm,
        String confirmText = 'Confirm',
        String cancelText = 'Cancel',
      }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}
