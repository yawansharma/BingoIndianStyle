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
    int roomNum = Random().nextInt(100);
    return roomNum;
  }

  void createRoom(int roomId, int size) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('gameRooms');

      List<int> numbers = List.generate(size * size, (index) => index + 1)
        ..shuffle();

      // List<List<int>> gridNumbers = List.generate(
      //     size, (row) => numbers.sublist(row * size, (row + 1) * size));

      Map<String, bool> availableSquares = {
        for (var num in numbers) num.toString(): false
      };

      await collectionReference.doc(roomId.toString()).set({
        'roomId': roomId,
        'gridSize': size,
        'gridNumbers': numbers,
        'availableSquares': availableSquares,
        'players': [],
      });
    } catch (e) {
      print('Couldnt Create Room: $e');
    }
  }

  void joinRoom(int roomId, BuildContext context) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('gameRooms')
          .doc('$roomId')
          .get();
      UserJoinRoom(roomId);
      final int size = doc['gridSize'];
      if (size == 5) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return FiveByFive(roomId: roomId);
        }));
      } else if (size == 6) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return SixBySix();
        }));
      } else if (size == 7) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return SevenBySeven();
        }));
      } else if (size == 8) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return EightByEight();
        }));
      }
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
    String userId = _auth.currentUser?.uid ?? "";

    DocumentReference roomRef =
        _firestore.collection('gameRooms').doc(roomNo.toString());

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        print("Room does not exist.");
        return;
      }

      // Handle missing 'players' array
      Map<String, dynamic> roomData = snapshot.data() as Map<String, dynamic>;
      List<dynamic> players =
          roomData.containsKey('players') ? roomData['players'] : [];

      if (players.contains(userId)) {
        print("User already in the room.");
        return;
      }

      if (players.length >= 2) {
        print("Room is full.");
        return;
      }

      // Add the new player's UID
      players.add(userId);
      transaction.update(roomRef, {'players': players});

      print("User $userId joined room $roomNo");
    });
  }
}
