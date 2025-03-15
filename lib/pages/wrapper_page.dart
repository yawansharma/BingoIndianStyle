import 'package:bingo_indian_style/pages/login_page.dart';
import 'package:bingo_indian_style/pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  late StreamSubscription<User?> _authStateSubscription;
  bool _isLoading = true; // Add a loading indicator
  String? _error; // Add an error message

  @override
  void initState() {
    super.initState();
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _isLoading = false; // Stop loading after authentication check
        if (user == null) {
          _error = null; // Clear any previous error
        } else {
          // Add any additional actions after successful login here, if needed.
        }
      });
    }, onError: (error) {
      setState(() {
        _isLoading = false;
        _error = 'Authentication error: $error';
      });
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    return user == null ? const LoginPage() : const BingoMainPage();
  }
}
