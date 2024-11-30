import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizland_app/services/question_service.dart';
import '../utils/matching_level.dart';

class MatchingGameScreen extends StatefulWidget {
  MatchingGameScreen({super.key, required this.level});
  final int level;

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  List<String> _allQuestions = [];
  List<String> _allAnswers = [];
  List<String> _questions = [];
  List<String> _answers = [];
  List<bool> _questionMatched = [];
  List<bool> _answerMatched = [];
  List<String> _selectedQuestions = [];
  List<String> _selectedAnswers = [];
  List<bool> _questionSelected = [];
  List<bool> _answerSelected = [];
  int _point = 0;
  int _minus = 0;
  int _currentRound = 0; // Track the current round
  final int _roundSize = 3; // Number of pairs per round


  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (matchingLevel.containsKey(widget.level)) {
      final folderPath = 'assets/matching_source/${widget.level}/';
      final List<String> images =
      matchingLevel[widget.level]!.map((e) => folderPath + e).toList();

      // Extract base names (without extensions) for answers
      final List<String> answers = images
          .map((image) => image.split('/').last.split('.').first)
          .toList();

      setState(() {
        _allQuestions = images;
        _allAnswers = answers;
      });

      _loadNextRound();
    }
  }

  void _loadNextRound() {
    if (_allQuestions.isEmpty) {
      // All rounds completed
      _showCompletionDialog();
      return;
    }

    setState(() {
      // Get up to 3 items for the current round
      final roundQuestions = _allQuestions.take(_roundSize).toList();
      final roundAnswers = _allAnswers.take(_roundSize).toList();

      // Remove these items from the pool
      _allQuestions = _allQuestions.sublist(roundQuestions.length);
      _allAnswers = _allAnswers.sublist(roundAnswers.length);

      // Shuffle answers
      final random = Random();
      roundAnswers.shuffle(random);

      // Update state
      _questions = roundQuestions;
      _answers = roundAnswers;
      _questionMatched = List<bool>.filled(roundQuestions.length, false);
      _answerMatched = List<bool>.filled(roundAnswers.length, false);
      _questionSelected = List<bool>.filled(roundQuestions.length, false);
      _answerSelected = List<bool>.filled(roundAnswers.length, false);
      _selectedQuestions.clear();
      _selectedAnswers.clear();
      _currentRound++;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Completed'),
        content: Text('Bạn nhận $_point trái chuối và  sai $_minus lần!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Exit the game screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shuffle() {
    final random = Random();
    // Shuffle both questions (images) and answers (words)
    _questions.shuffle(random);
    _answers.shuffle(random);

    // Reset match and selection lists
    _questionMatched = List<bool>.filled(_questions.length, false);
    _answerMatched = List<bool>.filled(_answers.length, false);
    _questionSelected = List<bool>.filled(_questions.length, false);
    _answerSelected = List<bool>.filled(_answers.length, false);
  }

  void _onSelectQuestion(int index) {
    if (_questionMatched[index]) return;

    setState(() {
      // Toggle the selection state for the question
      _questionSelected[index] = !_questionSelected[index];
      _selectedQuestions.add(_questions[index]);
    });
    _checkMatch();
  }

  void _onSelectAnswer(int index) {
    if (_answerMatched[index]) return;

    setState(() {
      // Toggle the selection state for the answer
      _answerSelected[index] = !_answerSelected[index];
      _selectedAnswers.add(_answers[index]);
    });
    _checkMatch();
  }

  void _checkMatch() {
    if (_selectedQuestions.isNotEmpty && _selectedAnswers.isNotEmpty) {
      final question = _selectedQuestions.last;
      final answer = _selectedAnswers.last;

      if (question.split('/').last.split('.').first == answer) {
        setState(() {
          _point++;
          final questionIndex = _questions.indexOf(question);
          final answerIndex = _answers.indexOf(answer);
          _questionMatched[questionIndex] = true;
          _answerMatched[answerIndex] = true;
          _selectedQuestions.clear();
          _selectedAnswers.clear();
        });

        // Wait for the visual effect before proceeding
        Future.delayed(const Duration(milliseconds: 600), () {
          // Check if the round is complete
          if (_questionMatched.every((matched) => matched)) {
            _loadNextRound();
          }
        });
      } else {
        setState(() {
          _minus++;
          // Trigger the red effect for incorrect match
          final questionIndex = _questions.indexOf(question);
          final answerIndex = _answers.indexOf(answer);
          _questionMatched[questionIndex] = false;
          _answerMatched[answerIndex] = false;
        });

        // Show red effect and then reset after 1 second
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            // Reset the selection and color after the red effect
            _questionSelected = List<bool>.filled(_questions.length, false);
            _answerSelected = List<bool>.filled(_answers.length, false);
          });
        });

        _selectedQuestions.clear();
        _selectedAnswers.clear();
      }
    }
  }



  Widget _buildQuestion(int index) {
    final bool isSelected = _questionSelected[index];
    final bool isMatched = _questionMatched[index];
    final bool isIncorrect = _questionMatched[index] == false && _questionSelected[index]; // Incorrect match check
    final double size = isSelected ? 180 : 170; // Increase size when selected

    // Set background color: Green for correct, Red for incorrect, Transparent otherwise
    final color = isMatched
        ? Colors.green
        : (isIncorrect ? Colors.red : Colors.transparent);

    return GestureDetector(
      onTap: () => _onSelectQuestion(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color, // Red or Green for incorrect or correct matches
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The image itself
              AnimatedOpacity(
                opacity: isMatched ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 4,
                  child: Image.asset(
                    height: size,
                    _questions[index],
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              // Image overlay when match is correct (green background)
              if (isMatched)
                Positioned(
                  child: Image.asset(
                    'assets/images/correct_icon.png', // Path to the correct match image
                    width: 200, // Adjust the size of the overlay image
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }





  Widget _buildAnswer(int index) {
    final bool isSelected = _answerSelected[index];
    final bool isMatched = _answerMatched[index];
    final bool isIncorrect = _answerMatched[index] == false && _answerSelected[index]; // Incorrect match check
    final double size = isSelected ? 180 : 170; // Increase size when selected

    // Set background color: Green for correct, Red for incorrect, Transparent otherwise
    final color = isMatched
        ? Colors.green
        : (isIncorrect ? Colors.red : Colors.transparent);

    return GestureDetector(
      onTap: () => _onSelectAnswer(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color, // Red or Green for incorrect or correct matches
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The answer text itself
              AnimatedOpacity(
                opacity: isMatched ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 4,
                  child: Center(
                    child: Text(
                      _answers[index],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Image overlay when match is correct (green background)
              if (isMatched)
                Positioned(
                  child: Image.asset(
                    'assets/images/correct_icon.png', // Path to the correct match image
                    width: 200, // Adjust the size of the overlay image
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }





  Widget _buildGameBoard() {
    return Expanded(
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_questions.length, (index) {
                return _buildQuestion(index);
              }),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_answers.length, (index) {
                return _buildAnswer(index);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScore() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Chuối: $_point | Sai: $_minus',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Ghép cặp từ vựng"),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset("assets/images/bg_matching_game.png",
                  fit: BoxFit.fill),
            ),
          ),
          Column(
            children: [
              _buildScore(),
              _buildGameBoard(),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadNextRound(); // Skip current round
        },
        child: const Icon(Icons.skip_next),
      ),
    );
  }
}
