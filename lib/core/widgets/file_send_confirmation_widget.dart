import 'package:flutter/material.dart';

class FileSendConfirmationWidget extends StatelessWidget {
  const FileSendConfirmationWidget({
    required this.widget,
    required this.onPressed,
    super.key,
  });

  final Widget widget;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 26.0, right: 10.0, left: 10.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.send),
          iconAlignment: IconAlignment.end,
          label: const Text('Send'),
        ),
      ),
      body: Center(child: widget),
    );
  }
}
