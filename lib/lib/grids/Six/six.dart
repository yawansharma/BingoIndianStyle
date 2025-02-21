// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:bingo_indian_style/grids/Six/SixLogic.dart';
import 'package:bingo_indian_style/pages/play_page.dart';

class SixBySix extends StatefulWidget {
  const SixBySix({super.key});

  @override
  State<SixBySix> createState() => _SixBySixState();
}

class _SixBySixState extends State<SixBySix> {
  List<Color> iconColors = List.generate(36, (index) => Colors.blue);
  List<bool> isPressed = List.generate(36, (index) => false);
  Color buttonColor = const Color.fromRGBO(255, 152, 129, 1);
  Color TextColor = const Color.fromRGBO(0, 0, 0, 1);

  var logic = Sixlogic();
  final GlobalKey<SixlogicState> logicKey = GlobalKey<SixlogicState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Column(
            children: [
              Container(
                  width: 0,
                  height: 0,
                  child: Expanded(child: Sixlogic(key: logicKey))),
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
                                              return const SixBySix();
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
                        side: BorderSide(
                            color: buttonColor,
                            width: 5,
                            style: BorderStyle.solid)),
                    child: const Text('Bingo')),
              ),
              const Text('6x6',
                  style: TextStyle(fontFamily: 'MajorMono', fontSize: 24))
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 10, 0, 10),
            child: SizedBox(
              width: 300,
              height: 400,
              child: InkWell(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6),
                    itemCount: 36,
                    itemBuilder: (context, index) {
                      return Container(
                          margin: const EdgeInsets.all(5),
                          color: iconColors[index],
                          alignment: Alignment.center,
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  if (!isPressed[index]) {
                                    iconColors[index] = Colors.red;
                                    isPressed[index] = true;

                                    logicKey.currentState
                                        ?.buttonPress(isPressed);

                                    var completed =
                                        logicKey.currentState?.completedSets ??
                                            0;

                                    if (completed >= 6) {
                                      buttonColor = Colors.red;
                                    }
                                  }
                                });
                              },
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(fontSize: 13),
                              )));
                    }),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            height: 300,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Column(
                children: [
                  Text(
                    'B',
                    style: TextStyle(
                      fontSize: 20,
                      color: (logicKey.currentState?.completedSets ?? 0) >= 1
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'I',
                    style: TextStyle(
                      fontSize: 20,
                      color: (logicKey.currentState?.completedSets ?? 0) >= 2
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'N',
                    style: TextStyle(
                      fontSize: 20,
                      color: (logicKey.currentState?.completedSets ?? 0) >= 3
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'G',
                    style: TextStyle(
                      fontSize: 20,
                      color: (logicKey.currentState?.completedSets ?? 0) >= 4
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'O',
                    style: TextStyle(
                      fontSize: 20,
                      color: (logicKey.currentState?.completedSets ?? 0) >= 5
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '!!',
                    style: TextStyle(
                      fontSize: 20,
                      color: (logicKey.currentState?.completedSets ?? 0) >= 6
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 300, 0, 0),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.mic_outlined)),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mark_chat_unread_rounded)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
