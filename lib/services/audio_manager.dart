import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _singleton = AudioManager._internal();

  factory AudioManager() => _singleton;

  AudioManager._internal();

  AudioPlayer? _audioPlayer;
  bool isMute = false;
  bool isMusicPlaying = false;

  // Initialize audio state from SharedPreferences
  Future<void> init() async {
    try {
      _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isMute = prefs.getBool('isMute') ?? false;
      isMusicPlaying = prefs.getBool('isMusicPlaying') ?? true;

      await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
      if (isMusicPlaying) {
        await playMusic();
      }
    } catch (e) {
      print("Error initializing AudioManager: $e");
    }
  }

  // Play music if the player is initialized
  Future<void> playMusic() async {
    try {
      if (_audioPlayer != null && !isMute) {
        await _audioPlayer!.play(AssetSource('musics/bg_music.mp3'));
        isMusicPlaying = true;
      }
    } catch (e) {
      print("Error playing music: $e");
    }
  }

  // Stop music if the player is initialized
  Future<void> stopMusic() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        isMusicPlaying = false;
      }
    } catch (e) {
      print("Error stopping music: $e");
    }
  }

  // Toggle mute state and save it
  Future<void> toggleMute() async {
    try {
      isMute = !isMute;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isMute', isMute);
    } catch (e) {
      print("Error toggling mute state: $e");
    }
  }

  // Toggle music playing state and save it
  Future<void> toggleMusic() async {
    try {
      isMusicPlaying = !isMusicPlaying;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isMusicPlaying', isMusicPlaying);

      if (isMusicPlaying) {
        await playMusic();
      } else {
        await stopMusic();
      }
    } catch (e) {
      print("Error toggling music state: $e");
    }
  }

  // Dispose the audio player if it's no longer needed
  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null; // Set the player to null after disposing
  }
}
