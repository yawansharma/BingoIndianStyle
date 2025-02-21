// Refactored bingo_play_page.dart

// File: lib/pages/bingo_play_page.dart

// ignore_for_file: avoid_print

import 'package:bingo_indian_style/pages/create_join.dart';
import 'package:bingo_indian_style/services/game_service.dart'; // Using GameService abstraction
import 'package:flutter/material.dart';
import 'package:bingo_indian_style/grids/Five/FIveByFive.dart';

// Suggestion: Move these grid pages to a 'features' folder or similar if you have more features
// import 'package:bingo_indian_style/grids/Six/six.dart';
// import 'package:bingo_indian_style/grids/Seven/seven.dart';
// import 'package:bingo_indian_style/grids/Eight/eight.dart';

class BingoPlayPage extends StatefulWidget {
  BingoPlayPage({super.key});

  @override
  State<BingoPlayPage> createState() => _BingoPlayPageState();
}

class _BingoPlayPageState extends State<BingoPlayPage> {
  final GameRepository _gameService =
      GameService(); // Using the GameRepository interface

  String _roomId = ''; // Store roomId as state variable
  double _noOfPlayers = 1.0;

  @override
  void initState() {
    super.initState();
    _generateRoomId(); // Generate roomId when page initializes
  }

  void _generateRoomId() {
    _roomId = _gameService.roomNum(); // Generate room ID using GameService
  }

  void _navigateToGameRoom(int gridSize) {
    _gameService.createRoom(_roomId, gridSize, _noOfPlayers.toInt()).then((_) {
      // Use _roomId here
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return FiveByFive(
          // Assuming 5x5 is the primary game for now - adjust as needed
          roomId: _roomId, // Pass the generated _roomId
        );
      }));
    }).catchError((error) {
      // Handle room creation error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create room: $error')),
      );
      print("Error creating room and navigating: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(
              MaterialPageRoute(builder: (context) => const CreateJoinPage()),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded),
              Text(
                'Create Room',
                style: TextStyle(fontFamily: 'PurplePurse', fontSize: 40),
              )
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(55, 10, 0, 20),
                child: SizedBox(
                  width: 800,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 81,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _navigateToGameRoom(
                              5), // Call navigation with gridSize
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(255, 152, 120, 1),
                            foregroundColor: Colors.white,
                            elevation: 15,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          child: const Text('5x5'),
                        ),
                      ),
                      SizedBox(
                        width: 81,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _navigateToGameRoom(
                              6), // Call navigation with gridSize
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(255, 152, 120, 1),
                            foregroundColor: Colors.white,
                            elevation: 15,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          child: const Text('6x6'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: SizedBox(
              width: 800,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 81,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _navigateToGameRoom(
                          7), // Call navigation with gridSize
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 152, 120, 1),
                        foregroundColor: Colors.white,
                        elevation: 15,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text('7x7'),
                    ),
                  ),
                  SizedBox(
                    width: 81,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _navigateToGameRoom(
                          8), // Call navigation with gridSize
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 152, 120, 1),
                        foregroundColor: Colors.white,
                        elevation: 15,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text('8x8'),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Text('Number of Players?'),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15),
              activeTickMarkColor: Colors.red,
              inactiveTickMarkColor: Colors.blue,
              overlayColor: Colors.green,
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            ),
            child: SizedBox(
              width: 500,
              child: Slider(
                value: _noOfPlayers,
                max: 7,
                min: 1,
                onChanged: (players) {
                  setState(() {
                    _noOfPlayers = players;
                  });
                  print(_noOfPlayers);
                },
                divisions: 6,
                label: _noOfPlayers.toStringAsFixed(0),
              ),
            ),
          )
        ],
      ),
    );
  }
}
