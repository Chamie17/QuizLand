import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/services/user_serivce.dart';
import 'package:shimmer/shimmer.dart';
import '../services/user_profile_service.dart';

class DetailRankScreen extends StatefulWidget {
  DetailRankScreen({super.key, required this.gameName});
  String gameName;

  @override
  State<DetailRankScreen> createState() => _DetailRankScreenState();
}

class _DetailRankScreenState extends State<DetailRankScreen> {
  List<Map<String, dynamic>> topUsers = [];

  Map<String, dynamic> me = {};
  Map<String, dynamic> meStarNScore = {};

  bool isLoading = true;

  String _getTitle() {
    switch (widget.gameName) {
      case 'matching':
        return "Bảng thành tích nhà kết nối";
      case 'listen':
        return "Bảng thành tích nhà âm thanh";
      case 'wordInput':
        return "Bảng thành tích nhà từ vựng";
      case 'arrangeSentence':
        return "Bảng thành tích nhà giao tiếp";
      default:
        return "Bảng thành tích QuizLand";
    }
  }

  int _getPosition() {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    int index = topUsers.indexWhere((user) => user['uid'] == currentUserUid);
    return index == -1 ? 0 : index + 1 ;
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {


    switch (widget.gameName) {
      case 'matching':
        topUsers = await userProfileService.getAllUsersByGameName('matching');
        break;
      case 'listen':
        topUsers = await userProfileService.getAllUsersByGameName('listen');
        break;
      case 'wordInput':
        topUsers = await userProfileService.getAllUsersByGameName('wordInput');
        break;
      case 'arrangeSentence':
        topUsers = await userProfileService.getAllUsersByGameName('arrangeSentence');
        break;
      default:
        topUsers = await userProfileService.getAllUsersByStarAndTotalScore();
        break;
    }

    List<Map<String, dynamic>> users = [];
    for (var user in topUsers) {
      users.add(await userService.getUserById(user['uid']));
    }

    return users;
  }

  void init() async {
    me = await userService.getUserById(FirebaseAuth.instance.currentUser!.uid);
    meStarNScore = await userProfileService.getUserDataByGameNameAndUid(widget.gameName, FirebaseAuth.instance.currentUser!.uid);
    setState(() {
isLoading = false;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: fetchUsers(),  // Pass the fetchUsers Future
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: ListView.builder(
                        itemCount: 3,
                        itemBuilder: (context, index) => ListTile(
                          title: Container(
                            height: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<Map<String, dynamic>> users = snapshot.data!;
                    return ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        var user = users[index];
                        return ListTile(
                            leading: Text('${index + 1}'),
                          title: Row(
                            children: [
                              CircleAvatar(
                                child: CachedNetworkImage(
                                  imageUrl: user['imageUrl'],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                                ),
                              ),
                              SizedBox(width: 32),
                              Text("${user['name']}\n${topUsers[index]['totalscore']}đ"),
                            ],
                          ),
                          trailing: Text("${topUsers[index]['star']} ⭐"),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            isLoading ? Shimmer.fromColors(
              baseColor: Colors.pink,
              highlightColor: Colors.purple,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.pink.shade300, // Background color
                  border: Border.all(
                    color: Colors.blue, // Border color
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
                ),
              ),
            ) :
            Container(
              decoration: BoxDecoration(
                color: Colors.pink.shade300, // Background color
                border: Border.all(
                  color: Colors.blue, // Border color
                  width: 2, // Border width
                ),
                borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
              ),
              child: ListTile(
                style: ListTileStyle.list,
                leading: Text("${_getPosition()}/${topUsers.length}"),
                title: Row(
                  children: [
                    CircleAvatar(
                      child: CachedNetworkImage(
                        imageUrl: me['imageUrl'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                    ),
                    Text("${me['name']}\n"
                        "${meStarNScore['totalscore']}đ"),
                  ],
                ),
                trailing: Text("${meStarNScore['star']} ⭐"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
