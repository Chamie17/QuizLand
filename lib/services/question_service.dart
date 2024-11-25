import 'package:firebase_storage/firebase_storage.dart';

final QuestionService questionService = QuestionService();

class QuestionService {
  Future<List<Map<String, String>>> getImages(String folderPath) async {
    List<Map<String, String>> images = [];

    try {
      final storageRef = FirebaseStorage.instance.ref(folderPath);
      final listResult = await storageRef.listAll();

      for (var item in listResult.items) {
        final url = await item.getDownloadURL();
        images.add({'name': item.name, 'url': url});
      }
    } catch (e) {
      print("Error occurred while fetching image URLs: $e");
    }

    return images;
  }
}