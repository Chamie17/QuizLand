import 'package:flutter/material.dart';
import 'package:quizland_app/utils/my_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hienThiMatKhau = true;
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
                      SizedBox(height: 40),
                      Text(
                        "Welcome back!",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontFamily: 'PlaywriteFRModerne',
                            fontWeight: FontWeight.bold),
                      ),
                      Container(
                        height: 300,
                        child: Image.asset(
                          "assets/images/login_screen.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(height: 80),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.length == 0) {
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
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Quên mật khẩu?",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              ],
                            ),
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
