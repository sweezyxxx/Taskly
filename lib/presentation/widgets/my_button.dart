import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12)
        ),
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Text(text, style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),),
        ),
      ),
    );
  }
}