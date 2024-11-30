import 'package:flutter/material.dart';

class WordInputGameScreen extends StatefulWidget {
  WordInputGameScreen({super.key, required this.level});
  int level;

  @override
  State<WordInputGameScreen> createState() => _WordInputGameScreenState();
}

class _WordInputGameScreenState extends State<WordInputGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Nghe và điền"),
      ),
      body: Stack(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Opacity(opacity: 0.7,
              child: Image.asset("assets/images/bg_word_input.jpg", fit: BoxFit.fill,)),
        ),
      ]),
    );
  }
}
