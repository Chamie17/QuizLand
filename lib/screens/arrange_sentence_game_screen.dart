import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  void triggerWarningEffect() {
    setState(() {
      showWarning = true;
    });

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

  void goToNextQuestion() {
    if (currentQuestionIndex < questionAnswers.length - 1) {
      setState(() {
        currentQuestionIndex++;
        initializeGame();
      });
    } else {
      // End of the game
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text("Congratulations!"),
                content: const Text("You have completed all questions."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ));
    }
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
        title: const Text("Arrange Sentence Game"),
      ),
      body: Stack(
        children: [
          // Background
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/bg_arrange.jpg",
                fit: BoxFit.fill,
              ),
            ),
          ),


          Positioned(
              top: 20,
              child: SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    "assets/images/iceboard.png",
                    fit: BoxFit.fill,
                  ))),

          Positioned(
            top: 225,
            left: 20,
            child: Text(
              'Correct: $correctAnswers',
              style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            top: 225,
            right: 20,
            child: Text(
              'Incorrect: $incorrectAnswers',
              style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          // Main Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100, right: 32, left: 32),
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
                    spacing: 8, // Space between items horizontally
                    runSpacing: 8, // Space between lines vertically
                    children: List.generate(selectedWords.length, (index) {
                      return GestureDetector(
                        onTap: () => onWordRemoved(index),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 3),
                            borderRadius: BorderRadius.circular(8),
                            color: selectedWords[index] != null
                                ? Colors.blue[100]
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
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(8),
                          color: shuffledWords[index] != ""
                              ? Colors.green[100]
                              : Colors.grey[300],
                        ),
                        child: Text(
                          shuffledWords[index],
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Check Answer Button
              Padding(
                padding: const EdgeInsets.all(16.0),
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
