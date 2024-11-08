import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/my_button.dart';
import '../utils/my_text_form_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String? _matKhau;
  String? _username;
  String? _phone;
  bool _isLoading = false;

  var _key = GlobalKey<FormState>();

  Future<bool> _checkPhoneExisted() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: _phone)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _checkUsernameExisted() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: _username)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

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
                _username = value;
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
                } else if (!value.startsWith("0")) {
                  return "Số điện thoại không hợp lệ!";
                }
                _phone = value.length == 10
                    ? "+84${value.substring(1)}"
                    : "+84$value";
                print(_phone!.trim());
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
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        _key.currentState!.save();

                        setState(() {
                          _isLoading = true;
                        });

                        bool isPhoneExisted = await _checkPhoneExisted();
                        bool isUsernameExisted = await _checkUsernameExisted();

                        if (isPhoneExisted || isUsernameExisted) {
                          setState(() {
                            _isLoading = false;
                          });
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Đăng kí thất bại"),
                              content: Text(
                                  isPhoneExisted ? "Số điện thoại đã được sử dụng, hãy thử lại với 1 số khác!" :
                                  "Tên đăng nhập đã tồn tại, hãy thử lại với 1 số khác!"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: _phone,
                              timeout: const Duration(seconds: 120),
                              verificationCompleted: (_) {},
                              verificationFailed: (FirebaseAuthException e) {
                                setState(() {
                                  _isLoading = false;
                                });
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Đăng kí thất bại"),
                                    content: const Text(
                                        "Số điện thoại của bạn không được hỗ trợ, hãy thử lại với 1 số khác!"),
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
                                  smsCode: "111111",
                                );

                                if (credential != null) {
                                  UserCredential userCredential =
                                  await FirebaseAuth.instance
                                      .signInWithCredential(credential);

                                  User? user = userCredential.user;

                                  if (user != null) {
                                    await user.updateDisplayName(_username);
                                    await user.updatePassword(_matKhau!);
                                    await user.reload();

                                    User currentUser =
                                    FirebaseAuth.instance.currentUser!;

                                    MyUser newUser = MyUser(
                                      uid: currentUser.uid,
                                      name: currentUser.displayName,
                                      phone: currentUser.phoneNumber,
                                      password: BCrypt.hashpw(
                                          _matKhau!, BCrypt.gensalt()),
                                    );

                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(currentUser.uid)
                                        .set(newUser.toJson());

                                    Navigator.popUntil(
                                      context,
                                          (route) => route.isFirst,
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                              codeAutoRetrievalTimeout: (verificationId) {});
                        }
                      }
                    }),
          ],
        ));
  }
}
