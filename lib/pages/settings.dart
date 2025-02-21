import 'package:bingo_indian_style/pages/login_page.dart';
import 'package:bingo_indian_style/services/auth_service.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(100, 100, 0, 0),
        child: GestureDetector(
          onTap: () async {
            await _auth.logoutWithGoogle(); // Wait for logout to complete
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false, // Remove all previous routes from stack
            );
          },
          child: const Text('LOGOUT'),
        ),
      ),
    );
  }
}
