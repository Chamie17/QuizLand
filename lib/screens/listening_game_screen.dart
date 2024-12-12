import 'dart:convert';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart'; // Import the vibration package
import 'dart:math'; // For random selection

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

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      duration: Duration(seconds: 10), // Animation duration
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
      duration: Duration(seconds: 8), // Animation duration
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
    // Load the audio files and their titles from the JSON
    final String jsonString =
    await rootBundle.loadString('assets/audio_source/audio_files.json');
    final Map<String, dynamic> audioMap = jsonDecode(jsonString);

    // Load audio files for the selected level
    files = List<String>.from(audioMap[widget.level.toString()] ?? []);

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

  Future<void> loadNextRound() async {
    if (roundsRemaining <= 0) {
      // No more rounds left
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Game Over!"),
          content: Text("You have completed all rounds."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  answeredPairs.clear(); // Reset answered pairs
                  roundsRemaining = 7; // Reset rounds count
                  files.shuffle(); // Shuffle the files for new game
                });
                loadNextRound();
              },
              child: Text("Restart"),
            ),
          ],
        ),
      );
      return;
    }

    // Handle rounds based on round logic
    if (roundsRemaining == 7) {
      // Round 1: Display first 3 items
      currentRoundFiles = files.take(3).toList();
    } else if (roundsRemaining == 6) {
      // Round 2: Display next 3 items
      currentRoundFiles = files.skip(3).take(3).toList();
    } else if (roundsRemaining == 5) {
      // Round 3: Display 1 last item and 2 random items
      currentRoundFiles = [files[6]] + _getRandomItems(2, 5);
    } else {
      // Rounds 4 to 7: Random 3 items from the remaining items
      currentRoundFiles = _getRandomItems(3, files.length);
    }

    // Fetch metadata titles for the current round files
    currentRoundAnswers = [];
    for (var file in currentRoundFiles) {
      final title = await getAudioTitle(file); // Fetch metadata title
      if (title != null) {
        currentRoundAnswers.add(title); // Add title to answers
      }
    }

    // Shuffle the answers to make them unpredictable
    currentRoundAnswers.shuffle();

    setState(() {});
    roundsRemaining--; // Decrease remaining rounds
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

    // Set the selected audio file when it's played
    setState(() {
      selectedAudioFile = fileName;
      selectedAnswer = null; // Reset selected answer when a new audio is played
      isIncorrect = false; // Reset incorrect state
    });
  }

  void checkAnswer(String selectedAnswerText) async {
    setState(() {
      selectedAnswer = selectedAnswerText; // Set the selected answer
    });

    // Extract the correct metadata title dynamically
    final correctTitle = await getAudioTitle(selectedAudioFile!);

    if (selectedAnswer == correctTitle) {
      // Correct answer
      setState(() {
        correctAnswers++; // Increment correct answers count
        // Add the correct pair to answeredPairs
        answeredPairs.add(selectedAudioFile!);
        // Remove the correct pair from current round files and answers
        currentRoundFiles.remove(selectedAudioFile);
        currentRoundAnswers.remove(selectedAnswer);
      });

      // Stop the audio immediately after selecting the correct answer
      await _audioPlayer.stop();

      // If the current round is complete, move to the next round
      if (answeredPairs.length % _roundSize == 0) {
        loadNextRound();
      }
    } else {
      // Incorrect answer: trigger vibration and show error
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500); // Vibrate for 500 milliseconds
      }

      // Increment incorrect answers count
      setState(() {
        incorrectAnswers++; // Increment incorrect answers count
        isIncorrect = true; // Show error image
      });

      // Reset the selection and hide error image after a short delay
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          selectedAudioFile = null;
          selectedAnswer = null; // Reset the incorrect selection state
          isIncorrect = false; // Hide error image
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Nghe và đoán")),
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
                    alignment: Alignment.center, // Center alignment for proper flipping
                    transform: Matrix4.identity()..scale(-1.0, 1.0), // Flip horizontally
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
                    alignment: Alignment.center, // Center alignment for proper flipping
                    transform: Matrix4.identity()..scale(-1.0, 1.0), // Flip horizontally
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
                    alignment: Alignment.center, // Center alignment for proper flipping
                    transform: Matrix4.identity()..scale(-1.0, 1.0), // Flip horizontally
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
              // Error image when incorrect answer
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
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF8E3A1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedAudioFile == currentRoundFiles[index]
                                        ? Colors.green // Green border for selected audio item
                                        : Colors.orange,
                                    width: 3,
                                  ),
                                ),
                                child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    width: selectedAudioFile == currentRoundFiles[index]
                                        ? 120
                                        : 100,
                                    alignment: Alignment.center,
                                    child: Row(children: [
                                      Icon(
                                        Icons.volume_up,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10),
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
                          return SizedBox.shrink();
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
                              onTap: () {
                                checkAnswer(currentRoundAnswers[index]);
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF8E3A1),
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
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
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
                    'Correct: $correctAnswers',
                    style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold, ),
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
                    'Incorrect: $incorrectAnswers',
                    style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
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
