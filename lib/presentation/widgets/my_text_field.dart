import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hint;
  final double horizontalPadding;
  final FocusNode? focusNode;

  const MyTextField({
    super.key,
    required this.hint,
    required this.obscureText,
    required this.controller,
    required this.horizontalPadding,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: TextField(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)
          ),
          fillColor: Theme.of(context).colorScheme.primary,
          filled: true,
          hintText: hint,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary
          )
        ),
        obscureText: obscureText,
        controller: controller,
        focusNode: focusNode,
      ),
    );
  }
}