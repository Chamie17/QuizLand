import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

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
}

