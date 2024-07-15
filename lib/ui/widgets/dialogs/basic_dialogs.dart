import 'package:flutter/cupertino.dart';

void showErrorMessage(BuildContext context, String message) => showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [CupertinoDialogAction(child: const Text('OK'), onPressed: () => Navigator.of(context).pop())],
      ),
    );
