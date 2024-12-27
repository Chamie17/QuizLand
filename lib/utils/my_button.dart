import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  String text;
  VoidCallback onPressed;
  MyButton({super.key, required this.text, required this.onPressed});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        height: 42,
        width: (MediaQuery.of(context).size.height / 3),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}
