import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quizland_app/screens/detail_rank_screen.dart';
import 'package:quizland_app/services/user_serivce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../services/user_profile_service.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> top3Users = [];
  List<Map<String, dynamic>> users = [];
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<double> _scaleAnimation1;
  late Animation<double> _scaleAnimation2;
  late Animation<double> _scaleAnimation3;

  late SharedPreferences prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    top3Users = await userProfileService.getTop3UsersByStarAndTotalScore();
    users.add(await userService.getUserById(top3Users[0]['uid']));
    users.add(await userService.getUserById(top3Users[1]['uid']));
    users.add(await userService.getUserById(top3Users[2]['uid']));
    print(users);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    init();

    _controller1 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation1 = Tween<double>(begin: 0.9, end: 0.95).animate(
      CurvedAnimation(parent: _controller1, curve: Curves.easeInOut),
    );
    _controller1.repeat(reverse: true);

    // Second animation variation: Faster zoom-in/zoom-out effect
    _controller2 = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _scaleAnimation2 = Tween<double>(begin: 0.9, end: 0.95).animate(
      CurvedAnimation(parent: _controller2, curve: Curves.easeInOut),
    );
    _controller2.repeat(reverse: true);

    // Third animation variation: Slower, more exaggerated zoom-in/zoom-out effect
    _controller3 = AnimationController(
      duration: const Duration(seconds: 1, milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation3 = Tween<double>(begin: 0.9, end: 0.95).animate(
      CurvedAnimation(parent: _controller3, curve: Curves.easeInOut),
    );
    _controller3.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  void _handleButton(String game) async{
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_1.mp3'));
    }
    switch (game) {
      case 'matching':
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRankScreen(
                gameName: 'matching',
              ),
            ));
        break;
      case 'listen':
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRankScreen(
                gameName: 'listen',
              ),
            ));
        break;
      case 'wordInput':
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRankScreen(
                gameName: 'wordInput',
              ),
            ));
        break;
      case 'arrangeSentence':
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRankScreen(
                gameName: 'arrangeSentence',
              ),
            ));
        break;
      default:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailRankScreen(
                gameName: 'quizland',
              ),
            ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bảng xếp hạng QuizLand"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/rank_bg.png",
              fit: BoxFit.fill,
            ),
          ),

          Positioned(
            top: -100,
            left: 0,
            child: SizedBox(
              height: 500,
              child: Lottie.asset('assets/lottiefiles/fireworks.json'),
            ),
          ),

          Positioned(
            top: -100,
            right: 0,
            child: SizedBox(
              height: 500,
              child: Lottie.asset('assets/lottiefiles/fireworks.json'),
            ),
          ),

          // Apply first animation to the third avatar and frame
          users.isNotEmpty
              ? Positioned(
                  left: 89,
                  bottom: 350 + 110,
                  child: SizedBox(
                    height: 70,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation1,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation1.value,
                          child: CachedNetworkImage(
                            imageUrl: users[2]['imageUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : const Positioned(
                  left: 105,
                  bottom: 350 + 125,
                  child: CircularProgressIndicator(),
                ),

          // Apply second animation to the first avatar and frame (faster effect)
          users.isNotEmpty
              ? Positioned(
                  left: 177,
                  bottom: 395 + 130,
                  child: SizedBox(
                    height: 70,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation2,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation2.value,
                          child: CachedNetworkImage(
                            imageUrl: users[0]['imageUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : const Positioned(
                  left: 195,
                  bottom: 395 + 145,
                  child: CircularProgressIndicator(),
                ),

          // Apply third animation to the second avatar and frame (slower and more exaggerated)
          users.isNotEmpty
              ? Positioned(
                  right: 87,
                  bottom: 362 + 110,
                  child: SizedBox(
                    height: 70,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation3,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation3.value,
                          child: CachedNetworkImage(
                            imageUrl: users[1]['imageUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : const Positioned(
                  right: 102,
                  bottom: 362 + 125,
                  child: CircularProgressIndicator(),
                ),

          // Medals and Frames (Apply the same animations to frames)
          Positioned(
            left: 90,
            bottom: 350,
            child: SizedBox(
              height: 80,
              child: AnimatedBuilder(
                animation: _scaleAnimation1,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation1.value,
                    child: Image.asset("assets/images/brone.png"),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 170,
            bottom: 395,
            child: SizedBox(
              height: 100,
              child: AnimatedBuilder(
                animation: _scaleAnimation2,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation2.value,
                    child: Image.asset("assets/images/gold.png"),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 80,
            bottom: 362,
            child: SizedBox(
              height: 80,
              child: AnimatedBuilder(
                animation: _scaleAnimation3,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation3.value,
                    child: Image.asset("assets/images/silver.png"),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 80,
            bottom: 350 + 100,
            child: SizedBox(
              height: 80,
              child: AnimatedBuilder(
                animation: _scaleAnimation1,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation1.value,
                    child: Image.asset("assets/images/frame_brone.png"),
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 153,
            bottom: 395 + 120,
            child: SizedBox(
              height: 100,
              child: AnimatedBuilder(
                animation: _scaleAnimation2,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation2.value,
                    child: Image.asset("assets/images/frame_gold.png"),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 70,
            bottom: 362 + 100,
            child: SizedBox(
              height: 100,
              child: AnimatedBuilder(
                animation: _scaleAnimation3,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation3.value,
                    child: Image.asset("assets/images/frame_silver.png"),
                  );
                },
              ),
            ),
          ),

          Positioned(
              left: 0,
              right: 0,
              bottom: 290,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.brown,
                          highlightColor: Colors.yellow,
                          child: Text(
                            users.isNotEmpty ? users[2]['name'] : "Loading...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                  Container(
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.brown,
                          highlightColor: Colors.yellow,
                          child: Text(
                            users.isNotEmpty ? users[0]['name'] : "Loading...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                  Container(
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.brown,
                          highlightColor: Colors.yellow,
                          child: Text(
                            users.isNotEmpty ? users[1]['name'] : "Loading...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )),
                ],
              )),

          // Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _handleButton('matching'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFd5c1a6),
                  side: const BorderSide(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: const Text(
                  "Nhà kết nối",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _handleButton('arrangeSentence'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF80b2b3),
                  side: const BorderSide(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: const Text(
                  "Nhà giao tiếp",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _handleButton('wordInput'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFc1a3ef),
                  side: const BorderSide(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: const Text(
                  "Nhà từ vựng",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _handleButton('listen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75cde8),
                  side: const BorderSide(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: const Text(
                  "Nhà âm thanh",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _handleButton('all'),
                child: SizedBox(
                    height: 100,
                    child: Image.asset('assets/images/detail_rank_button.png')),
              ))
        ],
      ),
    );
  }
}
