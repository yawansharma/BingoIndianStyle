import 'package:bingo_indian_style/pages/main_page.dart';
import 'package:bingo_indian_style/pages/signup.dart';
import 'package:bingo_indian_style/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _SignupState();
}

class _SignupState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(100, 100, 0, 0),
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    await _auth.loginWithGoogle();
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return BingoMainPage();
                    }));
                  },
                  icon: const Icon(Icons.g_mobiledata_rounded))
            ],
          ),
        ],
      ),
    );
  }
}
