import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/components/home_body.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _handleScreen() {
    if (_currentIndex == 0) {
      return HomeBody();
    }
    return HomeBody();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              print("ok ok ok");
            },
            child: CircleAvatar(
              child: CachedNetworkImage(
                imageUrl: FirebaseAuth.instance.currentUser!.photoURL!,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: imageProvider),
                  ),
                ),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Xin chào ${FirebaseAuth.instance.currentUser!.displayName}"),
            Row(
              children: [
                SizedBox(
                  height: 30,
                  child: Image.asset('assets/images/coin.png'),
                ),
                Text(
                  "400",
                  style: TextStyle(fontSize: 24),
                ),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.settings,
                size: 54,
              ))
        ],
      ),
      body: _handleScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: SizedBox(
                height: 40,
                child: Image.asset("assets/images/home_icon.png"),
              ),

              label: "Trang chủ"),
          BottomNavigationBarItem(
              icon: SizedBox(
                height: 40,
                child: Image.asset("assets/images/ranking_icon.png"),
              ), label: "BXH"),
          BottomNavigationBarItem(
                  icon: SizedBox(
                    height: 40,
                    child: Image.asset("assets/images/book_icon.png"),
                  ), label: "Từ điển"),
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
          FirebaseAuth.instance.signOut();
        },
        child: Text("Logout"),
      ),
    );
  }
}
