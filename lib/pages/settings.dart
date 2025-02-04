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
          onTap: () {
            _auth.signout();
            Navigator.pop(context);
          },
          child: const Text('LOGOUT'),
        ),
      ),
    );
  }
}
