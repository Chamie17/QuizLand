import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/screens/splash_screen.dart';
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
  String? _username;
  bool _isLoading = false;
  var _key = GlobalKey<FormState>();

  Future<dynamic> _checkLogin() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: _username)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final user = snapshot.docs.first.data() as Map<String, dynamic>;
      if (BCrypt.checkpw(_matKhau!, user['password'])) {
        return MyUser.fromJson(user);
      }
      return null;
    } else {
      return null;
    }
  }

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
                _username = value;
                return null;
              },
              labelText: 'Tên đăng nhập',
              hintText: 'Hãy điền tên đăng nhập',
              icon: Icons.person,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              isPassword: false,
              onFieldSubmitted: (_) {},
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
                  onPressed: () {},
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
                    onPressed: () async {
                      if (_key.currentState?.validate() ?? false) {
                        _key.currentState!.save();

                        setState(() {
                          _isLoading = true;
                        });

                        MyUser? user = await _checkLogin();

                        if (user != null) {
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: user!.phone,
                            timeout: const Duration(seconds: 120),
                            verificationCompleted: (_) {},
                            verificationFailed: (FirebaseAuthException e) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Đăng nhập thất bại"),
                                  content: const Text(
                                      "Có lỗi xảy ra, vui lòng thử lại."),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            codeSent: (String verificationId,
                                int? resendToken) async {
                              PhoneAuthCredential credential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verificationId,
                                      smsCode: "111111");

                              await FirebaseAuth.instance
                                  .signInWithCredential(credential);

                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
                              );

                              setState(() {
                                _isLoading = false;
                              });
                            },
                            codeAutoRetrievalTimeout: (_) {},
                          );
                        }
                        else {
                          setState(() {
                            _isLoading = false;
                          });
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Đăng nhập thất bại"),
                              content: const Text(
                                  "Sai tên đăng nhập hoặc mật khẩu, vui long thử lại!"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SplashScreen(),)),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                  ),
          ],
        ));
  }
}
