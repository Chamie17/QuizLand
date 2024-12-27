import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    _musicController.dispose();
    _wordController.dispose();

    super.dispose();
  }


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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nhà âm nhạc",
                        style: GoogleFonts.lalezar(
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
                          style: GoogleFonts.lalezar(
                            fontSize: 24,
                              color: Colors.white,
                            // fontStyle: FontStyle.italic,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nhà từ vựng",
                        style: GoogleFonts.lalezar(
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
                          style: GoogleFonts.lalezar(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nhà giao tiếp",
                        style: GoogleFonts.lalezar(
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
                          style: GoogleFonts.lalezar(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Nhà kết nối",
                        style: GoogleFonts.lalezar(
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
                          style: GoogleFonts.lalezar(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double scaleHeight(double inputHeight) => inputHeight * screenHeight / 2856;
    double scaleWidth(double inputWidth) => inputWidth * screenWidth / 1280;

    return Stack(
      children: [
        SizedBox(
          width: screenWidth,
          height: screenHeight - getBottomHeight(),
          child: Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.fill,
          ),
        ),

        // Sun
        Positioned(
          right: 0,
          top: 0,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value,
                child: child,
              );
            },
            child: SizedBox(
              height: scaleHeight(360),
              child: Image.asset('assets/images/sun.png'),
            ),
          ),
        ),

        // Music House
        Positioned(
          key: _keyMusic,
          left: scaleWidth(180),
          top: scaleHeight(25),
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
                    onTap: _goToMusicScreen,
                    child: SizedBox(
                      height: scaleHeight(500),
                      child: Image.asset('assets/images/h1.png'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Positioned(
          left: scaleWidth(70),
          top: scaleHeight(200),
          child: SizedBox(
            height: scaleHeight(390),
            child: Image.asset('assets/images/nhaamnhac.png'),
          ),
        ),

        // Vocabulary House
        Positioned(
          key: _keyWord,
          right: scaleWidth(-100),
          top: scaleHeight(440),
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
                    onTap: _goToWordScreen,
                    child: SizedBox(
                      height: scaleHeight(500),
                      child: Image.asset('assets/images/h2.png'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Positioned(
          right: scaleWidth(300),
          top: scaleHeight(540),
          child: SizedBox(
            height: scaleHeight(360),
            child: Image.asset('assets/images/nhatuvung.png'),
          ),
        ),

        // Communication House
        Positioned(
          key: _keyCommunicate,
          left: scaleWidth(50),
          top: scaleHeight(850),
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
                    onTap: _goToCommunicateScreen,
                    child: SizedBox(
                      height: scaleHeight(500),
                      child: Image.asset('assets/images/h3.png'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Positioned(
          left: scaleWidth(380),
          bottom: scaleHeight(1200),
          child: SizedBox(
            height: scaleHeight(360),
            child: Image.asset('assets/images/nhagiaotiep.png'),
          ),
        ),

        // Connection House
        Positioned(
          key: _keyConnect,
          left: scaleWidth(230),
          bottom: scaleHeight(200),
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
                    onTap: _goToMatchingScreen,
                    child: SizedBox(
                      height: scaleHeight(500),
                      child: Image.asset('assets/images/h4.png'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Positioned(
          right: scaleWidth(320),
          bottom: scaleHeight(140),
          child: SizedBox(
            height: scaleHeight(360),
            child: Image.asset('assets/images/nhaketnoi.png'),
          ),
        ),

        // Monkey
        Positioned(
          right: scaleWidth(100),
          bottom: scaleHeight(800),
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
                      height: scaleHeight(550),
                      child: Image.asset('assets/images/monkey.png'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
