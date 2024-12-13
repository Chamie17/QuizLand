import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:quizland_app/models/user_profile.dart';
import 'package:quizland_app/screens/matching_game_screen.dart';
import 'package:quizland_app/screens/word_input_game_screen.dart';
import 'package:quizland_app/services/user_profile_service.dart';

import 'arrange_sentence_game_screen.dart';
import 'listening_game_screen.dart';

class ResultScreen extends StatefulWidget {
  ResultScreen(
      {super.key,
      required this.level,
      required this.game,
      required this.correct,
      required this.incorrect,
      required this.uid});
  int level;
  String game;
  int correct;
  int incorrect;
  String uid;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  void saveResult() async {
    int star = getStar();
    int total = getTotal();

    GameHistory gameHistory = GameHistory(
      level: widget.level,
      total: total,
      correct: widget.correct,
      incorrect: widget.incorrect,
      star: star,
    );

    UserProfile userProfile = UserProfile(
      uid: widget.uid,
      history: {
        widget.game: [gameHistory],
      },
    );

    await userProfileService.saveResult(userProfile);
  }

  @override
  void initState() {
    print(
        '${widget.uid} ${widget.game} ${widget.level} ${widget.correct} ${widget.incorrect}');
    saveResult();
    super.initState();
  }

  int getTotal() {
    return widget.incorrect > widget.correct
        ? 0
        : widget.correct - widget.incorrect;
  }

  int getStar() {
    int total = getTotal();
    if (total == 0) return 0;

    int correct = widget.correct;
    int incorrect = widget.incorrect;

    if (incorrect == 0) return 3;

    double percent = total / correct;
    if (percent > 0.7) return 2;
    if (percent > 0.3) return 1;
    return 0;
  }

  void _handleGoHome() async {
    context.pushReplacementNamed('login');
  }

  void _handleReplay() async {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    'assets/images/result_asset/bg_result.png',
                    fit: BoxFit.fill,
                  ))),
          Positioned.fill(
              child: Image.asset('assets/images/result_asset/board.png')),
          Positioned(
            left: 0,
            right: 0,
            top: 250,
            child: SizedBox(
              width: 100,
              height: 100,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  'assets/images/result_asset/${getStar()}_star.png',
                ),
              ),
            ),
          ),
          Positioned(
              top: 25,
              left: 0,
              bottom: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Đúng: ${widget.correct} lần",
                    style: GoogleFonts.pacifico(
                      textStyle: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  Text(
                    "Sai: ${widget.incorrect} lần",
                    style: GoogleFonts.pacifico(
                      textStyle: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const Divider(
                    color: Colors.white,
                    endIndent: 100,
                    indent: 100,
                    thickness: 5,
                  ),
                  Text(
                    "Tổng điểm: ${getTotal()}đ",
                    style: GoogleFonts.pacifico(
                      textStyle: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ],
              )),
          Positioned(
              left: 0,
              right: 0,
              bottom: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: _handleReplay,
                      icon: SizedBox(
                        height: 100,
                        child: Image.asset(
                            'assets/images/result_asset/replay_button.png'),
                      )),
                  IconButton(
                      onPressed: _handleGoHome,
                      icon: SizedBox(
                        height: 100,
                        child: Image.asset(
                            'assets/images/result_asset/home_button.png'),
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: SizedBox(
                        height: 100,
                        child: Image.asset(
                            'assets/images/result_asset/next_button.png'),
                      ))
                ],
              )),
          Positioned(
              left: 0,
              right: 0,
              bottom: 220,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Chơi lại",
                    style: GoogleFonts.pacifico(
                      textStyle:
                          TextStyle(fontSize: 24, color: Colors.brown.shade800),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Text(
                    "Trang chủ",
                    style: GoogleFonts.pacifico(
                      textStyle:
                          TextStyle(fontSize: 24, color: Colors.brown.shade800),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Text(
                    "Tiếp tục",
                    style: GoogleFonts.pacifico(
                      textStyle:
                          TextStyle(fontSize: 24, color: Colors.brown.shade800),
                    ),
                  ),
                ],
              )),
          if (getStar() == 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
              child: SizedBox(
                  height: 250,
                  child: Lottie.asset('assets/lottiefiles/0_star_ani.json')))
        ],
      ),
    );
  }
}
