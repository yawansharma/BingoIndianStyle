// ignore_for_file: avoid_print
import 'dart:math';
import 'package:bingo_indian_style/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:bingo_indian_style/grids/Five/FiveLogic.dart';
import 'package:bingo_indian_style/pages/play_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FiveByFive extends StatefulWidget {
  final roomId;
  const FiveByFive({Key? key, required this.roomId}) : super(key: key);

  @override
  State<FiveByFive> createState() => _FiveByFiveState();
}

class _FiveByFiveState extends State<FiveByFive> {
  List<int> shuffledNumbers = [];
  Map<String, bool> availableSquares = {};
  List<Color> iconColors = List.generate(25, (index) => Colors.blue);
  List<bool> isPressed = List.generate(25, (index) => false);
  Color buttonColor = const Color.fromRGBO(255, 152, 129, 1);
  Color TextColor = const Color.fromRGBO(0, 0, 0, 1);
  final game = GameService();

  var logic = FiveLogic();

  final GlobalKey<LogicState> logicKey = GlobalKey<LogicState>();

  @override
  void initState() {
    super.initState();
    shuffledNumbers = List.generate(25, (index) => index + 1)..shuffle();
    listenToGameUpdates();
  }

  void listenToGameUpdates() {
    FirebaseFirestore.instance
        .collection('gameRooms')
        .doc(widget.roomId.toString())
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          availableSquares =
              Map<String, bool>.from(snapshot.get('availableSquares') ?? {});

          // Convert Firestore's availableSquares map to match player's grid
          List<bool> isPressed = List.generate(25, (index) {
            int num =
                shuffledNumbers[index]; // Each player has a different shuffle
            return availableSquares[num.toString()] ?? false;
          });

          // Update logic for this player only
          logicKey.currentState?.buttonPress(isPressed);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                    height: 0,
                    width: 0,
                    child: Expanded(child: FiveLogic(key: logicKey))),
                SafeArea(
                  child: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () async {
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
                                                return FiveByFive(
                                                  roomId: widget.roomId,
                                                );
                                              }));
                                            },
                                            child: const Text('NO')),
                                        TextButton(
                                            onPressed: () {
                                              print(
                                                  'Navigate to Play page Start');
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              BingoPlayPage()),
                                                      (route) => route.isFirst);
                                              print(
                                                  'Navigate to Play page End');
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
                          elevation:
                              (logicKey.currentState?.completedSets ?? 0) >= 5
                                  ? 10
                                  : 0,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          side: BorderSide(
                              color:
                                  (logicKey.currentState?.completedSets ?? 0) >=
                                          5
                                      ? Colors.purple.shade800
                                      : Colors.black,
                              width: 5,
                              style: BorderStyle.solid)),
                      child: const Text('Bingo')),
                ),
                const Text('5x5',
                    style: TextStyle(fontFamily: 'MajorMono', fontSize: 24))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 10, 0, 10),
            child: SizedBox(
              width: 300,
              height: 350,
              child: InkWell(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    int number = shuffledNumbers[index];
                    bool isSelected =
                        availableSquares[number.toString()] ?? false;
                    return Container(
                      margin: const EdgeInsets.all(5),
                      color: isSelected
                          ? Colors.red
                          : Colors.blue, // Change based on Firestore
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () async {
                          if (!isSelected) {
                            game.updateAvailableSquares(widget.roomId, number);
                          }
                        },
                        child: Text('$number'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            height: 300,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 40, 0, 0),
              child: Column(
                children: [
                  Text(
                    'B',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                      fontWeight: FontWeight.bold,
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
                      fontWeight: FontWeight.bold,
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
                      fontWeight: FontWeight.bold,
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
                      fontWeight: FontWeight.bold,
                      color: (logicKey.currentState?.completedSets ?? 0) >= 5
                          ? Colors.green
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
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
