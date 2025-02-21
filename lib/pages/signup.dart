import 'package:bingo_indian_style/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(100, 100, 0, 0),
                child: Text(
                  'SIGNUP',
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(150, 0, 0, 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: SizedBox(
                    child: TextField(
                      controller: _email,
                      decoration: const InputDecoration(label: Text('Email')),
                    ),
                    width: 400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: SizedBox(
                    child: TextField(
                      obscureText: true,
                      controller: _password,
                      decoration:
                          const InputDecoration(label: Text('Password')),
                    ),
                    width: 400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: TextButton(
                    onPressed: () {
                      _auth.signUp(_email.text, _password.text);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Signup!',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                            Color.fromRGBO(114, 2, 156, 1))),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
