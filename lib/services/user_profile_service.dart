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
          // Sort the game history by level in ascending order
          List<GameHistory> sortedHistory = userProfile.history[gameName]!;
          sortedHistory.sort((a, b) => a.level.compareTo(b.level)); // Ascending order by level
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


}
