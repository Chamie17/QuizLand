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
  List<String> _originalQuestions = [];
  List<String> _originalAnswers = [];
  List<int> _usedQuestions = [];  // List to track used questions
  int _point = 0;
  int _minus = 0;
  int _currentRound = 0; // Track the current round
  final int _maxRounds = 7; // Maximum rounds
  final int _roundSize = 3; // Number of pairs per round
  int _roundsRemaining = 7; // Tracks remaining rounds


  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (matchingLevel.containsKey(widget.level)) {
      final folderPath = 'assets/matching_source/${widget.level}/';
      final List<String> images = matchingLevel[widget.level]!.map((e) => folderPath + e).toList();

      // Extract base names (without extensions) for answers
      final List<String> answers = images
          .map((image) => image.split('/').last.split('.').first)
          .toList();

      setState(() {
        _allQuestions = List.from(images); // Preserve the original questions list
        _allAnswers = List.from(answers); // Preserve the original answers list
        _originalQuestions = List.from(images); // Copy the original questions
        _originalAnswers = List.from(answers); // Copy the original answers
      });

      _loadNextRound();
    }
  }

  // Add this to track the display count (already existing in your code)
  Map<String, int> questionDisplayCount = {};

  void _loadNextRound() {
    if (_roundsRemaining <= 0) {
      // All rounds completed
      _showCompletionDialog();
      return;
    }

    setState(() {
      final random = Random();

      // Ensure you have at least 3 pairs of questions/answers for each round
      final roundSize = min(_roundSize, _originalQuestions.length);

      List<String> roundQuestions = [];
      List<String> roundAnswers = [];

      // List to track already selected questions
      Set<int> selectedIndices = Set<int>();

      // List to track used questions in previous rounds
      List<int> unusedQuestions = List<int>.generate(_originalQuestions.length, (index) => index);

      // First, shuffle the questions to get random selection
      unusedQuestions.shuffle(random);

      // Select questions ensuring each is shown at least twice
      for (int i = 0; i < roundSize; i++) {
        bool questionSelected = false;

        // Try to select a question that has been displayed less than twice
        for (int j = 0; j < unusedQuestions.length; j++) {
          int randomIndex = unusedQuestions[j];

          // Check if the question has been displayed less than twice
          if ((questionDisplayCount[_originalQuestions[randomIndex]] ?? 0) < 2) {
            roundQuestions.add(_originalQuestions[randomIndex]);
            roundAnswers.add(_originalAnswers[randomIndex]);
            selectedIndices.add(randomIndex);  // Mark as selected

            // Update the display count
            questionDisplayCount[_originalQuestions[randomIndex]] =
                (questionDisplayCount[_originalQuestions[randomIndex]] ?? 0) + 1;

            questionSelected = true;
            unusedQuestions.removeAt(j); // Remove the question from unused pool
            break;
          }
        }

        // If no question with less than 2 displays is available, use any question
        if (!questionSelected && unusedQuestions.isNotEmpty) {
          int randomIndex = unusedQuestions.removeLast();  // Select any remaining question
          roundQuestions.add(_originalQuestions[randomIndex]);
          roundAnswers.add(_originalAnswers[randomIndex]);
          selectedIndices.add(randomIndex);  // Mark as selected

          // Update the display count
          questionDisplayCount[_originalQuestions[randomIndex]] =
              (questionDisplayCount[_originalQuestions[randomIndex]] ?? 0) + 1;
        }
      }

      // Shuffle answers to make the game more challenging
      roundAnswers.shuffle(random);

      // Update the round data
      _questions = roundQuestions;
      _answers = roundAnswers;

      // Initialize match status for this round
      _questionMatched = List<bool>.filled(roundQuestions.length, false);
      _answerMatched = List<bool>.filled(roundAnswers.length, false);
      _questionSelected = List<bool>.filled(roundQuestions.length, false);
      _answerSelected = List<bool>.filled(roundAnswers.length, false);
      _selectedQuestions.clear();
      _selectedAnswers.clear();

      _currentRound++;
      _roundsRemaining--; // Decrease remaining rounds
    });
  }


// Log the display counts when needed (for debugging)
  void _logQuestionDisplayCounts() {
    questionDisplayCount.forEach((question, count) {
      print('Question: $question displayed $count times');
    });
  }
  void _showCompletionDialog() {
    _logQuestionDisplayCounts();
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
    final bool isIncorrect = !isMatched && isSelected; // Simplified incorrect match check
    final double size = isSelected ? 180 : 170; // Increase size when selected

    // Set background color: Green for correct, Red for incorrect, Transparent otherwise
    final Color backgroundColor = isMatched
        ? Colors.green
        : (isIncorrect ? Colors.red : Colors.transparent);

    return GestureDetector(
      onTap: () => _onSelectQuestion(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16), // Reduced padding for balance
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12), // Slightly more rounded corners
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _questions[index],
                      height: size,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Image overlay when match is correct (green background)
              if (isMatched)
                Positioned(
                  child: Image.asset(
                    'assets/images/correct_icon.png',
                    width: 100, // Adjusted size of overlay image
                    height: 100,
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
    final bool isIncorrect = !isMatched && isSelected; // Simplified incorrect match check
    final double size = isSelected ? 180 : 170; // Increase size when selected

    // Set background color: Green for correct, Red for incorrect, Transparent otherwise
    final Color backgroundColor = isMatched
        ? Colors.green
        : (isIncorrect ? Colors.red : Colors.transparent);

    return GestureDetector(
      onTap: () => _onSelectAnswer(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16), // Reduced padding for consistency
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12), // Slightly more rounded corners
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
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Image overlay when match is correct (green background)
              if (isMatched)
                Positioned(
                  child: Image.asset(
                    'assets/images/correct_icon.png',
                    width: 100, // Adjusted size of overlay image
                    height: 100,
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
    return Positioned(
      top: 0,
      left: 20,
      right: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Correct: $_point',
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.bold
              ),
            ),
            Text(
              'Incorrect: $_minus',
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
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
          _buildScore(),
          Column(
            children: [
              SizedBox(height: 32,),
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
