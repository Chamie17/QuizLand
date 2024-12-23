import 'dart:convert';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../utils/matching_level.dart';

class DetailWordScreen extends StatefulWidget {
  DetailWordScreen({super.key, required this.word, required this.audioUrl});
  String word;
  String audioUrl;

  @override
  State<DetailWordScreen> createState() => _DetailWordScreenState();
}

class _DetailWordScreenState extends State<DetailWordScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late String pronunciation = "";
  late String meaning = "";
  late List<String> partsOfSpeech = [];
  late String? imagePath;
  bool isLoading = true;

  String? getImagePath(String imageName) {
    for (var entry in matchingLevel.entries) {
      for (var image in entry.value) {
        if (image.startsWith(imageName)) {
          return 'assets/matching_source/${entry.key}/$image';
        }
      }
    }
    return null;
  }

  Future<void> loadDetail() async {
    final response = await http.get(Uri.parse(
        'https://api.dictionaryapi.dev/api/v2/entries/en/${widget.word.toLowerCase()}'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data[0]['phonetics'] != null && data[0]['phonetics'] is List && data[0]['phonetics'].isNotEmpty) {
        var phonetics = data[0]['phonetics'] as List;
        pronunciation = phonetics[0]['text'] ?? '';

        if (pronunciation.isEmpty && phonetics.length > 2 && phonetics[2] is Map && phonetics[2].containsKey('text')) {
          pronunciation = phonetics[2]['text'] ?? '';
        }
      } else {
        pronunciation = 'No pronunciation available';
      }


      final temp = <String>{};
      for (var entry in data) {
        if (entry['meanings'] != null) {
          for (var meaning in entry['meanings']) {
            temp.add(meaning['partOfSpeech']);
          }
        }
      }
      partsOfSpeech = temp.toList();

      final byteData = await rootBundle.load("assets/${widget.audioUrl}");
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${widget.word}.mp3');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      final metadata = await readMetadata(tempFile, getImage: false);
      meaning = metadata.title!;

      imagePath = getImagePath(widget.word);
      if (imagePath == null) {
        var meanings = data[0]['meanings'];
        for (var meaning in meanings) {
          var synonyms = meaning['synonyms'];
          for (String synonym in synonyms) {
            imagePath = getImagePath(synonym);
            if (imagePath != null) break;
          }
        }

      }
    } else {
      throw Exception('Failed to load pronunciation');
    }
  }

  Future<void> init() async {
    await loadDetail();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void _handleAudio() async {
    await _audioPlayer.play(AssetSource(widget.audioUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Từ điển QuizLand"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(), // Show loading indicator
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(),
                Text(
                  widget.word,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: _handleAudio,
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.black,
                        )),
                    Text(
                      pronunciation,
                      style: const TextStyle(fontSize: 16),
                    )
                  ],
                ),
                Text(
                  "Từ loại: ${partsOfSpeech.join(", ")}",
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(),
                Text(
                  "Nghĩa: $meaning",
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Center(
                  child: SizedBox(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(imagePath!),
                      ),
                    ),
                  ),
                ),
                const Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
