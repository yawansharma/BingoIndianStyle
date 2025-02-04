// ignore_for_file: camel_case_types, avoid_print

import 'package:bingo_indian_style/pages/create_join.dart';
import 'package:bingo_indian_style/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:bingo_indian_style/pages/play_page.dart';

class BingoMainPage extends StatelessWidget {
  const BingoMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'INDIAN STYLE',
                    style: TextStyle(
                        fontFamily: 'Qahiri',
                        fontSize: 78,
                        color: Color.fromRGBO(255, 152, 129, 1)),
                  ),
                ),
                Text(
                  'BINGO',
                  style: TextStyle(
                    fontFamily: 'Rammetto',
                    fontSize: 56,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const CreateJoin();
                      }));
                    },
                    child: const Options(
                      icon: Icons.play_arrow,
                      label: 'Play',
                    )),
                GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Settings();
                      }));
                    },
                    child:
                        const Options(icon: Icons.settings, label: 'Settings')),
                GestureDetector(
                    onTap: () {
                      print('Home Rules Pressed');
                    },
                    child: const Options(
                      icon: Icons.menu_book_rounded,
                      label: 'Home Rules',
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Options extends StatefulWidget {
  final IconData icon;
  final String label;
  const Options({super.key, required this.icon, required this.label});

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(widget.icon),
          Text(widget.label,
              style: const TextStyle(fontSize: 30, fontFamily: 'PurplePurse'))
        ],
      ),
    );
  }
}
