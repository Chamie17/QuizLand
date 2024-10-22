import 'package:flutter/material.dart';
import 'package:quizland_app/utils/my_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _hienThiMatKhau = true;
  bool _hienThiXacNhanMatKhau = true;
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.length == 0) {
                                      return "Vui lòng điền tên đăng nhập!";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Tên đăng nhập',
                                    hintText: 'Hãy điền tên đăng nhập',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    labelStyle: TextStyle(color: Colors.black),
                                    prefixIcon:
                                    Icon(Icons.person, color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.redAccent, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Vui lòng điền số điện thoại!";
                                    } else if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                      return "Số điện thoại không hợp lệ!";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Số điện thoại',
                                    hintText: 'Hãy điền số điện thoại',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    labelStyle: TextStyle(color: Colors.black),
                                    prefixIcon:
                                    Icon(Icons.phone, color: Colors.black),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.redAccent, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Vui lòng điền mật khẩu!";
                                    }
                                    _matKhau = value;
                                    return null;
                                  },
                                  obscureText: _hienThiMatKhau,
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu',
                                    hintText: 'Hãy nhập mật khẩu',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    labelStyle: TextStyle(color: Colors.black),
                                    prefixIcon:
                                    Icon(Icons.lock, color: Colors.black),
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
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.redAccent, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20),
                                  ),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),

                              SizedBox(height: 10),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Vui lòng xác nhận mật khẩu!";
                                    } else if (value != _matKhau) {
                                      return "Mật khẩu không khớp!";
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
                                  obscureText: _hienThiXacNhanMatKhau,
                                  decoration: InputDecoration(
                                    labelText: 'Xác nhận mật khẩu',
                                    hintText: 'Hãy nhập lại mật khẩu',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    labelStyle: TextStyle(color: Colors.black),
                                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                          _hienThiXacNhanMatKhau
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.black),
                                      onPressed: () {
                                        setState(() {
                                          _hienThiXacNhanMatKhau = !_hienThiXacNhanMatKhau;
                                        });
                                      },
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.redAccent, width: 2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    contentPadding:
                                    EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                  ),
                                  style: TextStyle(fontSize: 18),
                                ),
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
