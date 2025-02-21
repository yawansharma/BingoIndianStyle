import 'package:bingo_indian_style/firebase_options.dart';
import 'package:bingo_indian_style/pages/create_join.dart';
import 'package:bingo_indian_style/pages/login_page.dart';
import 'package:bingo_indian_style/pages/main_page.dart';
import 'package:bingo_indian_style/pages/cover_page.dart';
import 'package:bingo_indian_style/pages/play_page.dart';
import 'package:bingo_indian_style/pages/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

class Bingo extends StatelessWidget {
  const Bingo({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/2',
      routes: {
        '/': (context) => const BingoMainPage(),
        '/first': (context) => const BingoCoverPage(),
        '/second': (context) => BingoPlayPage(),
        '/1': (context) => const SignupPage(),
        '/2': (context) => const LoginPage(),
        '/3': (context) => const CreateJoinPage(),
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.playIntegrity, // or AndroidProvider.debug
  //   appleProvider: AppleProvider.debug,
  // );

  runApp(const Bingo());
}
