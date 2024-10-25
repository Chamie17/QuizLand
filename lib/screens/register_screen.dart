import 'package:flutter/material.dart';
import 'package:quizland_app/utils/my_button.dart';

import '../utils/my_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _matKhau;
  var _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_sharp,
              size: 30,
            )),
        backgroundColor: Colors.blue.shade50,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.blue.shade50,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "Create account",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontFamily: 'PlaywriteFRModerne',
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        height: 300,
                        child: Image.asset(
                          "assets/images/register_screen.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(height: 20),
                      Form(
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
                              SizedBox(height: 10),

                              SizedBox(height: 10),

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
                              SizedBox(height: 10),

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

                              SizedBox(height: 10),

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
                              SizedBox(height: 16),
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
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
