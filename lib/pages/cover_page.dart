import 'package:bingo_indian_style/pages/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:blinking_text/blinking_text.dart';

class BingoCoverPage extends StatelessWidget {
  const BingoCoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const Wrapper();
          }));
        },
        child: const SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'INDIAN STYLE',
                      style: TextStyle(
                          fontFamily: 'Qahiri',
                          fontSize: 100,
                          color: Color.fromRGBO(255, 152, 129, 1)),
                    ),
                  ),
                  SizedBox(
                    height: 00,
                  ),
                  Text(
                    'BINGO',
                    style: TextStyle(
                      fontFamily: 'Rammetto',
                      fontSize: 70,
                    ),
                  ),
                ],
              ),
              BlinkText('Tap anywhere on screen to continue',
                  style: TextStyle(color: Color.fromRGBO(128, 128, 128, 0.5)))
            ],
          ),
        ),
      ),
    );
  }
}
