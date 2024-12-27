import 'dart:convert';
import 'dart:io';
import 'dart:math'; // For random selection

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart'; // Import the vibration package

class ListeningGameScreen extends StatefulWidget {
  ListeningGameScreen({super.key, required this.level});
  int level;

  @override
  State<ListeningGameScreen> createState() => _ListeningGameScreenState();
}

class _ListeningGameScreenState extends State<ListeningGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _controller2;
  late Animation<double> _animation2;
  List<String> files = [];
  Map<String, String> audioTitles = {}; // Maps audio file to its title
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<String> currentRoundFiles = [];
  List<String> currentRoundAnswers = [];
  int roundsRemaining = 7; // Number of rounds remaining
  final int _roundSize = 3; // Number of pairs per round

  // Track selected audio and answer
  String? selectedAudioFile;
  String? selectedAnswer;

  // Track answered pairs
  List<String> answeredPairs = []; // To keep track of correct answers

  // Track incorrect answer state and display error image
  bool isIncorrect = false;

  int correctAnswers = 0;
  int incorrectAnswers = 0;

  late SharedPreferences prefs;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    _controller2.dispose();

    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 10), // Animation duration
      vsync: this,
    );

    // Define the animation from screen width to -100 (off-screen)
    _animation = Tween<double>(
      begin: -200,
      end: 400, // Moving off-screen to the left
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller.repeat();

    _controller2 = AnimationController(
      duration: const Duration(seconds: 8), // Animation duration
      vsync: this,
    );

    // Define the animation from screen width to -100 (off-screen)
    _animation2 = Tween<double>(
      begin: 420,
      end: -400, // Moving off-screen to the left
    ).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller2.repeat();
    init();
  }

  void init() async {
    prefs = await SharedPreferences.getInstance();
    // Load the audio files and their titles from the JSON
    final String jsonString =
    await rootBundle.loadString('assets/audio_source/audio_files.json');
    final Map<String, dynamic> audioMap = jsonDecode(jsonString);

    // Load audio files for the selected level
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

    // Load audio titles (manually from JSON or file)
    for (var file in files) {
      audioTitles[file] = file.split('.')[0]; // Example: Use filename without extension as title
    }

    setState(() {});
    loadNextRound();
  }

  Future<String?> getAudioTitle(String fileName) async {
    final assetPath = 'assets/audio_source/${widget.level}/$fileName';
    final byteData = await rootBundle.load(assetPath);

    // Get a temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');

    // Write the asset content to a temporary file
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());

    // Read metadata and return title
    final metadata = await readMetadata(tempFile, getImage: false);
    return metadata.title;
  }

  void resetGame() {
    setState(() {
      roundsRemaining = 7;
      correctAnswers = 0;
      incorrectAnswers = 0;
      answeredPairs.clear();
      currentRoundFiles.clear();
      currentRoundAnswers.clear();
      selectedAudioFile = null;
      selectedAnswer = null;
      isIncorrect = false;
      loadNextRound();
    });
  }

  Future<void> loadNextRound() async {
    selectedAnswer = null;
    selectedAudioFile = null;
    if (roundsRemaining <= 0) {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      bool? isReplay = await context.pushNamed('result', pathParameters: {
        'uid': uid,
        'game': 'listen',
        'level': widget.level.toString(),
        'correct': correctAnswers.toString(),
        'incorrect': incorrectAnswers.toString()
      });

      if (isReplay ?? false) {
        resetGame();
      }

      return;
    }

    if (roundsRemaining == 7) {
      currentRoundFiles = files.take(3).toList();
    } else if (roundsRemaining == 6) {
      currentRoundFiles = files.skip(3).take(3).toList();
    } else if (roundsRemaining == 5) {
      currentRoundFiles = [files[6]] + _getRandomItems(2, 5);
    } else {
      currentRoundFiles = _getRandomItems(3, files.length);
    }

    currentRoundAnswers = [];
    for (var file in currentRoundFiles) {
      final title = await getAudioTitle(file);
      if (title != null) {
        currentRoundAnswers.add(title);
      }
    }

    currentRoundAnswers.shuffle();

    setState(() {});
    roundsRemaining--;
  }

  List<String> _getRandomItems(int count, int maxIndex) {
    final random = Random();
    List<String> items = [];
    while (items.length < count) {
      String randomItem = files[random.nextInt(maxIndex)];
      if (!items.contains(randomItem)) {
        items.add(randomItem);
      }
    }
    return items;
  }

  void playAudio(String fileName) async {
    await _audioPlayer.play(AssetSource('audio_source/${widget.level}/$fileName'));

    setState(() {
      selectedAudioFile = fileName;
      selectedAnswer = null;
      isIncorrect = false;
    });
  }

  void checkAnswer(String selectedAnswerText) async {
    setState(() {
      selectedAnswer = selectedAnswerText;
    });

    final correctTitle = await getAudioTitle(selectedAudioFile!);

    if (selectedAnswer == correctTitle) {
      bool isMute = prefs.getBool('isMute') ?? false;
      if (!isMute) {
        await AudioPlayer().play(AssetSource('sound_effects/correct_sound_1.mp3'));
      }
      setState(() {
        correctAnswers++;
        answeredPairs.add(selectedAudioFile!);
        currentRoundFiles.remove(selectedAudioFile);
        currentRoundAnswers.remove(selectedAnswer);
        selectedAnswer = null;
        selectedAudioFile = null;
      });

      await _audioPlayer.stop();

      if (answeredPairs.length % _roundSize == 0) {
        loadNextRound();
      }
    } else {
      bool isMute = prefs.getBool('isMute') ?? false;
      if (!isMute) {
        await AudioPlayer().play(AssetSource('sound_effects/wrong_sound_1.mp3'));
      }

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }

      setState(() {
        incorrectAnswers++;
        isIncorrect = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          selectedAudioFile = null;
          selectedAnswer = null;
          isIncorrect = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("LISTENING GAME")),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset("assets/images/bg_music.jpg", fit: BoxFit.fill),
          ),

          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Positioned(
                left: _animation2.value,
                top: 40,
                child: SizedBox(
                  height: 50,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, 1.0),
                    child: Lottie.asset('assets/lottiefiles/eagle.json'),
                  ),

                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Positioned(
                left: _animation2.value - 30,
                top: 20,
                child: SizedBox(
                  height: 50,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, 1.0),
                    child: Lottie.asset('assets/lottiefiles/eagle.json'),
                  ),

                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Positioned(
                left: _animation2.value - 30,
                top: 70,
                child: SizedBox(
                  height: 50,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..scale(-1.0, 1.0),
                    child: Lottie.asset('assets/lottiefiles/eagle.json'),
                  ),

                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                left: _animation.value,
                bottom: 40,
                child: SizedBox(
                  height: 200,
                  child: Lottie.asset('assets/lottiefiles/camel.json'),
                ),
              );
            },
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        if (index < currentRoundFiles.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                playAudio(currentRoundFiles[index]);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8E3A1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedAudioFile == currentRoundFiles[index]
                                        ? Colors.green
                                        : Colors.orange,
                                    width: 3,
                                  ),
                                ),
                                child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: selectedAudioFile == currentRoundFiles[index]
                                        ? 120
                                        : 100,
                                    alignment: Alignment.center,
                                    child: Row(children: [
                                      const Icon(
                                        Icons.volume_up,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        height: 30,
                                        width: 60,
                                        child: Image.asset(
                                          'assets/images/sound_wave.png',
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ])),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ),
                  ),
                  // Column for Shuffled answers
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        if (index < currentRoundAnswers.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                bool isMute = prefs.getBool('isMute') ?? false;
                                if (!isMute) {
                                  await AudioPlayer().play(AssetSource('sound_effects/click_sound_2.mp3'));
                                }
                                checkAnswer(currentRoundAnswers[index]);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8E3A1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedAnswer == currentRoundAnswers[index]
                                        ? Colors.green // Green border for selected answer
                                        : Colors.orange,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    currentRoundAnswers[index],
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isIncorrect) // Show error image
            Center(
              child: Image.asset(
                "assets/images/error.png",
                width: 300,
                height: 300,
              ),
            ),
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
                    style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold, ),
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
                    style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
