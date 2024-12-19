import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/services/user_serivce.dart';
import 'package:quizland_app/utils/my_text_form_field.dart';

import '../models/user.dart';
import '../utils/my_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _hienThiMatKhau = true;
  String? _matKhau;
  String? _email;
  bool _isLoading = false;
  var _key = GlobalKey<FormState>();

  void _handleLogin() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email!,
          password: _matKhau!,
        );

        await FirebaseAuth.instance.currentUser!.updatePhotoURL("https://firebasestorage.googleapis.com/v0/b/quizland-ba92d.firebasestorage.app/o/avatars%2Fdefault%20avatar.png?alt=media&token=96a8a7af-b4b3-4fbf-86aa-615ec12b2074");
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Error during sign-in: $e');
        final result = await showOkAlertDialog(
          context: context,
          title: 'Lỗi',
          message: 'Địa chỉ email hoặc mật khẩu không đúng!',
        );
      }

    }
  }

  void _handleForgotPassword() async {
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: 'Email',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return "Vui lòng điền địa chỉ email!";
            } else if (!EmailValidator.validate(value!)) {
              return "Địa chỉ email không hợp lệ";
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
        ),
      ],
      title: 'Khôi phục mật khẩu',
      message: 'Hãy nhập địa chỉ email muốn khôi phục',
    );

    if (text != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: text.first);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text('Link khôi phục đã gửi đến ${text.first}'),
      ));
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MyTextFormField(
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Vui lòng điền mật khẩu!";
                    }
                    _matKhau = value;
                    return null;
                  },
                  onFieldSubmitted: (_) {},
                  isPassword: _hienThiMatKhau,
                  labelText: 'Mật khẩu',
                  hintText: 'Hãy nhập mật khẩu',
                  icon: Icons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _hienThiMatKhau
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _hienThiMatKhau = !_hienThiMatKhau;
                      });
                    },
                  ),
                ),
                TextButton(
                  onPressed: _handleForgotPassword,
                  child: const Text(
                    "Quên mật khẩu?",
                  ),
                )
              ],
            ),
            _isLoading
                ? CircularProgressIndicator()
                : MyButton(
                    text: "Đăng nhập",
                    onPressed: _handleLogin,
                  ),
          ],
        ));
  }
}
