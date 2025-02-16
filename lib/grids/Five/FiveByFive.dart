// ignore_for_file: avoid_print
import 'dart:math';
import 'package:bingo_indian_style/services/game_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool isMyTurn = false;
  bool gamePaused = true;
  String currentPlayerName = "Waiting...";
  bool bingoTimerStarted = false;
  DateTime? bingoStartTime;
  bool hasPressedBingo = false;
  int globalBingoStartTime = 0;
  Map<String, int> bingoReactionTimes = {};

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

          int currentTurn = snapshot.get('currentTurn') ?? 0;
          List<String> players =
              List<String>.from(snapshot.get('players') ?? []);
          List<String> spectators =
              List<String>.from(snapshot.get('spectators') ?? []);
          gamePaused = snapshot.get('gamePaused') ?? true;
          bool gameStarted = snapshot.get('gameStarted') ?? false;

          globalBingoStartTime = snapshot.data() != null &&
                  snapshot.data()!.containsKey('bingoStartTime')
              ? snapshot.get('bingoStartTime')
              : 0;

          bingoReactionTimes =
              Map<String, int>.from(snapshot.get('bingoReactionTimes') ?? {});
          String myUID = FirebaseAuth.instance.currentUser!.uid;

          // Exclude spectators from turn logic
          List<String> activePlayers =
              players.where((p) => !spectators.contains(p)).toList();

          isMyTurn = activePlayers.contains(myUID) &&
              (activePlayers.indexOf(myUID) == currentTurn) &&
              !gamePaused;

          if (activePlayers.isNotEmpty && currentTurn < activePlayers.length) {
            String currentTurnUID = activePlayers[currentTurn];

            if (currentTurnUID == myUID) {
              setState(() {
                currentPlayerName = "You";
              });
            } else {
              fetchPlayerName(currentTurnUID);
            }
          } else {
            setState(() {
              currentPlayerName = "Waiting...";
            });
          }

          updateBingoState();

          // Show Start Game Pop-up only for the host
          String hostUID = players.isNotEmpty ? players[0] : "";
          if (!gameStarted && myUID == hostUID) {
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted && ModalRoute.of(context)?.isCurrent == true) {
                showStartGameDialog();
              }
            });
          }
        });
      }
    });
  }

  void updateBingoState() {
    List<bool> isPressed = List.generate(25, (index) {
      int num = shuffledNumbers[index];
      return availableSquares[num.toString()] ?? false;
    });

    logicKey.currentState?.buttonPress(isPressed); // Update the BINGO logic
  }

  void fetchPlayerName(String playerUID) async {
    if (playerUID.isEmpty) {
      setState(() {
        currentPlayerName = "Waiting...";
      });
      return;
    }

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(playerUID)
          .get();

      print("Fetching name for UID: $playerUID");

      if (userSnapshot.exists && userSnapshot.data() != null) {
        String newName = userSnapshot['username'] ?? "Unknown Player";
        print("Fetched Name: $newName");

        if (currentPlayerName != newName) {
          setState(() {
            currentPlayerName = newName;
          });
        }
      } else {
        print("No username found for UID: $playerUID");
        setState(() {
          currentPlayerName = "Unknown Player";
        });
      }
    } catch (e) {
      print("Error fetching player name: $e");
      setState(() {
        currentPlayerName = "Unknown Player";
      });
    }
  }

  void showStartGameDialog() {
    if (ModalRoute.of(context)?.isCurrent != true)
      return; // Prevent multiple dialogs

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Start Game?"),
          content: const Text(
              "Not all players have joined. Do you want to start now?"),
          actions: [
            // TextButton(
            //   onPressed: () {
            //     Navigator.pop(context); // Close dialog, keep waiting
            //   },
            //   child: const Text("Wait"),
            // ),
            TextButton(
              onPressed: () {
                game.startGame(widget.roomId); // Start the game
                Navigator.pop(context);
              },
              child: const Text("Start Now"),
            ),
          ],
        );
      },
    );
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
                    width: 250,
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
                            onPressed: () {}, icon: const Icon(Icons.settings)),
                        Text('${widget.roomId}'),
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
                      onPressed:
                          (logicKey.currentState?.completedSets ?? 0) >= 5 &&
                                  !hasPressedBingo
                              ? () {
                                  String userId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  game.recordBingoPress(widget.roomId, userId);

                                  setState(() {
                                    hasPressedBingo = true;
                                  });

                                  print("User $userId pressed BINGO.");
                                }
                              : null,
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
                Text(
                  isMyTurn
                      ? "It's Your Turn, $currentPlayerName!"
                      : "Waiting for $currentPlayerName...",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple),
                ),
                const SizedBox(height: 10),
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
                        onPressed: isMyTurn && !gamePaused && !isSelected
                            ? () async {
                                game.updateAvailableSquares(
                                    widget.roomId, number);

                                // Update pressed states locally
                                setState(() {
                                  availableSquares[number.toString()] = true;
                                });

                                //Convert Firestore's availableSquares map to a boolean list
                                List<bool> isPressed =
                                    List.generate(25, (index) {
                                  int num = shuffledNumbers[index];
                                  return availableSquares[num.toString()] ??
                                      false;
                                });

                                logicKey.currentState?.buttonPress(isPressed);

                                game.endTurn(widget
                                    .roomId); // Move to next player's turn
                              }
                            : null,
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
