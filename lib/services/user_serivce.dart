import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

final UserService userService = UserService();

class UserService {
  Future<UserCredential?> register(String email, String password, String name) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updatePhotoURL("https://firebasestorage.googleapis.com/v0/b/quizland-ba92d.firebasestorage.app/o/avatars%2Fdefault%20avatar.png?alt=media&token=96a8a7af-b4b3-4fbf-86aa-615ec12b2074");
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>> getUserById(String uid) async {
    final url = Uri.parse('https://us-central1-quizland-ba92d.cloudfunctions.net/getUserById?uid=$uid');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error: ${response.statusCode}');
        return {'error': 'Failed to fetch user'};
      }
    } catch (e) {
      print('Error: $e');
      return {'error': 'An unexpected error occurred'};
    }
  }

}

