import 'package:bingo_indian_style/pages/login.dart';
import 'package:bingo_indian_style/pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('SOmething Went Wrong'),
              );
            } else {
              if (snapshot.data == null) {
                return const LoginPage();
              } else {
                return const BingoMainPage();
              }
            }
          }),
    );
  }
}
