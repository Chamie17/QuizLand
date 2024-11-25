import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizland_app/services/question_service.dart';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  Widget _buildQuestion(String question, String url) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: Image.network(
          url,
          width: 100,
          height: 100,
        ),
        onTap: () {
          setState(() {

          });
        },
      ),
    );
  }

  Widget _buildAnswer(String answer, int index) {
    return Material(
      color: Colors.transparent,
      elevation: 5,
      child: InkWell(
        child: Container(
          height: 100,
          width: 150,
          color: Colors.pink,
          child: Center(
              child: Text(
            answer,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          )),
        ),
        onTap: () {
          setState(() {
            currentAnswer = answer;
            if (currentQuestion == currentAnswer) {
              result[index] = true;
              _checkFinish();
            }
          });
        },
      ),
    );
  }

  String? currentQuestion;
  String? currentAnswer;

  late List<Map<String, String>> images;

  void init() async {
    images = await questionService.getImages('me_and_my_friends');
    images = images.sublist(0, 4);
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  List<bool> result = [false, false, false, false];

  void _checkFinish() {
    if (!result.contains(false)) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Text("Chuc mung da chien thang"),
        ),
      );
    }
  }

  Future<List<Widget>> questionColumn() async {
    return images.map((image) => _buildQuestion(image['name']!, image['url']!)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Ghép cặp từ vựng"),
      ),
      body: Stack(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Opacity(opacity: 0.7,
          child: Image.asset("assets/images/bg_matching_game.png", fit: BoxFit.fill,)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<List<Widget>>(
                  future: questionColumn(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No questions available');
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: snapshot.data!,
                      );
                    }
                  },
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

              ],
            ),
          ],
        ),
      ]),
    );
  }
}
