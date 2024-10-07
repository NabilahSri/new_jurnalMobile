import 'package:flutter/material.dart';

class ButtonCustom extends StatelessWidget {
  final VoidCallback onPressedAction;
  final Color? color;
  final bool? isLoading;
  final String text;
  final double? width;
  const ButtonCustom({
    super.key,
    this.color = Colors.blue,
    this.isLoading = false,
    required this.text,
    required this.onPressedAction,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
          onPressed: onPressedAction,
          style: ElevatedButton.styleFrom(
              backgroundColor: color, foregroundColor: Colors.white),
          child: isLoading!
              ? CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(text)),
    );
  }
}
