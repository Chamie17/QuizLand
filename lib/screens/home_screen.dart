import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/components/home_body.dart';
import 'package:quizland_app/screens/dictionary_screen.dart';
import 'package:quizland_app/screens/rank_screen.dart';
import 'package:quizland_app/screens/setting_screen.dart';
import '../services/audio_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final AudioManager _audioManager = AudioManager();
  bool isMusicPlaying = true;
  bool isMute = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAudioManager();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initAudioManager() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isMusicPlaying = prefs.getBool('isMusicPlaying') ?? true;
      isMute = prefs.getBool('isMute') ?? false;
    });

    if (isMusicPlaying) {
      await _audioManager.playMusic();
    } else {
      await _audioManager.stopMusic();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _audioManager.stopMusic();
    } else if (state == AppLifecycleState.resumed) {
      if (isMusicPlaying) {
        _audioManager.playMusic();
      }
    }
  }

  Widget _getSelectedScreen() {
    switch (_currentIndex) {
      case 0:
        return const HomeBody();
      case 1:
        return const RankScreen();
      case 2:
        return const DictionaryScreen();
      case 3:
        return const SettingScreen();
      default:
        return const HomeBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 24,
              child: Image.asset("assets/images/home_icon.png"),
            ),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 24,
              child: Image.asset("assets/images/ranking_icon.png"),
            ),
            label: "BXH",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 24,
              child: Image.asset("assets/images/book_icon.png"),
            ),
            label: "Từ điển",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 24,
              child: Image.asset("assets/images/setting.png"),
            ),
            label: "Tuỳ chỉnh",
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) async {
          bool isMute = prefs.getBool('isMute') ?? false;
          if (!isMute) {
            await AudioPlayer().play(AssetSource('sound_effects/click_sound_1.mp3'), volume: 100);
          }
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
