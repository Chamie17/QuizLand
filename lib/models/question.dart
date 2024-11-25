class Question {
  String? id;
  String type;
  List<String> questions;
  List<String> answers;

  Question({
    required this.id,
    required this.type,
    required this.questions,
    required this.answers,
  });

  factory Question.fromSentence(String id, String sentence) {
    return Question(
      id: id,
      type: 'sentence',
      questions: [sentence],
      answers: sentence.split(" "),
    );
  }

  factory Question.fromImages(String id, List<String> imageLinks, List<String> answers) {
    if (imageLinks.length != 4 || answers.length != 4) {
      throw ArgumentError("There must be exactly 4 images and 4 answers.");
    }
    return Question(
      id: id,
      type: 'image',
      questions: imageLinks,
      answers: answers,
    );
  }

  factory Question.fromAudio(String id, List<String> audioLinks, List<String> answers) {
    if (audioLinks.length != 4 || answers.length != 4) {
      throw ArgumentError("There must be exactly 4 audio files and 4 answers.");
    }
    return Question(
      id: id,
      type: 'audio',
      questions: audioLinks,
      answers: answers,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String?,
      type: json['type'] as String,
      questions: List<String>.from(json['questions'] as List<dynamic>),
      answers: List<String>.from(json['answers'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'questions': questions,
      'answers': answers,
    };
  }

}
