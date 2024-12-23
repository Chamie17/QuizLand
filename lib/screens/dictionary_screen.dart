import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:quizland_app/screens/arrange_sentence_game_screen.dart';
import 'package:quizland_app/screens/detail_word_screen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  late List<String> words = [];
  late Map<String, String> audioUrl = {};

  void init() async {
    final String jsonString =
        await rootBundle.loadString('assets/audio_source/audio_files.json');
    final Map<String, dynamic> audioMap = jsonDecode(jsonString);
    for (var entry in audioMap.entries) {
      for (var word in entry.value) {
        audioUrl[word] = 'audio_source/${entry.key}/$word';
      }
    }
    setState(() {
      words = audioUrl.keys.map((file) {
        return file.split('.').first;
      }).toList();
      words.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void detailWord(String word, String audioUrl) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailWordScreen(word: word, audioUrl: audioUrl),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Từ điển QuizLand"),
        centerTitle: true,
        backgroundColor: Colors.purple.shade200,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchAnchor.bar(
                viewBackgroundColor: Colors.blue.shade100,
                isFullScreen: true,
                suggestionsBuilder: (context, controller) {
                  final String input = controller.value.text;
                  return words
                      .where((word) => word.contains(input))
                      .map((item) => ListTile(
                            title: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            onTap: () {
                              controller.closeView(item);
                              final String audioPath = audioUrl['$item.mp3']!;
                              detailWord(item, audioPath);
                            },
                          ));
                },
                barLeading: const Icon(Icons.search),
                barHintText: "Nhập từ vựng muốn tra cứu",
              ),

              // Show all words
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blue.shade300),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            words[index],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          onTap: () {
                            final String audioPath = audioUrl['${words[index]}.mp3']!;
                            detailWord(words[index], audioPath);
                          },
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: words.length,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
