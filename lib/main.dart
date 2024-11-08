import 'package:flutter/material.dart';
import 'package:quizland_app/screens/welcome_screen.dart';
import 'package:quizland_app/utils/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    //* Material App là toàn bộ ứng dụng
    //* theme la phan dinh nghia style, decoration, cua cac widgets trong app
    //* home la phan noi dung cua app

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      home: WelcomeScreen(),
    );
  }
}