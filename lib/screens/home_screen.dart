import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/components/home_body.dart';
import 'package:quizland_app/screens/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  Widget _handleScreen() {
    if (_currentIndex == 0) {
      return HomeBody();
    } else if (_currentIndex == 3) {
      return SettingScreen();
    }
    return HomeBody();
  }

  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    player.setReleaseMode(ReleaseMode.loop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setSource(AssetSource('musics/bg_music.mp3'));
      await player.resume();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      player.pause();
    } else if (state == AppLifecycleState.resumed) {
      player.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _handleScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: SizedBox(
                height: 24,
                child: Image.asset("assets/images/home_icon.png"),
              ),

              label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: SizedBox(
                height: 24,
                child: Image.asset("assets/images/ranking_icon.png"),
              ), label: "BXH"),
          BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 24,
                    child: Image.asset("assets/images/book_icon.png"),
                  ), label: "Từ điển"),
          BottomNavigationBarItem(
              icon: SizedBox(
                height: 24,
                child: Image.asset("assets/images/setting.png"),
              ), label: "Tuỳ chỉnh"),
        ],
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          player.stop();
          FirebaseAuth.instance.signOut();
        },
        child: Text("Logout"),
      ),
    );
  }
}
