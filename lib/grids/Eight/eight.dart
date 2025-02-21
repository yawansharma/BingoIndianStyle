// eightbyseven.dart
// eight_by_seven_page.dart  (Corrected filename for clarity - although it's actually 8x8 as per request)
// File: lib/pages/eightbyseven.dart

// ignore_for_file: avoid_print

import 'package:bingo_indian_style/grids/Eight/EightLogic.dart';
import 'package:bingo_indian_style/services/game_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Using EightLogic for 8x8 grid
import 'package:bingo_indian_style/pages/play_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- BingoGrid Widget (Reused with adjustments for 8x8) ---
class BingoGrid extends StatelessWidget {
  final List<int> shuffledNumbers;
  final Map<String, bool> availableSquares;
  final bool isMyTurn;
  final bool gamePaused;
  final bool isSpectator;
  final Function(int) onSquareTap;

  const BingoGrid({
    Key? key,
    required this.shuffledNumbers,
    required this.availableSquares,
    required this.isMyTurn,
    required this.gamePaused,
    required this.onSquareTap,
    this.isSpectator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340, // Increased width for 8x8 grid to fit better
      height: 450, // Increased height for 8x8 grid to fit better
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8), // Correct 8x8 grid
        itemCount: 64, // Correct item count for 8x8 grid
        itemBuilder: (context, index) {
          int number = shuffledNumbers[index];
          bool isSelected = availableSquares[number.toString()] ?? false;
          return InkWell(
            onTap: (isMyTurn && !gamePaused && !isSelected && !isSpectator)
                ? () => onSquareTap(number)
                : null,
            child: Container(
              margin: const EdgeInsets.all(1), //  margin for  squares
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(
                    3), // Optional: Slightly rounded corners for squares
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10), // Adjusted font size for smaller squares
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- EightBySeven Widget (Corrected Class Name to EightByEight for 8x8 Grid) ---
class EightByEight extends StatefulWidget {
  // Class name as requested by filename
  final String roomId;
  const EightByEight({Key? key, required this.roomId}) : super(key: key);

  @override
  State<EightByEight> createState() =>
      _EightBySevenState(); // Corrected State name
}

class _EightBySevenState extends State<EightByEight> {
  // Corrected State Class name
  List<int> shuffledNumbers = [];
  Map<String, bool> availableSquares = {};
  String currentPlayerName = "Waiting...";
  bool isMyTurn = false;
  bool gamePaused = true;
  bool hasPressedBingo = false;
  bool isSpectator = false;

  final GameService _gameService = GameService();
  final GlobalKey<EightLogicState>
      _logicKey = // Changed Logic Key to EightLogicState
      GlobalKey<EightLogicState>();

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _listenToGameUpdates();
  }

  Future<void> _initializeGame() async {
    shuffledNumbers =
        List.generate(64, (index) => index + 1) // 64 numbers for 8x8
          ..shuffle();
  }

  void _listenToGameUpdates() {
    FirebaseFirestore.instance
        .collection('gameRooms')
        .doc(widget.roomId.toString())
        .snapshots()
        .listen(_processGameSnapshot, onError: _handleGameUpdateError);
  }

  void _processGameSnapshot(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      print("Game room not found: ${widget.roomId}");
      return;
    }

    final gameData = snapshot.data() as Map<String, dynamic>?;
    if (gameData == null) return;

    print(
        "Game Data Update (8x8): gamePaused = ${gameData['gamePaused']}, currentTurn = ${gameData['currentTurn']}, players = ${gameData['players']}, spectators = ${gameData['spectators']}"); // ADDED LOGGING

    _updateGameStateFromSnapshot(gameData);
    _updateCurrentPlayerName(gameData);
    _updateBingoState();
    _checkAndShowStartGameDialog(gameData);
    _checkAndShowLeaderboard(gameData);
  }

  void _handleGameUpdateError(error) {
    print("Error listening to game updates: $error");
  }

  void _updateGameStateFromSnapshot(Map<String, dynamic> gameData) {
    setState(() {
      availableSquares =
          Map<String, bool>.from(gameData['availableSquares'] ?? {});
      gamePaused = gameData['gamePaused'] ?? true;
      isSpectator = _determineIsSpectator(gameData);
      isMyTurn = _determineIsMyTurn(gameData);
    });
  }

  bool _determineIsSpectator(Map<String, dynamic> gameData) {
    List<String> spectators = List<String>.from(gameData['spectators'] ?? []);
    String myUID = FirebaseAuth.instance.currentUser!.uid;
    return spectators.contains(myUID);
  }

  bool _determineIsMyTurn(Map<String, dynamic> gameData) {
    if (isSpectator) return false;

    int currentTurn = gameData['currentTurn'] ?? 0;
    List<String> players = List<String>.from(gameData['players'] ?? []);
    List<String> spectators = List<String>.from(gameData['spectators'] ?? []);
    String myUID = FirebaseAuth.instance.currentUser!.uid;

    List<String> activePlayers =
        players.where((p) => !spectators.contains(p)).toList();
    return activePlayers.contains(myUID) &&
        (activePlayers.indexOf(myUID) == currentTurn) &&
        !gamePaused;
  }

  void _updateCurrentPlayerName(Map<String, dynamic> gameData) {
    int currentTurn = gameData['currentTurn'] ?? 0;
    List<String> players = List<String>.from(gameData['players'] ?? []);
    List<String> activePlayers = players
        .where(
            (p) => !List<String>.from(gameData['spectators'] ?? []).contains(p))
        .toList();

    if (activePlayers.isNotEmpty && currentTurn < activePlayers.length) {
      String currentTurnUID = activePlayers[currentTurn];
      if (currentTurnUID == FirebaseAuth.instance.currentUser!.uid) {
        _setPlayerNameToUI("You");
      } else {
        _fetchPlayerName(currentTurnUID);
      }
    } else {
      _setPlayerNameToUI("Waiting...");
    }
  }

  void _setPlayerNameToUI(String name) {
    if (currentPlayerName != name) {
      setState(() {
        currentPlayerName = name;
      });
    }
  }

  void _updateBingoState() {
    List<bool> pressedStates = List.generate(64, (index) {
      // Updated to 64 for 8x8
      int num = shuffledNumbers[index];
      return availableSquares[num.toString()] ?? false;
    });
    _logicKey.currentState?.buttonPress(pressedStates);
  }

  Future<void> _fetchPlayerName(String playerUID) async {
    if (playerUID.isEmpty) {
      _setPlayerNameToUI("Waiting...");
      return;
    }
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(playerUID)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        String newName = userSnapshot['username'] ?? "Unknown Player";
        _setPlayerNameToUI(newName);
      } else {
        _setPlayerNameToUI("Unknown Player");
      }
    } catch (e) {
      print("Error fetching player name: $e");
      _setPlayerNameToUI("Unknown Player");
    }
  }

