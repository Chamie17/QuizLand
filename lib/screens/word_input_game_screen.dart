import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class WordInputGameScreen extends StatefulWidget {
  WordInputGameScreen({super.key, required this.level});
  final int level;

  @override
  State<WordInputGameScreen> createState() => _WordInputGameScreenState();
}

class _WordInputGameScreenState extends State<WordInputGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> files = [];
  Map<String, String> audioTitles = {};
  String currentTitle = "";
  List<String> shuffledLetters = [];
  List<String> selectedLetters = [];
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  bool errorOccurred = false; // Flag to track error state

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    try {
      // Load the JSON file containing audio file paths and titles
      final String jsonString =
      await rootBundle.loadString('assets/audio_source/audio_files.json');
      final Map<String, dynamic> audioMap = jsonDecode(jsonString);

      files = List<String>.from(audioMap[widget.level.toString()] ?? []);
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
      // Reset the game state variables
      correctAnswers = 0;
      incorrectAnswers = 0;
      errorOccurred = false;
      selectedLetters.clear();
      shuffledLetters.clear();

      // Reload the files and titles
      files = [];
      audioTitles.clear();

      // Reinitialize the game by loading audio files and selecting the first one
      init();
    });
  }


  void loadNextAudio() async{
    if (files.isEmpty) {
      // Show completion dialog when no files remain
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
    final currentFile = files.removeAt(0);
    currentTitle = audioTitles[currentFile]!;
    shuffledLetters = currentTitle.split('')..shuffle(Random());
    selectedLetters = [];

    setState(() {
      _audioPlayer.setAsset('assets/audio_source/${widget.level}/$currentFile');
    });
    print(currentFile);
    _audioPlayer.play();
  }

  void onLetterTap(String letter, bool isInCenter) {
    setState(() {
      if (isInCenter) {
        // Move back to shuffled letters
        selectedLetters.remove(letter);
        shuffledLetters.add(letter);
      } else {
        // Move to the center
        shuffledLetters.remove(letter);
        selectedLetters.add(letter);
      }
    });
  }

  void checkResult() async {
    if (selectedLetters.join('') == currentTitle) {
      setState(() {
        correctAnswers++; // Increment correct answer count
      });
      loadNextAudio(); // Proceed to next word
    } else {
      setState(() {
        incorrectAnswers++; // Increment incorrect answer count
        errorOccurred = true; // Show error image
        selectedLetters.clear(); // Reset selected letters
        shuffledLetters.clear();
        shuffledLetters.addAll(currentTitle.split('')); // Move selected letters back to shuffled letters
        shuffledLetters.shuffle(Random()); // Shuffle shuffled letters again
      });

      // Trigger vibration if the device has a vibrator
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500); // Vibrate for 500 milliseconds
      }

      // Hide error image after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          errorOccurred = false; // Hide error image after 1 second
        });
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
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
                    style: TextStyle(
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
                    style: TextStyle(
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
              SizedBox(
                height: 72,
              ),
              // Audio Play Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 72),
                child: GestureDetector(
                  onTap: () {
                    _audioPlayer.seek(Duration.zero);
                    _audioPlayer.play();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.replay_outlined,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _audioPlayer.seek(Duration.zero);
                            _audioPlayer.play();
                          },
                        ),
                        Text(
                          "Nghe lại lần nữa",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Spacer(),
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

              Spacer(),

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
              SizedBox(
                height: 80,
              ),
              // Check Result Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E3A8A)),
                onPressed: checkResult,
                child: const Text("Kiểm tra kết quả", style: TextStyle(color: Colors.white),),
              ),
              SizedBox(
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
