import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibration/vibration.dart';

import '../models/question_answer.dart';

class ArrangeSentenceGameScreen extends StatefulWidget {
  ArrangeSentenceGameScreen({super.key, required this.level});
  final int level;

  @override
  State<ArrangeSentenceGameScreen> createState() =>
      _ArrangeSentenceGameScreenState();
}

class _ArrangeSentenceGameScreenState extends State<ArrangeSentenceGameScreen>
    with SingleTickerProviderStateMixin {
  late List<QuestionAnswer> questionAnswers = [];
  late List<String> shuffledWords = [];
  late List<String?> selectedWords = [];
  int currentQuestionIndex = 0;
  bool showWarning = false;
  double warningScale = 1.0;
  int correctAnswers = 0;
  int incorrectAnswers = 0;

  Future<void> loadQuestionAnswers() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/arrange_source/level${widget.level}.json');
      List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        questionAnswers =
            jsonData.map((data) => QuestionAnswer.fromJson(data)).toList();
        initializeGame();
      });
    } catch (e) {
      print("Error loading or parsing JSON: $e");
    }
  }

  void initializeGame() {
    if (questionAnswers.isNotEmpty) {
      String answer = questionAnswers[currentQuestionIndex].answer;
      shuffledWords = answer.split(' ')..shuffle();
      selectedWords = List.filled(answer.split(' ').length, null);
    }
  }

  void resetCurrentQuestion() {
    setState(() {
      initializeGame(); // Reinitialize the question-answer interface
      showWarning = false; // Remove warning image
    });
  }

  void triggerWarningEffect() async{
    setState(() {
      showWarning = true;
    });

    if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 500); // Vibrate for 500 milliseconds
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        warningScale = 1.5; // Zoom out
      });
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        warningScale = 1.0; // Zoom in
      });
    });

    Future.delayed(const Duration(seconds: 1), resetCurrentQuestion);
  }

  void onWordSelected(String word, int index) {
    setState(() {
      if (selectedWords.contains(null)) {
        int placeholderIndex = selectedWords.indexOf(null);
        selectedWords[placeholderIndex] = word;
        shuffledWords[index] = ""; // Remove the word from the shuffled list
      }
    });
  }

  void onWordRemoved(int index) {
    setState(() {
      String? removedWord = selectedWords[index];
      if (removedWord != null) {
        int emptyIndex = shuffledWords.indexOf("");
        if (emptyIndex != -1) {
          shuffledWords[emptyIndex] = removedWord;
        }
        selectedWords[index] = null;
      }
    });
  }

  bool checkAnswer() {
    String userAnswer = selectedWords.join(' ').trim();
    return userAnswer == questionAnswers[currentQuestionIndex].answer.trim();
  }

  void goToNextQuestion() async{
    if (currentQuestionIndex < questionAnswers.length - 1) {
      setState(() {
        currentQuestionIndex++;
        initializeGame();
      });
    } else {
      // End of the game
      String uid = FirebaseAuth.instance.currentUser!.uid;

      bool? isReplay = await context.pushNamed('result', pathParameters: {
        'uid': uid,
        'game': 'arrangeSentence',
        'level': widget.level.toString(),
        'correct': correctAnswers.toString(),
        'incorrect': incorrectAnswers.toString()
      });

      if (isReplay ?? false) {
        resetGame();
      }
    }
  }

  void resetGame() {
    setState(() {
      correctAnswers = 0;
      incorrectAnswers = 0;
      currentQuestionIndex = 0;
      initializeGame();
    });
  }

  void handleCheckAnswer() {
    if (checkAnswer()) {
      goToNextQuestion();
      setState(() {
        correctAnswers++;  // Increment correct answers
      });
    } else {
      triggerWarningEffect();
      setState(() {
        incorrectAnswers++;  // Increment incorrect answers
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadQuestionAnswers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("ARRANGE SENTENCE GAME"),
      ),
      body: Stack(
        children: [
          // Background
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              "assets/images/bg_arrange.jpg",
              fit: BoxFit.fill,
            ),
          ),


          Positioned(
              top: 60,
              child: SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    "assets/images/iceboard.png",
                    fit: BoxFit.fill,
                  ))),

          Positioned(
              top: 200,
              child: SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Lottie.asset(
                    "assets/lottiefiles/santa.json",
                    fit: BoxFit.fill,
                  ))),

          Positioned(
              right: -100,
              bottom: 120,
              child: SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Lottie.asset(
                    "assets/lottiefiles/snowman.json",
                    fit: BoxFit.fitHeight,
                  ))),

          Positioned(
            left: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Đúng: $correctAnswers',
                    style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold, ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sai: $incorrectAnswers',
                    style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 140, right: 32, left: 32),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Center(
                    child: Text(
                      questionAnswers.isNotEmpty
                          ? questionAnswers[currentQuestionIndex].question
                          : "Loading...",
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              // Selected Words
              Expanded(
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4, // Space between items horizontally
                    runSpacing: 8, // Space between lines vertically
                    children: List.generate(selectedWords.length, (index) {
                      return GestureDetector(
                        onTap: () => onWordRemoved(index),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: selectedWords[index] != null ? Border.all(color: Colors.transparent, width: 3) : BorderDirectional(bottom: BorderSide(color: Colors.black, width: 2)),
                            borderRadius: selectedWords[index] != null ? BorderRadius.circular(8) : null,
                            color: selectedWords[index] != null
                                ? Colors.yellow[100]
                                : Colors.transparent,
                          ),
                          child: Text(
                            selectedWords[index] ?? "",
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Shuffled Words
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(shuffledWords.length, (index) {
                    return GestureDetector(
                      onTap: shuffledWords[index] != ""
                          ? () => onWordSelected(shuffledWords[index], index)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(8),
                          color: shuffledWords[index] != ""
                              ? Colors.yellow[100]
                              : Colors.white,
                        ),
                        child: Text(
                          shuffledWords[index],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Check Answer Button
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFfe68b2)),
                  onPressed: handleCheckAnswer,
                  child: const Text("Kiểm tra đáp án", style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),

          // Warning Effect
          if (showWarning)
            Center(
              child: AnimatedScale(
                scale: warningScale,
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  "assets/images/error.png",
                  width: 300,
                  height: 300,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
