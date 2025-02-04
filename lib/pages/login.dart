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
              Padding(
                padding: const EdgeInsets.fromLTRB(90, 10, 0, 0),
                child: Row(
                  children: [
                    const Text('No Account?'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: GestureDetector(
                        child: const Text('SignUp!'),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return SignupPage();
                          }));
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(150, 0, 0, 0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: SizedBox(
                    child: TextField(
                      controller: _email,
                      decoration: const InputDecoration(label: Text('Email')),
                    ),
                    width: 400,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
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
                      _auth.signIn(_email.text, _password.text);
                    },
                    child: const Text(
                      'Login',
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
