import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;

  LoadingButton({required this.isLoading, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator()
        : ElevatedButton(onPressed: onPressed, child: Text(text));
  }
}
