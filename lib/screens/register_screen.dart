import 'package:flutter/material.dart';
import 'package:quizland_app/components/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
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
                    const SizedBox(height: 20),
                    RegisterForm()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
