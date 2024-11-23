import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  Widget _buildQuestion(String question, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Image.asset(
          "assets/images/$question.png",
          width: 100,
          height: 100,
        ),
        onTap: () {
          setState(() {
            currentQuestion = question;
            if (currentQuestion == currentAnswer) {
              result[index] = true;
              _checkFinish();
            }
          });
        },
      ),
    );
  }

  Widget _buildAnswer(String answer, int index) {
    return Material(
      color: Colors.transparent,
      elevation: 5,
      child: InkWell(
        child: Container(
          height: 100,
          width: 150,
          color: Colors.pink,
          child: Center(
              child: Text(
            answer,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          )),
        ),
        onTap: () {
          setState(() {
            currentAnswer = answer;
            if (currentQuestion == currentAnswer) {
              result[index] = true;
              _checkFinish();
            }
          });
        },
      ),
    );
  }

  String? currentQuestion;
  String? currentAnswer;

  List<bool> result = [false, false, false, false];

  void _checkFinish() {
    if (!result.contains(false)) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Text("Chuc mung da chien thang"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Ghép cặp từ vựng"),
      ),
      body: Stack(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Opacity(opacity: 0.7,
          child: Image.asset("assets/images/bg_matching_game.png", fit: BoxFit.fill,)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!result[0] || currentAnswer != currentAnswer)
                  _buildQuestion('monkey', 0),
                if (!result[1] || currentAnswer != currentAnswer)
                  _buildQuestion('coin', 1),
                if (!result[2] || currentAnswer != currentAnswer)
                  _buildQuestion('cloud1', 2),
                if (!result[3] || currentAnswer != currentAnswer)
                  _buildQuestion('logo', 3)
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!result[1] || currentAnswer != currentAnswer)
                  _buildAnswer('coin', 1),
                if (!result[0] || currentAnswer != currentAnswer)
                  _buildAnswer('monkey', 0),
                if (!result[2] || currentAnswer != currentAnswer)
                  _buildAnswer('cloud1', 2),
                if (!result[3] || currentAnswer != currentAnswer)
                  _buildAnswer('logo', 3)
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
