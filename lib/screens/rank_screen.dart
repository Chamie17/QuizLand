import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Top 4 những người tôi luôn tin tưởng"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text("Top 1: Trịnh Trần Phương Tuấn"),
            subtitle: Text("Tổng điểm: ${NumberFormat('#,###').format(5000000)}đ", style: TextStyle(fontSize: 16),),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text("Top 2: Meo Meo"),
            subtitle: Text("Tổng điểm: ${NumberFormat('#,###').format(3000000)}đ", style: TextStyle(fontSize: 16),),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text("Top 3: Jack"),
            subtitle: Text("Tổng điểm: ${NumberFormat('#,###').format(1000000)}đ", style: TextStyle(fontSize: 16),),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text("Top 4: J97"),
            subtitle: Text("Tổng điểm: ${NumberFormat('#,###').format(500000)}đ", style: TextStyle(fontSize: 16),),
          )
        ],
      ),
    );
  }
}
