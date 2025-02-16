import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential?> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      //Save user info in Firestore
      User? user = userCredential.user;
      if (user != null) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': user.displayName,
          'email': user.email,
          'profilePic': user.photoURL
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> logoutWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      print(e);
    }
  }

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
