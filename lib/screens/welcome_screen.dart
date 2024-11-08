import 'package:flutter/material.dart';
import 'package:quizland_app/screens/login_screen.dart';
import 'package:quizland_app/screens/register_screen.dart';
import 'package:quizland_app/utils/my_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Row(),
            const Text(
              "Quiz Land",
              style: TextStyle(
                  color: Colors.purple, fontSize: 60, fontFamily: 'Kablammo'),
            ),
            Image.asset("assets/images/logo.png"),
            MyButton(text: "Đăng nhập", onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ));
            },),
            const SizedBox(
              height: 24,
            ),
            MyButton(text: "Đăng kí", onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ));
            },)
          ],
        ),
      ),
    );
  }
}
