import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/services/audio_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final AudioManager _audioManager = AudioManager(); // Instance of AudioManager
  TextEditingController _nameController = TextEditingController();
  List<String> avatarImageNames = [
    'boy1.png',
    'boy2.png',
    'boy3.png',
    'girl1.png',
    'girl2.png',
    'girl3.png',
    'default avatar.png',
  ];
  late Future<List<String>> _avatarImageUrls;
  late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Fetch the current user
    _avatarImageUrls = _loadAvatarImages();
  }

  // Dispose controller to avoid memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<List<String>> _loadAvatarImages() async {
    List<String> urls = [];
    try {
      for (String avatarName in avatarImageNames) {
        String url = await FirebaseStorage.instance
            .ref('avatars/$avatarName')
            .getDownloadURL();
        urls.add(url);
      }
    } catch (e) {
      print("Error loading avatar images: $e");
    }
    return urls;
  }

  // Handle name update
  _handleChangeName() async {
    _nameController.text = _currentUser?.displayName ?? '';
    final text = await showTextInputDialog(
      context: context,
      textFields: [
        DialogTextField(
          hintText: 'Họ và tên',
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return "Vui lòng nhập họ và tên";
            }
            return null;
          },
          initialText: _nameController.text,
          keyboardType: TextInputType.text,
        ),
      ],
      title: 'Cập nhật họ và tên',
    );

    if (text != null && text.first != _nameController.text) {
      await _currentUser?.updateDisplayName(text.first);
      setState(() {}); // Refresh the UI
    }
  }

  // Handle avatar change
  _handleChangeAvatar() async {
    final avatarImageUrls = await _avatarImageUrls;

    if (avatarImageUrls.isEmpty) {
      print('chưa load');
      return;
    }

    final selectedAvatar = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn ảnh đại diện'),
          content: SingleChildScrollView(
            child: Column(
              children: avatarImageUrls.map((avatarUrl) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(avatarUrl);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 300,
                      height: 300,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedAvatar != null) {
      await _currentUser!.updatePhotoURL(selectedAvatar);
      setState(() {}); // Refresh the UI
    }
  }

  void _handleAbout() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
                height: 150,
                width: double.maxFinite,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.transparent,
                            child: _currentUser?.photoURL == null
                                ? Icon(Icons.account_circle,
                                size: 50, color: Colors.grey[600])
                                : null,
                          ),
                          _currentUser?.photoURL != null
                              ? Positioned.fill(
                            child: GestureDetector(
                              onTap: _handleChangeAvatar,
                              child: CachedNetworkImage(
                                imageUrl: _currentUser!.photoURL!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          )
                              : Container(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _handleChangeAvatar,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blue,
                                child: Icon(
                                  Icons.edit,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Chào bé ${_currentUser?.displayName ?? ''}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 4,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: _handleChangeName,
                              icon: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                  width: double.maxFinite,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.maxFinite, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onPressed: () async {
                            await _audioManager.toggleMute();
                            setState(() {}); // Refresh UI
                          },
                          child: Row(
                            children: [
                              Icon(_audioManager.isMute
                                  ? Icons.volume_off
                                  : Icons.volume_up),
                              SizedBox(width: 10),
                              Text("Âm thanh"),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.maxFinite, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onPressed: () async {
                            await _audioManager.toggleMusic();
                            setState(() {}); // Refresh UI
                          },
                          child: Row(
                            children: [
                              Icon(_audioManager.isMusicPlaying
                                  ? Icons.music_note
                                  : Icons.music_off),
                              SizedBox(width: 10),
                              Text("Nhạc nền"),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.maxFinite, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onPressed: _handleAbout,
                          child: Row(
                            children: [
                              Icon(Icons.help),
                              SizedBox(width: 10),
                              Text("About"),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.maxFinite, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onPressed: () async {
                            await _audioManager.stopMusic();
                            FirebaseAuth.instance.signOut();
                          },
                          child: Text("Đăng xuất"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
