//EightLogic.dart
import 'package:flutter/material.dart';

class EightLogic extends StatefulWidget {
  const EightLogic({super.key});

  @override
  State<EightLogic> createState() => EightLogicState();
}

class EightLogicState extends State<EightLogic> {
  int setsCompleted = 0;

  final List<List<int>> rows = [
    [0, 1, 2, 3, 4, 5, 6, 7],
    [8, 9, 10, 11, 12, 13, 14, 15],
    [16, 17, 18, 19, 20, 21, 22, 23],
    [24, 25, 26, 27, 28, 29, 30, 31],
    [32, 33, 34, 35, 36, 37, 38, 39],
    [40, 41, 42, 43, 44, 45, 46, 47],
    [48, 49, 50, 51, 52, 53, 54, 55],
    [56, 57, 58, 59, 60, 61, 62, 63]
  ];

  final List<List<int>> columns = [
    [0, 8, 16, 24, 32, 40, 48, 56],
    [1, 9, 17, 25, 33, 41, 49, 57],
    [2, 10, 18, 26, 34, 42, 50, 58],
    [3, 11, 19, 27, 35, 43, 51, 59],
    [4, 12, 20, 28, 36, 44, 52, 60],
    [5, 13, 21, 29, 37, 45, 53, 61],
    [6, 14, 22, 30, 38, 46, 54, 62],
    [7, 15, 23, 31, 39, 47, 55, 63]
  ];

  final List<List<int>> diagonals = [
    [0, 9, 18, 27, 36, 45, 54, 63],
    [7, 14, 21, 28, 35, 42, 49, 56]
  ];

  void buttonPress(List<bool> isPressed) {
    setState(() {
      setsCompleted = 0;
      for (var row in rows) {
        if (row.every((index) => isPressed[index])) {
          setsCompleted++;
        }
      }
      for (var column in columns) {
        if (column.every((index) => isPressed[index])) {
          setsCompleted++;
        }
      }
      for (var diagonal in diagonals) {
        if (diagonal.every((index) => isPressed[index])) {
          setsCompleted++;
        }
      }
    });
  }

  int get completedSets => setsCompleted;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