  void _checkAndShowStartGameDialog(Map<String, dynamic> gameData) {
    bool gameStarted = gameData['gameStarted'] ?? false;
    List<String> players = List<String>.from(gameData['players'] ?? []);
    String hostUID = players.isNotEmpty ? players[0] : "";
    String myUID = FirebaseAuth.instance.currentUser!.uid;

    if (!gameStarted && myUID == hostUID) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          _showStartGameDialog();
        }
      });
    }
  }

  void _checkAndShowLeaderboard(Map<String, dynamic> gameData) {
    Map<String, int> reactionTimes =
        Map<String, int>.from(gameData['bingoReactionTimes'] ?? {});
    List<String> players = List<String>.from(gameData['players'] ?? []);
    List<String> spectators = List<String>.from(gameData['spectators'] ?? []);
    List<String> activePlayers = players
        .where(
            (p) => !List<String>.from(gameData['spectators'] ?? []).contains(p))
        .toList();

    if ((gameData['showLeaderboard'] ?? false) &&
        players.isEmpty &&
        spectators.isNotEmpty) {
      _showLeaderboardDialog(reactionTimes);
    }
  }

  void _showStartGameDialog() {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Start Game?"),
        content: const Text(
            "Not all players have joined. Do you want to start now?"),
        actions: [
          TextButton(
            onPressed: () {
              _gameService.startGame(widget.roomId);
              Navigator.pop(context);
            },
            child: const Text("Start Now"),
          ),
        ],
      ),
    );
  }

  Future<void> _showLeaderboardDialog(
      Map<String, int> bingoReactionTimes) async {
    if (!mounted) return;

    List<MapEntry<String, int>> sortedEntries = bingoReactionTimes.entries
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    List<Map<String, String>> leaderboard = [];
    for (var entry in sortedEntries) {
      String playerUID = entry.key;
      int reactionTime = entry.value;
      String playerName = await _getPlayerNameFromUID(playerUID);
      leaderboard.add({'name': playerName, 'time': '${reactionTime / 1000}s'});
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("🏆 Leaderboard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: leaderboard
              .map((entry) => Text("${entry['name']} - ${entry['time']}"))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _gameService.deleteRoom(widget.roomId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<String> _getPlayerNameFromUID(String playerUID) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(playerUID)
          .get();
      return userSnapshot.exists
          ? (userSnapshot['username'] ?? "Unknown Player")
          : "Unknown Player";
    } catch (e) {
      print("Error fetching player name for leaderboard: $e");
      return "Unknown Player";
    }
  }

  void _handleGridSquareTap(int number) async {
    if (!isMyTurn || gamePaused || isSpectator) return;

    await _gameService.updateAvailableSquares(widget.roomId, number);
    setState(() {
      availableSquares[number.toString()] = true;
    });
    _updateBingoState();
    await _gameService.endTurn(widget.roomId);
  }

  void _handleBingoButtonPress() {
    if ((_logicKey.currentState?.completedSets ?? 0) >=
            7 && // Bingo condition for 8x8 (keeping at 7 for now, can adjust)
        !hasPressedBingo &&
        !isSpectator) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      _gameService.recordBingoPress(widget.roomId, userId);
      setState(() {
        hasPressedBingo = true;
        isSpectator = true;
      });
      print("User $userId pressed BINGO and became a spectator.");
    }
  }

  Future<void> _leaveGameRoom() async {
    // ... (No changes in this method) ...
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
                    child: Expanded(
                        child: EightLogic(
                            // Using EightLogic Widget
                            key: _logicKey))),
                SafeArea(
                  child: SizedBox(
                    width: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: _leaveGameRoom,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.dashboard_rounded),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.photo_camera_outlined),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.settings),
                        ),
                        Text('${widget.roomId}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                      SizedBox(height: 0),
                      Text(
                        'BINGO', // Updated to BINGOOS!!
                        style: TextStyle(
                          fontFamily: 'Rammetto',
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 0, 10),
                  child: ElevatedButton(
                      onPressed: _handleBingoButtonPress,
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          elevation:
                              (_logicKey.currentState?.completedSets ?? 0) >= 7
                                  ? 10
                                  : 0,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          side: BorderSide(
                              color: (_logicKey.currentState?.completedSets ??
                                          0) >=
                                      7
                                  ? Colors.purple.shade800
                                  : Colors.black,
                              width: 5,
                              style: BorderStyle.solid)),
                      child: const Text('Bingo')),
                ),
                Text(
                  isMyTurn
                      ? "It's Your Turn, $currentPlayerName!"
                      : isSpectator
                          ? "$currentPlayerName is a Spectator"
                          : "Waiting for $currentPlayerName...",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSpectator ? Colors.grey : Colors.purple),
                ),
                const SizedBox(height: 10),
                const Text('8x8', // Updated to 8x8 Grid Size Text
                    style: TextStyle(fontFamily: 'MajorMono', fontSize: 24))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(70, 5, 0, 10),
            child: BingoGrid(
              // BingoGrid Widget Here
              shuffledNumbers: shuffledNumbers,
              availableSquares: availableSquares,
              isMyTurn: isMyTurn,
              gamePaused: gamePaused,
              isSpectator: isSpectator,
              onSquareTap: _handleGridSquareTap,
            ),
          ),
          SizedBox(
            width: 80,
            height: 450,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 45, 0, 0),
              child: Column(
                children: [
                  _buildBingoLetter(
                      'B', (_logicKey.currentState?.completedSets ?? 0) >= 1),
                  const SizedBox(height: 10),
                  _buildBingoLetter(
                      'I', (_logicKey.currentState?.completedSets ?? 0) >= 2),
                  const SizedBox(height: 10),
                  _buildBingoLetter(
                      'N', (_logicKey.currentState?.completedSets ?? 0) >= 3),
                  const SizedBox(height: 10),
                  _buildBingoLetter(
                      'G', (_logicKey.currentState?.completedSets ?? 0) >= 4),
                  const SizedBox(height: 10),
                  _buildBingoLetter(
                      'O', (_logicKey.currentState?.completedSets ?? 0) >= 5),
                  const SizedBox(height: 10),
                  _buildBingoLetter(
                      'O', // Added second 'O'
                      (_logicKey.currentState?.completedSets ?? 0) >= 6),
                  const SizedBox(height: 10),
                  _buildBingoLetter(
                      'S', // Added 'S'
                      (_logicKey.currentState?.completedSets ?? 0) >= 7),
                  const SizedBox(height: 10),
                  _buildBingoLetter(
                      '!!', // Added '!!'
                      (_logicKey.currentState?.completedSets ?? 0) >=
                          8), // Condition adjusted for 8 letters
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 300, 0, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mic_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mark_chat_unread_rounded),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBingoLetter(String letter, bool isCompleted) {
    return Text(
      letter,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isCompleted ? Colors.green : Colors.black,
      ),
    );
  }
}
