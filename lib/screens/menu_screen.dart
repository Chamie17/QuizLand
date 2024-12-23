import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quizland_app/screens/arrange_sentence_game_screen.dart';
import 'package:quizland_app/screens/listening_game_screen.dart';
import 'package:quizland_app/screens/matching_game_screen.dart';
import 'package:quizland_app/screens/word_input_game_screen.dart';

import '../models/user_profile.dart';
import '../services/user_profile_service.dart';

class MenuScreen extends StatefulWidget {
  MenuScreen(
      {super.key,
      required this.backgroundColor,
      required this.boxColor,
      required this.gameName});
  Color backgroundColor;
  Color boxColor;
  String gameName;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late List<GameHistory> gameHistory = [];
  bool isLoading = true;

  void init() async {
    var user = FirebaseAuth.instance.currentUser;
    gameHistory = await userProfileService.getLevelsHistory(widget.gameName, user!.uid);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _animation = Tween<double>(begin: 400, end: -100).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleEnterGameScreen(int level) async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        switch (widget.gameName) {
          case 'matching':
            return MatchingGameScreen(level: level);
          case 'listen':
            return ListeningGameScreen(level: level);
          case 'wordInput':
            return WordInputGameScreen(level: level);
          case 'arrangeSentence':
            return ArrangeSentenceGameScreen(level: level);
          default:
            return MatchingGameScreen(level: level);
        }
      },
    ));
  }

  void _handleEnterLockedLevel() async {
    final result = await showOkAlertDialog(
      context: context,
      title: 'Thông báo',
      message: 'Màn chơi hiện tại chưa được mở khoá, hãy vượt qua màn chơi phía trước để mở nhé!',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isNewUser = gameHistory.isEmpty;
    int unlockedLevel = gameHistory.isNotEmpty ? gameHistory.length + 1 : 1;

    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Container(
            color: widget.backgroundColor,
          ),
          Positioned(
            left: 0,
            top: 30,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset(
                'assets/images/arrow_back.png',
                height: 60,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Lottie.asset('assets/lottiefiles/monkey_top.json', height: 220),
          ),
          const Positioned(
            left: 65,
            top: 85,
            child: Text(
              "Levels",
              style: TextStyle(fontSize: 90, fontFamily: 'Kablammo'),
            ),
          ),
          Positioned(
            left: -50,
            right: -50,
            bottom: -10,
            child: Lottie.asset('assets/lottiefiles/grass_animation.json'),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                left: _animation.value,
                bottom: 40,
                child: SizedBox(
                  height: 100,
                  child: Lottie.asset('assets/lottiefiles/banana.json'),
                ),
              );
            },
          ),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Positioned(
              left: 15,
              top: 220,
              child: SizedBox(
                width: 380,
                height: 800,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    GameHistory? history;
                    if (!isNewUser && index < gameHistory.length) {
                      history = gameHistory[index];
                    }

                    bool isLevelUnlocked = index + 1 <= unlockedLevel;

                    return InkWell(
                      onTap: () {
                        if (isLevelUnlocked) {
                          _handleEnterGameScreen(index + 1);
                        } else {
                          _handleEnterLockedLevel();
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: widget.boxColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${index + 1}', // Display the level number
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 36,
                                fontFamily: 'Kablammo',
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Show star icons for unlocked levels
                                if (!isNewUser && history != null && history.star > 0)
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(0.5, 0.5),
                                      ),
                                    ],
                                  ),
                                if (!isNewUser && history != null && history.star > 1)
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(0.5, 0.5),
                                      ),
                                    ],
                                  ),
                                if (!isNewUser && history != null && history.star > 2)
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(0.5, 0.5),
                                      ),
                                    ],
                                  ),
                                if (!isLevelUnlocked)
                                  const Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(0.5, 0.5),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

