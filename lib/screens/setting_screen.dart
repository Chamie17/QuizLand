import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isMute = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Stack(
        children: [
          RotatedBox(
              quarterTurns: 1,
              child: Image.asset(
                "assets/images/setting_board.png",
              ))
        ],
      ),
    )));
  }
}
