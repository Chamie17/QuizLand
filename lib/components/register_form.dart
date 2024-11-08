import 'package:flutter/material.dart';

import '../utils/my_button.dart';
import '../utils/my_text_form_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String? _matKhau;
  var _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _key,
        child: Column(
          children: [
            MyTextFormField(
              labelText: "Tên đăng nhập",
              hintText: "Hãy điền tên đăng nhập",
              icon: Icons.person,
              onFieldSubmitted: (_) {},
              validator: (value) {
                if (value == null || value.length == 0) {
                  return "Vui lòng điền tên đăng nhập!";
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),

            MyTextFormField(
              labelText: "Số điện thoại",
              hintText: "Hãy điền số điện thoại",
              icon: Icons.phone,
              onFieldSubmitted: (_) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Vui lòng điền số điện thoại!";
                } else if (value.length != 10 ||
                    !RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return "Số điện thoại không hợp lệ!";
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
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
              onFieldSubmitted: (_) {
                if (_key.currentState!.validate()) {
                  print("Da xu ly");
                } else {
                  print("loi roi ma");
                }
              },
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

            MyButton(
              text: "Đăng kí",
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
