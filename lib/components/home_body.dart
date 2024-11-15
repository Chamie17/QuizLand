import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late Animation<double> _animation1;
  late AnimationController _controller2;
  late Animation<double> _animation2;
  late AnimationController _controller3;
  late Animation<double> _animation3;
  late AnimationController _controller4;
  late Animation<double> _animation4;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation 1: Slow and Wide Shake
    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation1 = Tween<double>(begin: -5.0, end: 5.0).animate(_controller1);

    // Animation 2: Quick and Tight Shake
    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )..repeat(reverse: true);
    _animation2 = Tween<double>(begin: -1.0, end: 1.0).animate(_controller2);

    // Animation 3: Vertical Shake
    _controller3 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation3 = Tween<double>(begin: -5.0, end: 5.0).animate(_controller3);

    // Animation 4: Randomized Shake
    final Random _random = Random();
    _controller4 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation4 = Tween<double>(
      begin: -(_random.nextDouble() * 10.0),
      end: _random.nextDouble() * 10.0,
    ).animate(_controller4);

    // sun
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // Duration for a full roll
    )..repeat(); // Repeats indefinitely

    _animation = Tween<double>(begin: 0, end: 2 * 3.14159) // 0 to 360 degrees
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // SizedBox(
        //   width: MediaQuery.of(context).size.width,
        //   height: MediaQuery.of(context).size.height,
        //   child: Lottie.asset('assets/lottiefiles/bg_animation.json'),
        // ),
        Positioned(
          bottom: 0,
          child: SizedBox(
            height: 120,
            width: MediaQuery.of(context).size.width,
            child: Image.asset('assets/images/grass_row.png', fit: BoxFit.fill,),
          ),
        ),
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
              height: 160,
              child: Image.asset('assets/images/sun.png'),
            ), // Your image
          ),
        ),

        Positioned(
          left: MediaQuery.of(context).size.width / 4,
          top: 40,
          child: AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation1.value, 0), // Shakes horizontally
                child: child,
              );
            },
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/h1.png'),
            ), // Your image
          ),
        ),
        Positioned(
            left: MediaQuery.of(context).size.width / 15,
            top: 110,
            child: AnimatedBuilder(
              animation: _animation1,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_animation1.value, 0), // Shakes horizontally
                  child: child,
                );
              },
              child: SizedBox(
                height: 180,
                child: Image.asset('assets/images/nhaamnhac.png'),
              ), // Your image
            ),),
        Positioned(
          right: 30,
          top: 200,
          child: AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation2.value, 0), // Shakes horizontally
                child: child,
              );
            },
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/h2.png'),
            ), // Your image
          ),
        ),
        Positioned(
          right: 0,
          top: 150,
          child: AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation2.value, 0), // Shakes horizontally
                child: child,
              );
            },
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/nhatuvung.png'),
            ), // Your image
          ),
        ),
        Positioned(
          left: 20,
          top: 300,
          child: AnimatedBuilder(
            animation: _animation3,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation3.value, 0), // Shakes horizontally
                child: child,
              );
            },
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/h3.png'),
            ), // Your image
          ),
        ),
        Positioned(
          left: 110,
          bottom: 200,
          child: AnimatedBuilder(
            animation: _animation3,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation3.value, 0), // Shakes horizontally
                child: child,
              );
            },
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/nhaketnoi.png'),
            ), // Your image
          ),
        ),
        Positioned(
          right: 40,
          bottom: 100,
          child: AnimatedBuilder(
            animation: _animation4,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation4.value, 0), // Shakes horizontally
                child: child,
              );
            },
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/h4.png'),
            ), // Your image
          ),
        ),
        Positioned(
          right: 100,
          bottom: 30,
          child: AnimatedBuilder(
            animation: _animation4,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation4.value, 0), // Shakes horizontally
                child: child,
              );
            },
            child: SizedBox(
              height: 160,
              child: Image.asset('assets/images/nhagiaotiep.png'),
            ), // Your image
          ),
        ),

      ],
    );
  }
}
