import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final int _roundSize = 3;
  int _roundsRemaining = 7;
  late SharedPreferences prefs;
  Map<String, int> questionDisplayCount = {};

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
    prefs = await SharedPreferences.getInstance();
    _controller_worm = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _animation_worm = Tween<double>(
      begin: -100,
      end: 400, // Moving off-screen to the left
    ).animate(CurvedAnimation(
      parent: _controller_worm,
      curve: Curves.easeInOut,
    ));

    _controller_worm.repeat();

    if (matchingLevel.containsKey(widget.level)) {
      final folderPath = 'assets/matching_source/${widget.level}/';
      final List<String> images =
      matchingLevel[widget.level]!.map((e) => folderPath + e).toList();

      final List<String> answers = images
          .map((image) => image.split('/').last.split('.').first)
          .toList();

      setState(() {
        _originalQuestions = List.from(images);
        _originalAnswers = List.from(answers);
      });

      _initializeQuestionDisplayCount();

      _loadNextRound();

      for (String question in _questions) {
        questionDisplayCount[question] =
            (questionDisplayCount[question] ?? 0) + 1;
      }
    } else {
      final result = await showOkAlertDialog(
          context: context,
          title: 'Thông báo',
          message: 'Màn chơi hiện tại chưa ra mắt',
          canPop: false
      );
      context.pop();
    }
  }

  void _initializeQuestionDisplayCount() {
    for (String question in _originalQuestions) {
      questionDisplayCount[question] = 0;
    }
  }

  void _loadNextRound() {
    if (_roundsRemaining <= 0) {
      _showCompletionDialog();
      return;
    }

    setState(() {
      final random = Random();
      final roundSize = min(_roundSize, _originalQuestions.length);

      List<String> roundQuestions = [];
      List<String> roundAnswers = [];

      List<String> unusedQuestions = List.from(_originalQuestions);

      unusedQuestions.shuffle(random);

      for (int i = 0; i < roundSize; i++) {
        bool questionSelected = false;
        for (String question in unusedQuestions) {
          if ((questionDisplayCount[question] ?? 0) < 1) {
            roundQuestions.add(question);
            roundAnswers.add(_originalAnswers[_originalQuestions.indexOf(question)]);

            questionDisplayCount[question] = (questionDisplayCount[question] ?? 0) + 1;

            questionSelected = true;
            unusedQuestions.remove(question);
            break;
          }
        }

        if (!questionSelected && unusedQuestions.isNotEmpty) {
          String question = unusedQuestions.removeLast();
          roundQuestions.add(question);
          roundAnswers.add(_originalAnswers[_originalQuestions.indexOf(question)]);

          questionDisplayCount[question] = (questionDisplayCount[question] ?? 0) + 1;
        }
      }

      roundAnswers.shuffle(random);

      _questions = roundQuestions;
      _answers = roundAnswers;

      _questionMatched = List<bool>.filled(roundQuestions.length, false);
      _answerMatched = List<bool>.filled(roundAnswers.length, false);
      _questionSelected = List<bool>.filled(roundQuestions.length, false);
      _answerSelected = List<bool>.filled(roundAnswers.length, false);
      _selectedQuestions.clear();
      _selectedAnswers.clear();

      _roundsRemaining--;
    });
  }

  void _logQuestionDisplayCounts() {
    questionDisplayCount.forEach((question, count) {
      print('Question: $question displayed $count times');
    });
  }

  void resetGame() {
    setState(() {
      _point = 0;
      _minus = 0;
      _roundsRemaining = 7;
      _selectedQuestions.clear();
      _selectedAnswers.clear();
      _questionMatched = [];
      _answerMatched = [];
      _questionSelected = [];
      _answerSelected = [];
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

  void _onSelectQuestion(int index) async{
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_2.mp3'));
    }
    if (_questionMatched[index]) return;

    setState(() {
      _questionSelected[index] = !_questionSelected[index];
      _selectedQuestions.add(_questions[index]);
    });
    _checkMatch();
  }

  void _onSelectAnswer(int index) async{
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_2.mp3'));
    }
    if (_answerMatched[index]) return;

    setState(() {
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
        bool isMute = prefs.getBool('isMute') ?? false;
        if (!isMute) {
          await AudioPlayer().play(AssetSource('sound_effects/correct_sound_1.mp3'));
        }
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
        bool isMute = prefs.getBool('isMute') ?? false;
        if (!isMute) {
          await AudioPlayer().play(AssetSource('sound_effects/wrong_sound_1.mp3'));
        }
        setState(() {
          _minus++;
          final questionIndex = _questions.indexOf(question);
          final answerIndex = _answers.indexOf(answer);
          _questionMatched[questionIndex] = false;
          _answerMatched[answerIndex] = false;
          _showIncorrectImage = true;
        });

        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 500);
        }

        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _showIncorrectImage = false;
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
        !isMatched && isSelected;

    final screenWidth = MediaQuery.of(context).size.width;

    final baseWidth = 1280.0;

    double widthScaleFactor = screenWidth / baseWidth;
    final double size = (isSelected) ? 620 * widthScaleFactor : 600 * widthScaleFactor;

    final Color backgroundColor = isMatched
        ? Colors.green
        : (isIncorrect ? Colors.red : Colors.transparent);

    return GestureDetector(
      onTap: () => _onSelectQuestion(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
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
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              if (isMatched)
                Positioned(
                  child: Image.asset(
                    'assets/images/correct_icon.png',
                    width: 100,
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
        !isMatched && isSelected;
    final screenWidth = MediaQuery.of(context).size.width;

    final baseWidth = 1280.0;

    double widthScaleFactor = screenWidth / baseWidth;
    final double size = (isSelected) ? 620 * widthScaleFactor : 600 * widthScaleFactor;

    final Color backgroundColor = isMatched
        ? Colors.green
        : (isIncorrect ? Colors.red : Colors.transparent);

    return GestureDetector(
      onTap: () => _onSelectAnswer(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [

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
        title: const Text("MATCHING GAME"),
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
              const SizedBox(
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
