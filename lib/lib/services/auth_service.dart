// auth_service.dart
// File: lib/services/auth_service.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Suggestion: Create a folder 'domain' and 'data'. Move this interface to 'domain/repositories/auth_repository.dart'
// and AuthService implementation to 'data/repositories/auth_repository_impl.dart'

// Interface for Authentication Service (Repository)
abstract class BaseAuthService {
  Future<UserCredential?> loginWithGoogle();
  Future<void> logoutWithGoogle();
  Future<User?> signUp(String email, String password);
  Future<User?> signIn(String email, String password);
  Future<void> signOut();
  // Suggestion: Add custom exception classes in a separate file (e.g., auth_exceptions.dart in 'domain/exceptions' folder)
  // For now, using generic Exception for simplicity in interface
}

class AuthService implements BaseAuthService {
  // Implements the interface
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Added for Firestore access - consider DI

  @override
  Future<UserCredential?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // User cancelled Google Sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      await _saveUserInfoToFirestore(
          userCredential.user); // Call Firestore saving method

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Suggestion: Create custom exception classes (e.g., GoogleSignInFailedException)
      print(
          "FirebaseAuthException during Google Sign-in: ${e.code}, ${e.message}"); // More informative logging
      _handleFirebaseAuthException(
          e.code); // Handle specific Firebase Auth exceptions
      rethrow; // Re-throw to allow UI layer to handle or display error
    } catch (e) {
      // Suggestion: Create custom exception classes (e.g., GoogleSignInGeneralException)
      print(
          "General Exception during Google Sign-in: $e"); // General error logging
      throw Exception(
          'Google Sign-in failed: ${e.toString()}'); // Throw generic exception for other errors
    }
  }

  // Separate method for saving user info to Firestore - SRP principle
  Future<void> _saveUserInfoToFirestore(User? user) async {
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName ??
              user.email?.split('@')[0] ??
              'Unknown User', // Provide default username
          'email': user.email ?? '', // Provide default if null
          'profilePic': user.photoURL ?? '', // Provide default if null
        }, SetOptions(merge: true));
      } catch (e) {
        print(
            "Error saving user info to Firestore: $e"); // Log Firestore saving errors
        // Decide if you want to throw or just log this. For critical user data, consider throwing and handling.
        // For non-critical, logging might be sufficient and allow login to succeed even if Firestore save fails.
      }
    }
  }

  @override
  Future<void> logoutWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
      await _auth
          .signOut(); // Also sign out from Firebase Auth for complete logout
    } catch (e) {
      print("Error during Google Sign-out: $e"); // Log sign-out errors
      throw Exception(
          'Logout failed: ${e.toString()}'); // Throw generic exception for sign-out errors
    }
  }

  @override
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential creds = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return creds.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException during Sign-up: ${e.code}, ${e.message}");
      _handleFirebaseAuthException(
          e.code); // Handle specific Firebase Auth exceptions
      rethrow;
    } catch (e) {
      print("General Exception during Sign-up: $e");
      throw Exception('Sign-up failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential creds = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return creds.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException during Sign-in: ${e.code}, ${e.message}");
      _handleFirebaseAuthException(
          e.code); // Handle specific Firebase Auth exceptions
      rethrow;
    } catch (e) {
      print("General Exception during Email Sign-in: $e");
      throw Exception('Sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error during Sign-out: $e");
      throw Exception('Sign-out failed: ${e.toString()}');
    }
  }

  // Private method to handle FirebaseAuthExceptions - SRP, keeps methods cleaner
  void _handleFirebaseAuthException(String code) {
    switch (code) {
      case "invalid-credential":
        throw Exception(
            'Invalid credentials. Please check your email and password.'); // More user-friendly message
      case "user-not-found":
        throw Exception('User not found. Please check your email or sign up.');
      case "wrong-password":
        throw Exception('Incorrect password. Please try again.');
      case "email-already-in-use":
        throw Exception(
            'An account with this email already exists. Try logging in.');
      case "invalid-email":
        throw Exception('Invalid email format. Please enter a valid email.');
      case "weak-password":
        throw Exception('Weak password. Please use a stronger password.');
      case "operation-not-allowed":
        throw Exception(
            'Email/password accounts are not enabled.'); // Indicate if email/pass sign-in is disabled
      default:
        throw Exception(
            'Authentication failed. Please try again.'); // Generic error for unhandled codes
    }
  }
}
