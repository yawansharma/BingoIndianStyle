import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signUp(String email, String password) async {
    try {
      final creds = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return creds.user;
    } catch (e) {
      log('SOMETHING WENT WRONG: $e');
    }
    return null;
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final creds = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return creds.user;
    } on FirebaseAuthException catch (e) {
      ExceptionHandle(e.code);
    }
    return null;
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('SOMETHING WRONG HAPPENED');
    }
  }

  void ExceptionHandle(String code) {
    switch (code) {
      case "invalid-credential":
        log('email/password is wrong');
      case "email-already-in-use":
        log('An Account with this email already exists');
    }
  }
}
