class UserProfile {
  final String uid;
  final Map<String, List<GameHistory>> history;

  UserProfile({
    required this.uid,
    required this.history,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'history': history.map((key, value) => MapEntry(
        key,
        value.map((game) => game.toMap()).toList(),
      )),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      history: (map['history'] as Map<String, dynamic>).map((key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((game) => GameHistory.fromMap(game))
            .toList(),
      )),
    );
  }
}

class GameHistory {
  final int level;
  final int total;
  final int correct;
  final int incorrect;
  final int star;

  GameHistory({
    required this.level,
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.star,
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'total': total,
      'correct': correct,
      'incorrect': incorrect,
      'star': star,
    };
  }
  
  factory GameHistory.fromMap(Map<String, dynamic> map) {
    return GameHistory(
      level: map['level'],
      total: map['total'],
      correct: map['correct'],
      incorrect: map['incorrect'],
      star: map['star'],
    );
  }
}