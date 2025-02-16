import 'package:bingo_indian_style/grids/Eight/eight.dart';
import 'package:bingo_indian_style/grids/Five/FIveByFive.dart';
import 'package:bingo_indian_style/grids/Seven/seven.dart';
import 'package:bingo_indian_style/grids/Six/six.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

import 'package:flutter/material.dart';

class GameService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  int RoomNum() {
    int roomNum = Random().nextInt(1000);
    return roomNum;
  }

  void createRoom(int roomId, int size, int maxPlayers) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String hostId = user.uid;
      String hostName = user.displayName ?? "Unknown Player";

      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('gameRooms');

      List<int> numbers = List.generate(size * size, (index) => index + 1)
        ..shuffle();

      Map<String, bool> availableSquares = {
        for (var num in numbers) num.toString(): false
      };

      await collectionReference.doc(roomId.toString()).set({
        'roomId': roomId,
        'gridSize': size,
        'gridNumbers': numbers,
        'availableSquares': availableSquares,
        'noOfPlayers': maxPlayers,
        'players': [hostId],
        'playerNames': {hostId: hostName},
        'gameStarted': false,
        'gamePaused': true,
        'currentTurn': 0,
        'bingoReactionTimes': {},
        'spectators': []
      });

      print(
          "Room $roomId created by host: $hostName ($hostId), waiting for players...");
    } catch (e) {
      print('Could not create room: $e');
    }
  }

  void joinRoom(int roomId, BuildContext context) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('gameRooms')
          .doc('$roomId')
          .get();

      if (!doc.exists) {
        print("Room does not exist.");
        return;
      }

      UserJoinRoom(roomId); // Add the player to the game

      final int size = doc['gridSize'];
      Widget gameScreen;

      switch (size) {
        case 5:
          gameScreen = FiveByFive(roomId: roomId);
          break;
        case 6:
          gameScreen = const SixBySix();
          break;
        case 7:
          gameScreen = const SevenBySeven();
          break;
        case 8:
          gameScreen = const EightByEight();
          break;
        default:
          print("Invalid grid size.");
          return;
      }

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => gameScreen));
    } catch (e) {
      print('Unable to join: $e');
    }
  }

  void updateAvailableSquares(int roomNo, int pressedNumber) async {
    try {
      await FirebaseFirestore.instance
          .collection('gameRooms')
          .doc(roomNo.toString())
          .update({
        'availableSquares.${pressedNumber.toString()}':
            true, // Mark number as pressed
      });
    } catch (e) {
      print("Error updating available squares: $e");
    }
  }

  void UserJoinRoom(int roomNo) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String userId = user.uid;
    String userName = user.displayName ?? "Unknown Player";

    DocumentReference roomRef =
        _firestore.collection('gameRooms').doc(roomNo.toString());

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        print("Room does not exist.");
        return;
      }

      Map<String, dynamic> roomData = snapshot.data() as Map<String, dynamic>;
      List<dynamic> players = roomData['players'] ?? [];
      Map<String, dynamic> playerNames =
          Map<String, dynamic>.from(roomData['playerNames'] ?? {});
      int maxPlayers = roomData['noOfPlayers'] ?? 2;

      if (players.contains(userId)) {
        print("User already in the room.");
        return;
      }

      if (players.length >= maxPlayers) {
        print("Room is full.");
        return;
      }

      players.add(userId);
      playerNames[userId] = userName;

      transaction
          .update(roomRef, {'players': players, 'playerNames': playerNames});
      print("Updated playerNames: $playerNames");
    });
  }

  void startGame(int roomId) async {
    FirebaseFirestore.instance
        .collection('gameRooms')
        .doc(roomId.toString())
        .update({'gameStarted': true, 'gamePaused': false, 'currentTurn': 0});

    print("Game started for room $roomId");
  }

  void endTurn(int roomId) async {
    DocumentReference gameRef = FirebaseFirestore.instance
        .collection('gameRooms')
        .doc(roomId.toString());

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gameRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;

      List<String> players = List<String>.from(gameData['players'] ?? []);
      List<String> spectators = List<String>.from(gameData['spectators'] ?? []);
      int currentTurn = gameData['currentTurn'];

      // Exclude spectators from turn
      List<String> activePlayers =
          players.where((p) => !spectators.contains(p)).toList();

      if (activePlayers.isEmpty)
        return; // Prevent crash if all players pressed BINGO

      int nextTurnIndex = (activePlayers.indexOf(players[currentTurn]) + 1) %
          activePlayers.length;

      transaction.update(gameRef,
          {'currentTurn': players.indexOf(activePlayers[nextTurnIndex])});
    });

    print("Turn updated for room $roomId");
  }

  void recordBingoPress(int roomId, String userId) async {
    DocumentReference gameRef = FirebaseFirestore.instance
        .collection('gameRooms')
        .doc(roomId.toString());

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gameRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;

      bool bingoStarted =
          gameData.containsKey('bingoStartTime'); // Check if timer exists
      int currentTime =
          DateTime.now().millisecondsSinceEpoch; // Get current timestamp

      Map<String, dynamic> updatedData = {
        'bingoReactionTimes.$userId':
            currentTime - (gameData['bingoStartTime'] ?? currentTime),
        'spectators': FieldValue.arrayUnion([userId]) // Mark user as spectator
      };

      // If no global timer exists, set it
      if (!bingoStarted) {
        updatedData['bingoStartTime'] = currentTime;
      }

      transaction.update(gameRef, updatedData);
    });

    print("User $userId pressed BINGO at global time.");
  }
}
