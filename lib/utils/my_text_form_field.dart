import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
  MyTextFormField(
      {super.key,
      required this.labelText,
      required this.hintText,
      required this.onFieldSubmitted,
      required this.validator,
      required this.icon,
      this.isPassword = false,
      this.keyboardType = TextInputType.text,
      this.textInputAction = TextInputAction.done,
      this.suffixIcon
      });
  String labelText;
  String hintText;
  void Function(String) onFieldSubmitted;
  String? Function(String?) validator;
  IconData icon;
  bool isPassword;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  IconButton? suffixIcon;

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextFormField(
        autofocus: true,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        obscureText: widget.isPassword,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: Icon(widget.icon, color: Colors.black),
          suffixIcon: widget.suffixIcon,
        ),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
