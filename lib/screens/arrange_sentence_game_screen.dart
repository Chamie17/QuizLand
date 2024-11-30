import 'package:flutter/material.dart';

class ArrangeSentenceGameScreen extends StatefulWidget {
  ArrangeSentenceGameScreen({super.key, required this.level});
  int level;

  @override
  State<ArrangeSentenceGameScreen> createState() => _ArrangeSentenceGameScreenState();
}

class _ArrangeSentenceGameScreenState extends State<ArrangeSentenceGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("xếp câu hoàn chỉnh"),
      ),
      body: Stack(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Opacity(opacity: 0.7,
              child: Image.asset("assets/images/bg_arrange.jpg", fit: BoxFit.fill,)),
        ),

      ]),
    );
  }
}
