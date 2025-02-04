// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:bingo_indian_style/pages/play_page.dart';

class EightByEight extends StatelessWidget {
  const EightByEight({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              SafeArea(
                child: SizedBox(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Do you want to leave the Game?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return const EightByEight();
                                            }));
                                          },
                                          child: const Text('NO')),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BingoPlayPage()),
                                                    (route) => route.isFirst);
                                          },
                                          child: const Text('YES'))
                                    ],
                                  );
                                });
                          },
                          icon: const Icon(Icons.arrow_back_ios_new)),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.dashboard_rounded)),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.photo_camera_outlined)),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.settings))
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'INDIAN STYLE',
                        style: TextStyle(
                            fontFamily: 'Qahiri',
                            fontSize: 45,
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
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 0, 10),
                child: ElevatedButton(
                    onPressed: () {
                      print('Bingo Pressed');
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        elevation: 10,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        side: const BorderSide(
                            color: Color.fromRGBO(255, 219, 187, 1),
                            width: 5,
                            style: BorderStyle.solid)),
                    child: const Text('Bingo')),
              ),
              const Text('8x8',
                  style: TextStyle(fontFamily: 'MajorMono', fontSize: 24))
            ],
          ),
          const Column(
            children: [],
          )
        ],
      ),
    );
  }
}
