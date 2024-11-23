import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:quizland_app/screens/matching_game_screen.dart';
import 'package:quizland_app/screens/menu_screen.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

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

  @override
  void initState() {
    init();
    super.initState();

    // sun
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
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

  @override
  void dispose() {
    super.dispose();
  }

  void init() async {
    targets.add(
        TargetFocus(
            identify: "Target 1",
            keyTarget: _keyMusic,
            contents: [
              TargetContent(
                  align: ContentAlign.bottom,
                  child: Container(
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Nha am nhac",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("huong dan cua nha am nhac",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ],
                    ),
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
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Nha tu vung",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("huong dan cua nha tu vung",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ],
                    ),
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
                  align: ContentAlign.right,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Nha giao tiep",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("huong dan cua nha giao tiep",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ],
                    ),
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
                  align: ContentAlign.right,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Nha ket noi",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("huong dan cua nha ket noi",
                            style: TextStyle(
                                color: Colors.white
                            ),),
                        )
                      ],
                    ),
                  )
              )
            ]
        )
    );
  }

  List<TargetFocus> targets = [];

  void showTutorial() {
    TutorialCoachMark(
      targets: targets, // List<TargetFocus>
      colorShadow: Colors.black, // DEFAULT Colors.black
      // alignSkip: Alignment.bottomRight,
      // textSkip: "SKIP",
      // paddingFocus: 10,
      // opacityShadow: 0.8,
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

    )..show(context:context);
  }
  
  void _goToMatchingScreen() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(backgroundColor: Color(0xFFd5c1a6), boxColor: Colors.yellowAccent,),));
  }

  void _goToCommuniateScreen() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(backgroundColor: Color(0xFF80b2b3), boxColor: Color(0xFFc56980),),));
  }

  void _goToWordScreen() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(backgroundColor: Color(0xFFc1a3ef), boxColor: Color(0xFFefa13e),),));
  }

  void _goToMusicScreen() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(backgroundColor: Color(0xFF75cde8), boxColor: Color(0xFFf5f05e),),));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 77,
              child: Image.asset('assets/images/bg.jpg', fit: BoxFit.cover,),
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
                        onTap:  _goToCommuniateScreen,
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
              right: -20,
              bottom: 220,
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
                          height: 250,
                          child: Image.asset('assets/images/monkey.png'),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              right: 20,
              bottom: 360,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: showTutorial,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: SizedBox(
                    height: 120,
                      child: Image.asset('assets/images/guide_bubble.png')),
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }
}
