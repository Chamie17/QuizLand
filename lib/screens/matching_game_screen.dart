import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:quizland_app/screens/welcome_screen.dart';
import 'package:quizland_app/services/question_service.dart';
import 'package:vibration/vibration.dart';
import '../utils/matching_level.dart';

class MatchingGameScreen extends StatefulWidget {
  MatchingGameScreen({super.key, required this.level});
  final int level;

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller_worm;
  late Animation<double> _animation_worm;
  bool _showIncorrectImage = false;



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
  int _point = 0;
  int _minus = 0;
  final int _roundSize = 3; // Number of pairs per round
  int _roundsRemaining = 7; // Tracks remaining rounds

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _controller_worm.dispose();
    super.dispose();
  }

  void init() async {
    // Initialize the AnimationController
    _controller_worm = AnimationController(
      duration: Duration(seconds: 8), // Animation duration
      vsync: this,
    );

    // Define the animation from screen width to -100 (off-screen)
    _animation_worm = Tween<double>(
      begin: -100,
      end: 400, // Moving off-screen to the left
    ).animate(CurvedAnimation(
      parent: _controller_worm,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller_worm.repeat();

    if (matchingLevel.containsKey(widget.level)) {
      final folderPath = 'assets/matching_source/${widget.level}/';
      final List<String> images =
          matchingLevel[widget.level]!.map((e) => folderPath + e).toList();

      // Extract base names (without extensions) for answers
      final List<String> answers = images
          .map((image) => image.split('/').last.split('.').first)
          .toList();

      setState(() {
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
      List<int> unusedQuestions =
          List<int>.generate(_originalQuestions.length, (index) => index);

      // First, shuffle the questions to get random selection
      unusedQuestions.shuffle(random);

      // Select questions ensuring each is shown at least twice
      for (int i = 0; i < roundSize; i++) {
        bool questionSelected = false;

        // Try to select a question that has been displayed less than twice
        for (int j = 0; j < unusedQuestions.length; j++) {
          int randomIndex = unusedQuestions[j];

          // Check if the question has been displayed less than twice
          if ((questionDisplayCount[_originalQuestions[randomIndex]] ?? 0) <
              2) {
            roundQuestions.add(_originalQuestions[randomIndex]);
            roundAnswers.add(_originalAnswers[randomIndex]);
            selectedIndices.add(randomIndex); // Mark as selected

            // Update the display count
            questionDisplayCount[_originalQuestions[randomIndex]] =
                (questionDisplayCount[_originalQuestions[randomIndex]] ?? 0) +
                    1;

            questionSelected = true;
            unusedQuestions.removeAt(j); // Remove the question from unused pool
            break;
          }
        }

        // If no question with less than 2 displays is available, use any question
        if (!questionSelected && unusedQuestions.isNotEmpty) {
          int randomIndex =
              unusedQuestions.removeLast(); // Select any remaining question
          roundQuestions.add(_originalQuestions[randomIndex]);
          roundAnswers.add(_originalAnswers[randomIndex]);
          selectedIndices.add(randomIndex); // Mark as selected

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

      _roundsRemaining--; // Decrease remaining rounds
    });
  }

// Log the display counts when needed (for debugging)
  void _logQuestionDisplayCounts() {
    questionDisplayCount.forEach((question, count) {
      print('Question: $question displayed $count times');
    });
  }

  void resetGame() {
    setState(() {
      // Reset scores
      _point = 0;
      _minus = 0;

      // Reset rounds remaining
      _roundsRemaining = 7;

      // Reset the selected state for questions and answers
      _selectedQuestions.clear();
      _selectedAnswers.clear();
      _questionMatched = [];
      _answerMatched = [];
      _questionSelected = [];
      _answerSelected = [];

      // Reload the next round with fresh state
      _loadNextRound();
    });
  }


  void _showCompletionDialog() async{
    _logQuestionDisplayCounts();

    String uid = FirebaseAuth.instance.currentUser!.uid;

    bool? isReplay = await context.pushNamed('result', pathParameters: {
      'uid': uid,
      'game': 'matching',
      'level': widget.level.toString(),
      'correct': _point.toString(),
      'incorrect': _minus.toString()
    });

    if (isReplay ?? false) {
      resetGame();
    }
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

  void _checkMatch() async {
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

        Future.delayed(const Duration(milliseconds: 600), () {
          if (_questionMatched.every((matched) => matched)) {
            _loadNextRound();
          }
        });
      } else {
        setState(() {
          _minus++;
          final questionIndex = _questions.indexOf(question);
          final answerIndex = _answers.indexOf(answer);
          _questionMatched[questionIndex] = false;
          _answerMatched[answerIndex] = false;
          _showIncorrectImage = true; // Show the incorrect image
        });

        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 500); // Vibrate for 500 milliseconds
        }

        // Reset the image visibility after 1 second
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _showIncorrectImage = false; // Hide the incorrect image
          });
        });

        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
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
    final bool isIncorrect =
        !isMatched && isSelected; // Simplified incorrect match check
    final double size = isSelected ? 180 : 170; // Increase size when selected

    // Set background color: Green for correct, Red for incorrect, Transparent otherwise
    final Color backgroundColor = isMatched
        ? Colors.green
        : (isIncorrect ? Colors.red : Colors.transparent);

    return GestureDetector(
      onTap: () => _onSelectQuestion(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 16), // Reduced padding for balance
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
                BorderRadius.circular(12), // Slightly more rounded corners
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The image itself
              AnimatedOpacity(
                opacity: isMatched ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 10,
                  shadowColor: Colors.black,
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
    final bool isIncorrect =
        !isMatched && isSelected; // Simplified incorrect match check
    final double size = isSelected ? 180 : 170; // Increase size when selected

    // Set background color: Green for correct, Red for incorrect, Transparent otherwise
    final Color backgroundColor = isMatched
        ? Colors.green
        : (isIncorrect ? Colors.red : Colors.transparent);

    return GestureDetector(
      onTap: () => _onSelectAnswer(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 16), // Reduced padding for consistency
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
                BorderRadius.circular(12), // Slightly more rounded corners
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The answer text itself
              AnimatedOpacity(
                opacity: isMatched ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 10,
                  shadowColor: Colors.black,
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
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Đúng: $_point',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Sai: $_minus',
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
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
            child: Image.asset("assets/images/bg_matching_game.png",
                fit: BoxFit.fill),
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Lottie.asset('assets/lottiefiles/ants.json'),
          ),
          _buildScore(),
          Column(
            children: [
              SizedBox(
                height: 64,
              ),
              _buildGameBoard(),
            ],
          ),

          if (_showIncorrectImage)
            Center(
              child: Image.asset(
                "assets/images/error.png",
                width: 300,
                height: 300,
              ),
            ),
        ],
      ),
    );
  }
}
