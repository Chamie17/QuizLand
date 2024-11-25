import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/services/user_serivce.dart';

import '../utils/my_button.dart';
import '../utils/my_text_form_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String? _matKhau;
  String? _name;
  String? _phone;
  String? _email;
  bool _isLoading = false;

  var _key = GlobalKey<FormState>();

  void _handleRegister() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();

      UserCredential? credential = await userService.register(_email!, _matKhau!, _name!);
      if (credential != null) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email!,
            password: _matKhau!,
          );
        } catch (e) {
          print('Error during sign-in: $e');
        }
      } else {
        final result = await showOkAlertDialog(
          context: context,
          title: 'Lỗi',
          message: 'Tài khoản đã tồn tại!',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _key,
        child: Column(
          children: [
            MyTextFormField(
              labelText: "Địa chỉ email",
              hintText: "Hãy điền địa chỉ email",
              icon: Icons.mail,
              onFieldSubmitted: (_) {},
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return "Vui lòng điền địa chỉ email!";
                } else if (!EmailValidator.validate(value!)) {
                  return "Địa chỉ email không hợp lệ";
                }
                _email = value;
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            MyTextFormField(
              labelText: "Họ và tên",
              hintText: "Hãy điền họ và tên",
              icon: Icons.person,
              onFieldSubmitted: (_) {},
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return "Vui lòng điền họ và tên!";
                }
                _name = value;
                return null;
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            MyTextFormField(
              isPassword: true,
              labelText: "Mật khẩu",
              hintText: "Hãy nhập mật khẩu",
              icon: Icons.lock,
              onFieldSubmitted: (_) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vui lòng điền mật khẩu!";
                }
                _matKhau = value;
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            MyTextFormField(
              isPassword: true,
              labelText: "Xác nhận mật khẩu",
              hintText: "Hãy nhập lại mật khẩu",
              icon: Icons.lock,
              onFieldSubmitted: (_) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vui lòng xác nhận mật khẩu!";
                } else if (value != _matKhau) {
                  return "Mật khẩu không khớp!";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : MyButton(
                    text: "Đăng kí",
                    onPressed: _handleRegister),
          ],
        ));
  }
}
