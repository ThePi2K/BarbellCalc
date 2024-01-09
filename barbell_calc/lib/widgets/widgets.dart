import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: Text(errorMessage),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
