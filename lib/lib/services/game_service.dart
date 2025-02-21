// game_service.dart
// File: lib/services/game_service.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bingo_indian_style/grids/Five/FIveByFive.dart';

abstract class GameRepository {
  Future<void> updateAvailableSquares(String roomId, int number);
  Future<void> endTurn(String roomId);
  Future<void> recordBingoPress(String roomId, String userId);
  Future<void> startGame(String roomId);
  Future<void> userLeaveRoom(String roomId);
  String roomNum();
  Future<void> createRoom(String roomId, int gridSize, int noOfPlayers);
  Future<void> joinRoom(int roomId, BuildContext context);
  Future<void> deleteRoom(String roomId);
}

class GameService implements GameRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> updateAvailableSquares(String roomId, int number) async {
    DocumentReference gameRoomRef =
        _firestore.collection('gameRooms').doc(roomId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gameRoomRef);
      if (!snapshot.exists) {
        throw Exception("Game room does not exist!");
      }
      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;
      Map<String, bool> availableSquares =
          Map<String, bool>.from(gameData['availableSquares'] ?? {});

      availableSquares[number.toString()] = true;

      transaction.update(gameRoomRef, {'availableSquares': availableSquares});
    });
  }

  @override
  Future<void> endTurn(String roomId) async {
    DocumentReference gameRoomRef =
        _firestore.collection('gameRooms').doc(roomId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gameRoomRef);
      if (!snapshot.exists) {
        throw Exception("Game room does not exist!");
      }
      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;
      int currentTurn = gameData['currentTurn'] ?? 0;
      List<String> players = List<String>.from(gameData['players'] ?? []);
      List<String> spectators = List<String>.from(gameData['spectators'] ?? []);

      List<String> activePlayers =
          players.where((p) => !spectators.contains(p)).toList();

      int nextTurn = currentTurn;
      do {
        nextTurn = (nextTurn + 1) % players.length;
      } while (spectators.contains(players[nextTurn]) && players.isNotEmpty);

      transaction.update(gameRoomRef, {'currentTurn': nextTurn});
    });
  }

  @override
  Future<void> recordBingoPress(String roomId, String userId) async {
    DocumentReference gameRoomRef =
        _firestore.collection('gameRooms').doc(roomId);
    int reactionTime = DateTime.now().millisecondsSinceEpoch;

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gameRoomRef);
      if (!snapshot.exists) {
        throw Exception("Game room does not exist!");
      }

      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;
      int bingoStartTime = gameData['bingoStartTime'] ?? reactionTime;
      Map<String, int> bingoReactionTimes =
          Map<String, int>.from(gameData['bingoReactionTimes'] ?? {});
      List<String> players = List<String>.from(gameData['players'] ?? []);
      List<String> spectators = List<String>.from(gameData['spectators'] ?? []);

      if (!bingoReactionTimes.containsKey(userId)) {
        bingoReactionTimes[userId] = reactionTime - bingoStartTime;

        players.remove(userId);
        spectators.add(userId);

        transaction.update(gameRoomRef, {
          'bingoReactionTimes': bingoReactionTimes,
          'players': players,
          'spectators': spectators,
        });
        if (players.isNotEmpty) {
          int nextTurn = (gameData['currentTurn'] + 1) % players.length;
          transaction.update(gameRoomRef, {'currentTurn': nextTurn});
        } else {
          // If no active players left, end the game
          transaction.update(gameRoomRef, {'gamePaused': true});
        }
        if (players.isEmpty) {
          transaction.update(gameRoomRef, {'gamePaused': true});
        }
      }
    });
    // No need to update currentTurn here anymore as game is paused and leaderboard will be shown
    // The room will be deleted after leaderboard, ending the game.
  }

  @override
  Future<void> startGame(String roomId) async {
    DocumentReference gameRoomRef =
        _firestore.collection('gameRooms').doc(roomId);
    await gameRoomRef.update({
      'gameStarted': true,
      'gamePaused': false,
      'bingoStartTime': DateTime.now().millisecondsSinceEpoch,
      'currentTurn': 0,
    });
  }

  @override
  Future<void> userLeaveRoom(String roomId) async {
    String userId = _auth.currentUser!.uid;
    DocumentReference gameRoomRef =
        _firestore.collection('gameRooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gameRoomRef);
      if (!snapshot.exists) {
        throw Exception("Game room does not exist!");
      }

      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;
      List<String> players = List<String>.from(gameData['players'] ?? []);
      List<String> spectators = List<String>.from(gameData['spectators'] ?? []);

      if (players.contains(userId)) {
        players.remove(userId);
      } else if (spectators.contains(userId)) {
        spectators.remove(userId);
      } else {
        return;
      }

      if (players.isEmpty) {
        transaction.delete(gameRoomRef);
      } else {
        int currentTurn = gameData['currentTurn'] ?? 0;
        if (currentTurn >= players.length) {
          currentTurn = 0;
        }
        transaction.update(gameRoomRef, {
          'players': players,
          'spectators': spectators,
          'currentTurn': currentTurn,
        });
      }
    });
  }

  @override
  Future<void> joinRoom(int roomId, BuildContext context) async {
    String roomIdString = roomId.toString();
    DocumentSnapshot roomSnapshot =
        await _firestore.collection('gameRooms').doc(roomIdString).get();
    if (!roomSnapshot.exists) {
      throw Exception("Room not found: $roomIdString");
    }

    DocumentReference gameRoomRef =
        _firestore.collection('gameRooms').doc(roomIdString);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gameRoomRef);
      Map<String, dynamic> gameData = snapshot.data() as Map<String, dynamic>;
      List<String> players = List<String>.from(gameData['players'] ?? []);
      List<String> spectators = List<String>.from(gameData['spectators'] ?? []);

      if (!players.contains(_auth.currentUser!.uid) &&
          !spectators.contains(_auth.currentUser!.uid)) {
        int maxPlayers = gameData.containsKey('maxPlayers')
            ? gameData['maxPlayers']
            : 7; // Default maxPlayers to 7 if not set

        if (players.length < maxPlayers) {
          players.add(_auth.currentUser!.uid);
          transaction.update(gameRoomRef, {'players': players});
        } else {
          spectators.add(_auth.currentUser!.uid);
          transaction.update(gameRoomRef, {'spectators': spectators});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Room is full. Joining as spectator.')),
          );
        }
      }
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FiveByFive(roomId: roomIdString),
      ),
    );
  }

  @override
  String roomNum() {
    Random random = Random();
    int randomNumber = random.nextInt(900000) + 100000;
    return randomNumber.toString();
  }

  @override
  Future<void> createRoom(String roomId, int gridSize, int noOfPlayers) async {
    try {
      await _firestore.collection('gameRooms').doc(roomId).set({
        'roomId': roomId,
        'gridSize': gridSize,
        'maxPlayers': noOfPlayers,
        'createdAt': FieldValue.serverTimestamp(),
        'players': [_auth.currentUser!.uid],
        'spectators': [],
        'availableSquares': {},
        'currentTurn': 0,
        'gamePaused': true,
        'gameStarted': false,
        'bingoStartTime': 0,
        'bingoReactionTimes': {},
      });
    } catch (e) {
      print("Error creating room $roomId: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    try {
      await _firestore.collection('gameRooms').doc(roomId).delete();
    } catch (e) {
      print("Error deleting room $roomId: $e");
      rethrow;
    }
  }
}
