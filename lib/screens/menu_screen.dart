import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quizland_app/screens/matching_game_screen.dart';

class MenuScreen extends StatefulWidget {
  MenuScreen({super.key, required this.backgroundColor, required this.boxColor});
  Color backgroundColor;
  Color boxColor;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration: Duration(seconds: 8), // Animation duration
      vsync: this,
    );

    // Define the animation from screen width to -100 (off-screen)
    _animation = Tween<double>(
      begin: 400,
      end: -100, // Moving off-screen to the left
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                  icon: Image.asset('assets/images/arrow_back.png', height: 60,) )),
          Positioned(
              right: 0,
              child: Lottie.asset('assets/lottiefiles/monkey_top.json',
                  height: 220)),
          Positioned(
              left: 70,
              top: 60,
              child: Text(
                "Units",
                style: TextStyle(fontSize: 100, fontFamily: 'Kablammo'),
              )),
          Positioned(
              left: -50,
              right: -50,
              bottom: -10,
              child: Lottie.asset('assets/lottiefiles/grass_animation.json')),
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
          Positioned(
            left: 15,
            top: 220,
            child: SizedBox(
              width: 380,
              height: 800,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      print(index);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchingGameScreen(),
                          ));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.boxColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 36,
                            fontFamily: 'Kablammo'),
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
