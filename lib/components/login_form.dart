import 'package:flutter/material.dart';
import 'package:quizland_app/utils/my_text_form_field.dart';

import '../utils/my_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _hienThiMatKhau = true;
  var _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _key,
        child: Column(
          children: [
            MyTextFormField(
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return "Vui lòng điền tên đăng nhập!";
                }
                return null;
              },
              labelText: 'Tên đăng nhập',
              hintText: 'Hãy điền tên đăng nhập',
              icon: Icons.person,

              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              isPassword: false,
              onFieldSubmitted: (_) { },
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
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    if (_key.currentState!.validate()) {
                      print("Da xu ly");
                    } else {
                      print("loi roi ma");
                    }
                  },
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
                  onPressed: () {},
                  child: const Text(
                    "Quên mật khẩu?",
                  ),
                )
              ],
            ),
            MyButton(
              text: "Đăng nhập",
              onPressed: () {
                if (_key.currentState!.validate()) {
                  print("Da xu ly");
                } else {
                  print("loi roi ma");
                }
              },
            ),
          ],
        ));
  }
}
