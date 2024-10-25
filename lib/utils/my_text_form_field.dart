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
      this.textInputAction = TextInputAction.done
      });
  String labelText;
  String hintText;
  void Function(String) onFieldSubmitted;
  String? Function(String?) validator;
  IconData icon;
  bool isPassword;
  TextInputType keyboardType;
  TextInputAction textInputAction;

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextFormField(
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
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
