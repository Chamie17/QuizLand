import 'package:flutter/material.dart';

class ListeningGameScreen extends StatefulWidget {
  ListeningGameScreen({super.key, required this.level});
  int level;

  @override
  State<ListeningGameScreen> createState() => _ListeningGameScreenState();
}

class _ListeningGameScreenState extends State<ListeningGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Nghe và đoán"),
      ),
      body: Stack(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Opacity(opacity: 0.7,
              child: Image.asset("assets/images/bg_music.jpg", fit: BoxFit.fill,)),
        ),

      ]),
    );
  }
}
