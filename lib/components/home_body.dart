import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/screens/menu_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key, required this.bottomNavigationBarKey});
  final GlobalKey bottomNavigationBarKey;

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late AnimationController _musicController;
  late Animation<double> _musicAnimation;

  late AnimationController _wordController;
  late Animation<double> _wordAnimation;

  var _keyMusic = GlobalKey();
  var _keyWord = GlobalKey();
  var _keyCommunicate = GlobalKey();
  var _keyConnect = GlobalKey();

  late SharedPreferences prefs;

  @override
  void initState() {
    init();
    super.initState();

    // sun
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * 3.14159) // 0 to 360 degrees
        .animate(_controller);

    // music
    _musicController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Total animation duration
    );
    _musicAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _musicController, curve: Curves.easeInOut),
    );
    _musicController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _musicController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _musicController.forward();
      }
    });
    _musicController.forward();

    _wordController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Total animation duration
    );
    _wordAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _wordController, curve: Curves.easeInOut),
    );
    _wordController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _wordController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _wordController.forward();
      }
    });
    _wordController.forward();


  }

  void init() async {
    prefs = await SharedPreferences.getInstance();
    targets.add(
        TargetFocus(
            identify: "Target 1",
            keyTarget: _keyMusic,
            contents: [
              TargetContent(
                  align: ContentAlign.bottom,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nhà âm nhạc",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 36.0
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text("Tại ngôi nhà này, nhiệm vụ của bạn là: \n\n"
                            "•	Nhấp chọn nghe các âm thanh.\n\n"
                            "•	Chọn từ đúng với nghĩa của âm thanh đó.\n\n"
                            "Nếu trả lời đúng hết, bạn sẽ nhận được ngôi sao từ chú khỉ ⭐️⭐️⭐️",
                          style: TextStyle(
                            fontSize: 24,
                              color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),),
                      )
                    ],
                  )
              )
            ]
        )
    );

    targets.add(
        TargetFocus(
            identify: "Target 2",
            keyTarget: _keyWord,
            contents: [
              TargetContent(
                  align: ContentAlign.left,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nhà từ vựng",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 36.0
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text("Tại ngôi nhà này, nhiệm vụ của bạn là: \n\n"
                            "•	Nhấp chọn nghe âm thanh.\n\n"
                            "•	Sắp xếp các mảnh chữ cái thành từ vựng mà bạn nghe được.\n\n"
                            "Nếu trả lời đúng hết, bạn sẽ nhận được ngôi sao từ chú khỉ ⭐️⭐️⭐️",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),),
                      )
                    ],
                  )
              ),

            ]
        )
    );

    targets.add(
        TargetFocus(
            identify: "Target 3",
            keyTarget: _keyCommunicate,
            contents: [
              TargetContent(
                  align: ContentAlign.custom,
                  customPosition: CustomTargetContentPosition(top: 0, right: 0, left: 200),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nhà giao tiếp",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 36.0
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text("Tại ngôi nhà này, nhiệm vụ của bạn là: \n\n"
                            "•	Đọc câu tiếng việt được cung cấp.\n\n"
                            "•	Sắp xếp các mảnh từ bên dưới thành 1 câu tiếng anh đúng nghĩa và ngữ pháp.\n\n"
                            "Nếu trả lời đúng hết, bạn sẽ nhận được ngôi sao từ chú khỉ ⭐️⭐️⭐️",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),),
                      )
                    ],
                  )
              )
            ]
        )
    );

    targets.add(
        TargetFocus(
            identify: "Target 4",
            keyTarget: _keyConnect,
            contents: [
              TargetContent(
                customPosition: CustomTargetContentPosition(top: 50),
                  align: ContentAlign.custom,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nhà kết nối",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 36.0
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text("Tại ngôi nhà này, nhiệm vụ của bạn là: \n\n"
                            "•	Ghép nối các hình ảnh với từ vựng tiếng anh của nó.\n\n"
                            "Nếu trả lời đúng hết, bạn sẽ nhận được ngôi sao từ chú khỉ ⭐️⭐️⭐️",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),),
                      )
                    ],
                  )
              )
            ]
        )
    );
  }

  List<TargetFocus> targets = [];

  double getBottomHeight() {
    final RenderBox? renderBox = widget.bottomNavigationBarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.size.height;
    }
    return 0;
  }

  void showTutorial() async{
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_1.mp3'));
    }

    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      textSkip: "Bỏ qua",
      onClickTarget: (target){
        print(target);
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print("clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target){
        print(target);
      },
      onSkip: (){
        print("skip");
        return true;
      },
      onFinish: (){
        print("finish");
      },

    ).show(context:context);
  }
  
  void _goToMatchingScreen() async {
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_1.mp3'));
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(backgroundColor: const Color(0xFFd5c1a6), boxColor: Colors.yellowAccent, gameName: 'matching',),));
  }

  void _goToCommunicateScreen() async {
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_1.mp3'));
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(backgroundColor: const Color(0xFF80b2b3), boxColor: const Color(0xFFc56980), gameName: 'arrangeSentence',),));
  }

  void _goToWordScreen() async {
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_1.mp3'));
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(backgroundColor: const Color(0xFFc1a3ef), boxColor: const Color(0xFF90CE3E), gameName: 'wordInput',),));
  }

  void _goToMusicScreen() async {
    bool isMute = prefs.getBool('isMute') ?? false;
    if (!isMute) {
      await AudioPlayer().play(AssetSource('sound_effects/click_sound_1.mp3'));
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(backgroundColor: const Color(0xFF75cde8), boxColor: const Color(0xFFf5f05e), gameName: 'listen',),));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - getBottomHeight(),
              child: Image.asset('assets/images/bg.jpg', fit: BoxFit.fill,),
            ),
            // sun
            Positioned(
              right: 0,
              top: 0,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value, // Rotates the widget
                    child: child,
                  );
                },
                child: SizedBox(
                  height: 120,
                  child: Image.asset('assets/images/sun.png'),
                ), // Your image
              ),
            ),

            // nha am nhac
            Positioned(
              key: _keyMusic,
              left: 50,
              top: 25,
              child: AnimatedBuilder(
                animation: _musicAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _musicAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap:  _goToMusicScreen,
                        child: SizedBox(
                          height: 160,
                          child: Image.asset('assets/images/h1.png'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
                left: 10,
                top: 80,
                child: SizedBox(
                  height: 120,
                  child: Image.asset('assets/images/nhaamnhac.png'),
                ),),

            // nha tu vung
            Positioned(
              key: _keyWord,
              right: -40,
              top: 160,
              child: AnimatedBuilder(
                animation: _wordAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _wordAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap:  _goToWordScreen,
                        child: SizedBox(
                          height: 160,
                          child: Image.asset('assets/images/h2.png'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              right: 95,
              top: 185,
              child: SizedBox(
                height: 120,
                child: Image.asset('assets/images/nhatuvung.png'),
              ),
            ),

            // nha giao tiep
            Positioned(
              key: _keyCommunicate,
              left: 10,
              top: 280,
              child: AnimatedBuilder(
                animation: _musicAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _musicAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap:  _goToCommunicateScreen,
                        child: SizedBox(
                          height: 160,
                          child: Image.asset('assets/images/h3.png'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              left: 115,
              bottom: 380,
              child: SizedBox(
                height: 120,
                child: Image.asset('assets/images/nhagiaotiep.png'),
              ),
            ),

            // nha ket noi
            Positioned(
              key: _keyConnect,
              left: 60,
              bottom: 80,
              child: AnimatedBuilder(
                animation: _wordAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _wordAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap:  _goToMatchingScreen,
                        child: SizedBox(
                          height: 160,
                          child: Image.asset('assets/images/h4.png'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              right: 130,
              bottom: 60,
              child: SizedBox(
                height: 120,
                child: Image.asset('assets/images/nhaketnoi.png'),
              ),
            ),

            Positioned(
              right: 20,
              bottom: 290,
              child: AnimatedBuilder(
                animation: _musicAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _musicAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: showTutorial,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: SizedBox(
                          height: 180,
                          child: Image.asset('assets/images/monkey.png'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ],
    );
  }
}
