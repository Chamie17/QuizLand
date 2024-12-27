import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizland_app/utils/my_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  void _goToLoginScreen() {
    context.pushNamed('login');
  }

  void _goToRegisterScreen() {
    context.pushNamed('register');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.15;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(),
          Text(
            "Quiz Land",
            style: TextStyle(
                color: Colors.purple, fontSize: fontSize, fontFamily: 'Kablammo'),
          ),
          SizedBox(
            height: 350,
            child: Image.asset("assets/images/logo.png", fit: BoxFit.fill,),
          ),
          MyButton(text: "Đăng nhập", onPressed: _goToLoginScreen),
          const SizedBox(
            height: 24,
          ),
          MyButton(text: "Đăng kí", onPressed: _goToRegisterScreen,)
        ],
      ),
    );
  }
}
