import 'dart:convert';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class WordInputGameScreen extends StatefulWidget {
  WordInputGameScreen({super.key, required this.level});
  final int level;

  @override
  State<WordInputGameScreen> createState() => _WordInputGameScreenState();
}

class _WordInputGameScreenState extends State<WordInputGameScreen> {
  List<String> files = [];
  Map<String, String> audioTitles = {};
  String currentTitle = "";
  List<String> shuffledLetters = [];
  List<String> selectedLetters = [];
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  bool errorOccurred = false;
  late SharedPreferences prefs;
  var currentFile;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    try {
      final String jsonString =
      await rootBundle.loadString('assets/audio_source/audio_files.json');
      final Map<String, dynamic> audioMap = jsonDecode(jsonString);

      files = List<String>.from(audioMap[widget.level.toString()] ?? []);

      if (files.isEmpty) {
        final result = await showOkAlertDialog(
            context: context,
            title: 'Thông báo',
            message: 'Màn chơi hiện tại chưa ra mắt',
            canPop: false
        );
        context.pop();
      }

      for (var file in files) {
        audioTitles[file] = file.split('.')[0];
      }

      if (files.isNotEmpty) {
        loadNextAudio();
      }
    } catch (e) {
      debugPrint("Error loading audio files: $e");

    }
  }

  void resetGame() {
    setState(() {
      correctAnswers = 0;
      incorrectAnswers = 0;
      errorOccurred = false;
      selectedLetters.clear();
      shuffledLetters.clear();
      files = [];
      audioTitles.clear();
      init();
    });
  }

  void loadNextAudio() async{
    if (files.isEmpty) {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      bool? isReplay = await context.pushNamed('result', pathParameters: {
        'uid': uid,
        'game': 'wordInput',
        'level': widget.level.toString(),
        'correct': correctAnswers.toString(),
        'incorrect': incorrectAnswers.toString()
      });

      if (isReplay ?? false) {
        resetGame();
      }

      return;
    }

    // Load the next audio file
    currentFile = files.removeAt(0);
    currentTitle = audioTitles[currentFile]!;
    shuffledLetters = currentTitle.split('')..shuffle(Random());
    selectedLetters = [];

    setState(() {

    });
    await AudioPlayer().play(AssetSource('audio_source/${widget.level}/$currentFile'));
    print(currentFile);
  }

  void onLetterTap(String letter, bool isInCenter) async{
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_2.mp3'));
    }
    setState(() {
      if (isInCenter) {
        selectedLetters.remove(letter);
        shuffledLetters.add(letter);
      } else {
        shuffledLetters.remove(letter);
        selectedLetters.add(letter);
      }
    });
  }

  void checkResult() async {
    if (selectedLetters.join('') == currentTitle) {
      bool isMute = prefs.getBool('isMute') ?? false;
      if (!isMute) {
        await AudioPlayer().play(AssetSource('sound_effects/correct_sound_1.mp3'));
      }
      setState(() {
        correctAnswers++;
      });
      loadNextAudio();
    } else {
      bool isMute = prefs.getBool('isMute') ?? false;
      if (!isMute) {
        await AudioPlayer().play(AssetSource('sound_effects/wrong_sound_1.mp3'));
      }
      setState(() {
        incorrectAnswers++;
        errorOccurred = true;
        selectedLetters.clear();
        shuffledLetters.clear();
        shuffledLetters.addAll(currentTitle.split(''));
        shuffledLetters.shuffle(Random());
      });

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }

      // Hide error image after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          errorOccurred = false;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("WORD INPUT GAME"),
      ),
      body: Stack(
        children: [
          const Row(),
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg_word_input.jpg",
              fit: BoxFit.fill,
            ),
          ),

          Positioned(
            top: 250,
            right: 0,
            left: 0,
            child: Image.asset(
              height: 300,
              'assets/images/woodboard.png', // Replace with your image path
              fit: BoxFit.fill,
            ),
          ),

          // Score Display
          Positioned(
            left: 20,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Đúng: $correctAnswers',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
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
                    border: Border.all(color: Colors.black)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sai: $incorrectAnswers',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Game UI
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 72,
              ),
              // Audio Play Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72),
                child: GestureDetector(
                  onTap: () async {
                    await AudioPlayer().play(AssetSource('audio_source/${widget.level}/$currentFile'));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.replay_outlined,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            await AudioPlayer().play(AssetSource('audio_source/${widget.level}/$currentFile'));
                          },
                        ),
                        const Text(
                          "Nghe lại lần nữa",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
              // Drop Zone for Selected Letters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: List.generate(
                    currentTitle.length,
                        (index) {
                      // Check if a letter is selected for this position
                      String? letter =
                      index < selectedLetters.length ? selectedLetters[index] : null;

                      return GestureDetector(
                        onTap: () {
                          if (letter != null) onLetterTap(letter, true); // Allow removal of selected letters
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: letter != null
                                ? Border.all(color: Colors.black, width: 1)
                                : const BorderDirectional(
                              bottom: BorderSide(color: Colors.black, width: 2),
                            ),
                            borderRadius: letter != null ? BorderRadius.circular(8) : null,
                            color: letter != null ? Colors.yellow[100] : Colors.transparent,
                          ),
                          child: Text(
                            letter?.toUpperCase() ?? "", // Show the letter or leave it blank
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const Spacer(),

              // Shuffled Letters
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: shuffledLetters
                    .map(
                      (letter) => GestureDetector(
                    onTap: () => onLetterTap(letter, false),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.yellow[100],
                      ),
                      child: Text(
                        letter.toUpperCase(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(
                height: 80,
              ),
              // Check Result Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E3A8A)),
                onPressed: checkResult,
                child: const Text("Kiểm tra kết quả", style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),

          if (errorOccurred)
            Center(
              child: Image.asset(
                height: 300,
                'assets/images/error.png', // Replace with your image path
                fit: BoxFit.fill,
              ),
            ),
        ],
      ),
    );
  }
}
