import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

final UserProfileService userProfileService = UserProfileService();

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveResult(UserProfile userProfile) async {
    try {
      DocumentReference userRef = _firestore.collection('userProfile').doc(userProfile.uid);

      // Get the current user profile from Firestore
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        // User exists, fetch the current game history
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        UserProfile currentUserProfile = UserProfile.fromMap(userData);

        // Check if the game exists for the given game name
        if (currentUserProfile.history.containsKey(userProfile.history.keys.first)) {
          List<GameHistory> gameHistory = currentUserProfile.history[userProfile.history.keys.first]!;

          // Find the existing game history for the specific level
          GameHistory? existingGameHistory;
          for (var game in gameHistory) {
            if (game.level == userProfile.history.values.first.first.level) {
              existingGameHistory = game;
              break;
            }
          }

          // If game history exists for that level, compare the new result with the old one
          if (existingGameHistory != null) {
            int newStar = userProfile.history.values.first.first.star;
            int newTotal = userProfile.history.values.first.first.total;

            // Update if the new result is better (higher star or total score)
            if (existingGameHistory.star < newStar ||
                (existingGameHistory.star == newStar && existingGameHistory.total < newTotal)) {
              // Update the existing game history entry
              gameHistory[gameHistory.indexOf(existingGameHistory)] = userProfile.history.values.first.first;
            }
          } else {
            // If no existing history for that level, add the new game history
            gameHistory.add(userProfile.history.values.first.first);
          }

          // Update the user's history in Firestore
          await userRef.update({
            'history': currentUserProfile.history.map((key, value) => MapEntry(
              key,
              value.map((game) => game.toMap()).toList(),
            )),
          });
        } else {
          // If the game doesn't exist in history, add the new game history for that game
          currentUserProfile.history[userProfile.history.keys.first] = userProfile.history.values.first;
          await userRef.update({
            'history': currentUserProfile.history.map((key, value) => MapEntry(
              key,
              value.map((game) => game.toMap()).toList(),
            )),
          });
        }
      } else {
        // If the user doesn't exist, create a new user profile
        await userRef.set(userProfile.toMap());
      }
    } catch (e) {
      print('Error saving result: $e');
    }
  }
}
