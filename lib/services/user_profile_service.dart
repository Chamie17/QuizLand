import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

final UserProfileService userProfileService = UserProfileService();

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveResult(UserProfile userProfile) async {
    try {
      DocumentReference userRef = _firestore.collection('userProfile').doc(userProfile.uid);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        UserProfile currentUserProfile = UserProfile.fromMap(userData);
        if (currentUserProfile.history.containsKey(userProfile.history.keys.first)) {
          List<GameHistory> gameHistory = currentUserProfile.history[userProfile.history.keys.first]!;
          GameHistory? existingGameHistory;
          for (var game in gameHistory) {
            if (game.level == userProfile.history.values.first.first.level) {
              existingGameHistory = game;
              break;
            }
          }
          if (existingGameHistory != null) {
            int newStar = userProfile.history.values.first.first.star;
            int newTotal = userProfile.history.values.first.first.total;
            if (existingGameHistory.star < newStar ||
                (existingGameHistory.star == newStar && existingGameHistory.total < newTotal)) {
              gameHistory[gameHistory.indexOf(existingGameHistory)] = userProfile.history.values.first.first;
            }
          } else {
            gameHistory.add(userProfile.history.values.first.first);
          }
          await userRef.update({
            'history': currentUserProfile.history.map((key, value) => MapEntry(
              key,
              value.map((game) => game.toMap()).toList(),
            )),
          });
        } else {
          currentUserProfile.history[userProfile.history.keys.first] = userProfile.history.values.first;
          await userRef.update({
            'history': currentUserProfile.history.map((key, value) => MapEntry(
              key,
              value.map((game) => game.toMap()).toList(),
            )),
          });
        }
      } else {
        await userRef.set(userProfile.toMap());
      }
    } catch (e) {
      print('Error saving result: $e');
    }
  }

  Future<List<GameHistory>> getLevelsHistory(String gameName, String uid) async {
    try {
      DocumentReference userRef = _firestore.collection('userProfile').doc(uid);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        UserProfile userProfile = UserProfile.fromMap(userData);

        if (userProfile.history.containsKey(gameName)) {
          List<GameHistory> sortedHistory = userProfile.history[gameName]!;
          sortedHistory.sort((a, b) => a.level.compareTo(b.level));
          return sortedHistory;
        } else {
          print('No history found for the game: $gameName');
          return [];
        }
      } else {
        print('User profile not found for UID: $uid');
        return [];
      }
    } catch (e) {
      print('Error retrieving levels history: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTop3UsersByStarAndTotalScore() async {
    try {
      QuerySnapshot userSnapshot = await _firestore.collection('userProfile').get();

      List<Map<String, dynamic>> usersData = [];

      for (var doc in userSnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        UserProfile userProfile = UserProfile.fromMap(userData);

        int totalStars = 0;
        int totalScore = 0;

        userProfile.history.forEach((gameName, gameHistoryList) {
          for (var game in gameHistoryList) {
            totalStars += game.star;
            totalScore += game.total;
          }
        });

        usersData.add({
          'uid': userProfile.uid,
          'star': totalStars,
          'totalscore': totalScore,
        });
      }

      usersData.sort((a, b) {
        if (b['star'] == a['star']) {
          return b['totalscore'].compareTo(a['totalscore']);
        } else {
          return b['star'].compareTo(a['star']);
        }
      });

      return usersData.take(3).toList();

    } catch (e) {
      print('Error retrieving top 3 users: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersByStarAndTotalScore() async {
    try {
      QuerySnapshot userSnapshot = await _firestore.collection('userProfile').get();

      List<Map<String, dynamic>> usersData = [];

      for (var doc in userSnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        UserProfile userProfile = UserProfile.fromMap(userData);

        int totalStars = 0;
        int totalScore = 0;

        userProfile.history.forEach((gameName, gameHistoryList) {
          for (var game in gameHistoryList) {
            totalStars += game.star;
            totalScore += game.total;
          }
        });

        usersData.add({
          'uid': userProfile.uid,
          'star': totalStars,
          'totalscore': totalScore,
        });
      }

      usersData.sort((a, b) {
        if (b['star'] == a['star']) {
          return b['totalscore'].compareTo(a['totalscore']);
        } else {
          return b['star'].compareTo(a['star']);
        }
      });

      return usersData;

    } catch (e) {
      print('Error retrieving users: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersByGameName(String gameName) async {
    try {
      QuerySnapshot userSnapshot = await _firestore.collection('userProfile').get();

      List<Map<String, dynamic>> usersData = [];

      for (var doc in userSnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        UserProfile userProfile = UserProfile.fromMap(userData);

        int totalStars = 0;
        int totalScore = 0;

        if (userProfile.history.containsKey(gameName)) {
          var gameHistoryList = userProfile.history[gameName];

          if (gameHistoryList != null) {
            for (var game in gameHistoryList) {
              totalStars += game.star;
              totalScore += game.total;
            }

            usersData.add({
              'uid': userProfile.uid,
              'gameName': gameName,
              'star': totalStars,
              'totalscore': totalScore,
            });
          }
        }
      }

      usersData.sort((a, b) {
        if (b['star'] == a['star']) {
          return b['totalscore'].compareTo(a['totalscore']);
        } else {
          return b['star'].compareTo(a['star']);
        }
      });

      return usersData;

    } catch (e) {
      print('Error retrieving users by gameName: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserDataByGameNameAndUid(String gameName, String uid) async {
    try {
      QuerySnapshot userSnapshot = await _firestore.collection('userProfile').get();

      List<Map<String, dynamic>> usersData = [];

      for (var doc in userSnapshot.docs) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        UserProfile userProfile = UserProfile.fromMap(userData);

        if (userProfile.uid == uid) {
          int totalStars = 0;
          int totalScore = 0;

          // Check if the user has history for the specific gameName
          if (userProfile.history.containsKey(gameName)) {
            var gameHistoryList = userProfile.history[gameName];

            if (gameHistoryList != null) {  // Ensure gameHistoryList is not null
              for (var game in gameHistoryList) {
                totalStars += game.star;
                totalScore += game.total;
              }

              usersData.add({
                'uid': userProfile.uid,
                'gameName': gameName,
                'star': totalStars,
                'totalscore': totalScore,
              });

            }
          } else if (['arrangeSentence', 'listen', 'matching', 'wordInput'].contains(gameName)) {
            usersData.add({
              'uid': userProfile.uid,
              'gameName': gameName,
              'star': 0,
              'totalscore': 0,

            });
          } else {
            int gameTotalStars = 0;
            int gameTotalScore = 0;
            // If gameName does not exist, get all game names and calculate totals
            userProfile.history.forEach((game, gameHistoryList) {
              if (gameHistoryList != null) {  // Ensure gameHistoryList is not null
                for (var gameHistory in gameHistoryList) {
                  gameTotalStars += gameHistory.star;
                  gameTotalScore += gameHistory.total;
                }
              }
            });

            usersData.add({
              'uid': userProfile.uid,
              'gameName': 'quizland',
              'star': gameTotalStars,
              'totalscore': gameTotalScore,
            });

          }

          break;
        }
      }

      return usersData.first;

    } catch (e) {
      print('Error retrieving user data by gameName and uid: $e');
      return {};
    }
  }

}
