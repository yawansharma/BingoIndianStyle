// seven_by_seven_page.dart
// File: lib/pages/seven_by_seven_page.dart

// ignore_for_file: avoid_print

import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:bingo_indian_style/services/game_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bingo_indian_style/grids/Seven/SevenLogic.dart'; // Assuming you have SevenLogic
import 'package:bingo_indian_style/pages/play_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zwidget/zwidget.dart';

// --- BingoGrid Widget (Reused - No Changes Needed from six_by_six_page.dart) ---
class BingoGrid extends StatefulWidget {
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
  State<BingoGrid> createState() => _BingoGridState();
}

class _BingoGridState extends State<BingoGrid> {
  List<double> opacities =
      List.generate(49, (index) => 0.0); // Opacity list for animation

  @override
  void initState() {
    super.initState();
    if (!widget.gamePaused) {
      // Start animation only if game is not paused initially
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(BingoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.gamePaused && widget.gamePaused) {
      // Reset opacity if game is paused again
      setState(() {
        opacities = List.generate(49, (index) => 0.0);
      });
    }
    if (oldWidget.gamePaused && !widget.gamePaused) {
      // Start animation again when game resumes
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (int i = 0; i < 49; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        // Staggered delay
        if (mounted) {
          setState(() {
            opacities[i] = 1.0; // Fade in each square
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 306,
      height: 350,
      child: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
        itemCount: 49,
        itemBuilder: (context, index) {
          int number = widget.shuffledNumbers[index];
          bool isSelected = widget.availableSquares[number.toString()] ?? false;

          return AnimatedOpacity(
            // Wrapped with AnimatedOpacity for pop-up effect
            opacity: opacities[index], // Use opacity for animation
            duration: const Duration(milliseconds: 900),
            child: ZWidget.forwards(
              // Wrapped Container with ZWidget.normal for 3D - ADDED BACK
              depth: 25, // Adjusted depth for grid buttons
              midChild: InkWell(
                onTap: (widget.isMyTurn &&
                        !widget.gamePaused &&
                        !isSelected &&
                        !widget.isSpectator)
                    ? () => widget.onSquareTap(number)
                    : null,
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // Kept gradient for buttons
                      colors: isSelected
                          ? [Colors.red.shade700, Colors.red.shade400]
                          : [Colors.blue.shade700, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      // Added boxShadow for 3D effect
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- SevenBySeven Widget ---
class SevenBySeven extends StatefulWidget {
  final String roomId;
  const SevenBySeven({Key? key, required this.roomId}) : super(key: key);

  @override
  State<SevenBySeven> createState() => _SevenBySevenState();
}

class _SevenBySevenState extends State<SevenBySeven> {
  List<int> shuffledNumbers = [];
  Map<String, bool> availableSquares = {};
  String currentPlayerName = "Waiting...";
  bool isMyTurn = false;
  bool gamePaused = true;
  bool hasPressedBingo = false;
  bool isSpectator = false;

  final GameService _gameService = GameService();
  final GlobalKey<SevenlogicState> _logicKey =
      GlobalKey<SevenlogicState>(); // Changed Logic Key to SevenLogicState

  final audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _listenToGameUpdates();
  }

  Future<void> _initializeGame() async {
    shuffledNumbers = List.generate(49, (index) => index + 1)
      ..shuffle(); // 49 numbers for 7x7
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
        "Game Data Update (7x7): gamePaused = ${gameData['gamePaused']}, currentTurn = ${gameData['currentTurn']}, players = ${gameData['players']}, spectators = ${gameData['spectators']}"); // ADDED LOGGING

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
    List<bool> pressedStates = List.generate(49, (index) {
      // Updated to 49 for 7x7
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
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.5, // Half width
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.deepPurpleAccent],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.videogame_asset,
                        size: 50, color: Colors.white),
                  ),

                  const SizedBox(height: 15),

                  // Room ID
                  Text(
                    "ROOM ID: ${widget.roomId}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),

                  const SizedBox(height: 10),

                  // Question Text
                  const Text(
                    "Start Game?",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),

                  const SizedBox(height: 10),

                  // Additional Info
                  const Text(
                    "Not all players have joined. Do you want to start now?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _gameService.startGame(widget.roomId);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Start Now",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white, // Light theme background
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.5, // 50% of screen width
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🏆 Leaderboard",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black26),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    var entry = leaderboard[index];
                    String medal = _getMedal(index);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                medal,
                                style: const TextStyle(fontSize: 22),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry['name']!,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                          Text(
                            entry['time']!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.deepOrange),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () async {
                    await _gameService.deleteRoom(widget.roomId);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Function to get Medal for the top 3 players
  String _getMedal(int index) {
    switch (index) {
      case 0:
        return "🥇"; // Gold Medal
      case 1:
        return "🥈"; // Silver Medal
      case 2:
        return "🥉"; // Bronze Medal
      default:
        return "🎖️"; // Participation Medal
    }
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
    _playSound(number);
    await _gameService.updateAvailableSquares(widget.roomId, number);
    setState(() {
      availableSquares[number.toString()] = true;
    });
    _updateBingoState();
    await _gameService.endTurn(widget.roomId);
  }

  void _handleBingoButtonPress() {
    if ((_logicKey.currentState?.completedSets ?? 0) >=
            7 && // Bingo condition for 7x7 (adjust if needed)
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

  Future<void> _playSound(int number) async {
    try {
      final assetPath = 'audio/en_num_$number.mp3';
      await audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> _leaveGameRoom() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Do you want to leave the Game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('NO'),
          ),
          TextButton(
            onPressed: () async {
              await _gameService.userLeaveRoom(widget.roomId);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => BingoPlayPage()),
                (route) => route.isFirst,
              );
            },
            child: const Text("YES"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Shader linearGradient = const LinearGradient(
      colors: [
        Color(0xFFFFE17B), // Light gold
        Color(0xFFF6B042), // Deeper gold
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    Shader textGradient = const LinearGradient(
      colors: [
        Color(0xFFFFC371), // Light orange
        Color(0xFFFF5F6D), // Reddish-orange
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: ArtisticBackgroundPainter(),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                        height: 0,
                        width: 0,
                        child: Expanded(
                            child: Sevenlogic(
                                key:
                                    _logicKey))), // Changed SixLogic to SevenLogic
                    SafeArea(
                      child: SizedBox(
                        width: 300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildIconButton(
                                Icons.arrow_back_ios_new, _leaveGameRoom),
                            _buildIconButton(Icons.dashboard_rounded, () {}),
                            _buildIconButton(
                                Icons.photo_camera_outlined, () {}),
                            _buildIconButton(Icons.settings, () {}),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '${widget.roomId}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ZWidget.forwards(
                            depth: 10,
                            rotationX: pi / 22,
                            rotationY: -pi / 15,
                            midChild: Stack(
                              children: [
                                // Stroke effect
                                Text(
                                  'BINGO',
                                  style: TextStyle(
                                    fontFamily: 'Rammetto',
                                    fontSize: 30,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 6
                                      ..color = const Color.fromRGBO(
                                          98, 27, 59, 1), // Dark purple stroke
                                  ),
                                ),
                                // Gradient fill effect
                                Text(
                                  'BINGO',
                                  style: TextStyle(
                                    fontFamily: 'Rammetto',
                                    fontSize: 30,
                                    foreground: Paint()
                                      ..shader = linearGradient,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: ZWidget.backwards(
                              depth: 10,
                              rotationX: pi / 22,
                              rotationY: pi / 15,
                              midChild: Stack(
                                children: [
                                  // 3D Shadow effect (Layer 1 - Dark shadow)
                                  Positioned(
                                    left: 4,
                                    top: 4,
                                    child: Text(
                                      'INDIAN STYLE',
                                      style: TextStyle(
                                        fontFamily: 'Qahiri',
                                        fontSize: 45,
                                        color: Colors.brown
                                            .shade900, // Deep brown shadow
                                      ),
                                    ),
                                  ),
                                  // 3D Shadow effect (Layer 2 - Lighter shadow for depth)
                                  Positioned(
                                    left: 2,
                                    top: 2,
                                    child: Text(
                                      'INDIAN STYLE',
                                      style: TextStyle(
                                        fontFamily: 'Qahiri',
                                        fontSize: 45,
                                        color: Colors.brown
                                            .shade500, // Medium brown shadow
                                      ),
                                    ),
                                  ),
                                  // Gradient Fill (Main Layer)
                                  Text(
                                    'INDIAN STYLE',
                                    style: TextStyle(
                                      fontFamily: 'Qahiri',
                                      fontSize: 45,
                                      foreground: Paint()
                                        ..shader =
                                            textGradient, // Gradient fill
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 0, 10),
                      child: GestureDetector(
                        onTap: _handleBingoButtonPress,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          width: 130, // More compact size
                          height: 45, // Sleeker height
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                12), // Softer rounded edges
                            gradient:
                                (_logicKey.currentState?.completedSets ?? 0) >=
                                        5
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFFFE57F), // Soft gold
                                          Color(0xFFFFB74D), // Warm orange
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.grey.shade900,
                                          Colors.grey.shade700,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                            boxShadow: (_logicKey.currentState?.completedSets ??
                                        0) >=
                                    5
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.amberAccent.withOpacity(0.7),
                                      blurRadius: 15,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 3),
                                    ),
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 3,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                            border: Border.all(
                              color: (_logicKey.currentState?.completedSets ??
                                          0) >=
                                      5
                                  ? Colors.amberAccent
                                  : Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            'BINGO',
                            style: TextStyle(
                              fontSize: 20, // Smaller font for a sleek look
                              fontWeight: FontWeight.w600, // Not too bold
                              letterSpacing: 1.5,
                              foreground: Paint()
                                ..shader = (_logicKey
                                                .currentState?.completedSets ??
                                            0) >=
                                        5
                                    ? LinearGradient(
                                        colors: [
                                          Colors.yellowAccent.shade700,
                                          Colors.orangeAccent.shade400,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 150, 40))
                                    : const LinearGradient(
                                        colors: [
                                          Colors.white70,
                                          Colors.blueGrey
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 150, 40)),
                              shadows: (_logicKey.currentState?.completedSets ??
                                          0) >=
                                      5
                                  ? [
                                      const Shadow(
                                        blurRadius: 10,
                                        color: Colors.amberAccent,
                                        offset: Offset(0, 2),
                                      ),
                                      const Shadow(
                                        blurRadius: 15,
                                        color: Colors.orangeAccent,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      const Shadow(
                                        blurRadius: 4,
                                        color: Colors.black54,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ),
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
                    const Text('7x7', // Updated to 7x7 Grid Size Text
                        style: TextStyle(fontFamily: 'MajorMono', fontSize: 24))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(80, 10, 0, 10),
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
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 40, 0, 0),
                  child: Column(
                    children: [
                      _buildBingoLetter('B',
                          (_logicKey.currentState?.completedSets ?? 0) >= 1),
                      const SizedBox(height: 20),
                      _buildBingoLetter('I',
                          (_logicKey.currentState?.completedSets ?? 0) >= 2),
                      const SizedBox(height: 20),
                      _buildBingoLetter('N',
                          (_logicKey.currentState?.completedSets ?? 0) >= 3),
                      const SizedBox(height: 20),
                      _buildBingoLetter('G',
                          (_logicKey.currentState?.completedSets ?? 0) >= 4),
                      const SizedBox(height: 20),
                      _buildBingoLetter('O',
                          (_logicKey.currentState?.completedSets ?? 0) >= 5),
                      const SizedBox(height: 20),
                      _buildBingoLetter(
                          'S',
                          (_logicKey.currentState?.completedSets ?? 0) >=
                              6), // Added 'O' for 7th letter
                      const SizedBox(height: 20),
                      _buildBingoLetter(
                          '!!',
                          (_logicKey.currentState?.completedSets ?? 0) >=
                              7), // Added 'S' for 7th letter
                      const SizedBox(height: 20),
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
        ],
      ),
    );
  }

  Widget _buildBingoLetter(String letter, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transform:
          isCompleted ? (Matrix4.identity()..scale(1.2)) : Matrix4.identity(),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..shader = LinearGradient(
              colors: isCompleted
                  ? [Colors.yellowAccent, Colors.orangeAccent]
                  : [Colors.white70, Colors.blueGrey],
            ).createShader(const Rect.fromLTWH(0, 0, 40, 40)),
          shadows: isCompleted
              ? [
                  const Shadow(
                    blurRadius: 15,
                    color: Colors.orangeAccent,
                    offset: Offset(0, 0),
                  ),
                  const Shadow(
                    blurRadius: 20,
                    color: Colors.yellowAccent,
                    offset: Offset(0, 0),
                  ),
                ]
              : [
                  const Shadow(
                    blurRadius: 5,
                    color: Colors.black54,
                    offset: Offset(2, 2),
                  ),
                ],
        ),
      ),
    );
  }
}

Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
      ),
    ),
  );
}

class ArtisticBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    // Enhanced Background Sky Gradient
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      colors: [
        Colors.deepPurple.shade900,
        Colors.pink.shade600,
        Colors.orange.shade400
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    // Sun/Moon with Glow Effect
    Paint sunPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2), 50, sunPaint);

    // Artistic Wave Layers
    _drawWave(canvas, size, Colors.indigo.shade700.withOpacity(0.9), 0.7);
    _drawWave(canvas, size, Colors.indigo.shade500.withOpacity(0.8), 0.75);
    _drawWave(canvas, size, Colors.indigo.shade300.withOpacity(0.7), 0.8);

    // Dynamic Cloud Layers
    _drawCloud(canvas, size, Offset(size.width * 0.2, size.height * 0.2), 50);
    _drawCloud(canvas, size, Offset(size.width * 0.7, size.height * 0.15), 60);
    _drawCloud(canvas, size, Offset(size.width * 0.4, size.height * 0.1), 40);

    // Starry Glow Effect
    _drawStar(canvas, size, Offset(size.width * 0.3, size.height * 0.1), 5);
    _drawStar(canvas, size, Offset(size.width * 0.8, size.height * 0.05), 7);
    _drawStar(canvas, size, Offset(size.width * 0.5, size.height * 0.2), 4);
  }

  void _drawWave(Canvas canvas, Size size, Color color, double heightFactor) {
    Paint wavePaint = Paint()..color = color;
    Path wavePath = Path();
    wavePath.moveTo(0, size.height * heightFactor);
    wavePath.quadraticBezierTo(
        size.width * 0.3,
        size.height * (heightFactor - 0.05),
        size.width * 0.6,
        size.height * heightFactor);
    wavePath.quadraticBezierTo(
        size.width * 0.85,
        size.height * (heightFactor + 0.05),
        size.width,
        size.height * heightFactor);
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, wavePaint);
  }

  void _drawCloud(Canvas canvas, Size size, Offset position, double radius) {
    Paint cloudPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(position, radius, cloudPaint);
    canvas.drawCircle(
        Offset(position.dx + radius * 0.6, position.dy + radius * 0.2),
        radius * 0.8,
        cloudPaint);
    canvas.drawCircle(
        Offset(position.dx - radius * 0.6, position.dy + radius * 0.3),
        radius * 0.7,
        cloudPaint);
    canvas.drawCircle(Offset(position.dx, position.dy + radius * 0.5),
        radius * 0.6, cloudPaint);
  }

  void _drawStar(Canvas canvas, Size size, Offset position, double radius) {
    Paint starPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(position, radius, starPaint);
    canvas.drawCircle(
        Offset(position.dx + 2, position.dy - 2), radius * 0.7, starPaint);
    canvas.drawCircle(
        Offset(position.dx - 2, position.dy + 2), radius * 0.6, starPaint);
    canvas.drawCircle(
        Offset(position.dx, position.dy + 3), radius * 0.5, starPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
