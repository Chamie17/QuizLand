import 'package:flutter/material.dart';
import 'package:quizland_app/components/login_form.dart';
import 'package:quizland_app/utils/my_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
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
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "Welcome back!",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontFamily: 'PlaywriteFRModerne',
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 350,
                        child: Image.asset(
                          "assets/images/login_screen.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(height: 80),
                      LoginForm()
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
