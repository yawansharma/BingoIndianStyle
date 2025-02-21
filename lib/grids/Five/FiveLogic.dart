import 'package:flutter/material.dart';

class FiveLogic extends StatefulWidget {
  const FiveLogic({super.key});

  @override
  State<FiveLogic> createState() => LogicState();
}

class LogicState extends State<FiveLogic> {
  int setsCompleted = 0;
  final List<List<int>> diagonals = [
    [0, 6, 12, 18, 24],
    [4, 8, 12, 16, 20]
  ];

  final List<List<int>> rows = [
    [0, 1, 2, 3, 4],
    [5, 6, 7, 8, 9],
    [10, 11, 12, 13, 14],
    [15, 16, 17, 18, 19],
    [20, 21, 22, 23, 24]
  ];

  final List<List<int>> columns = [
    [0, 5, 10, 15, 20],
    [1, 6, 11, 16, 21],
    [2, 7, 12, 17, 22],
    [3, 8, 13, 18, 23],
    [4, 9, 14, 19, 24]
  ];

  void buttonPress(List<bool> isPressed) {
    int completed = 0;

    for (var row in rows) {
      if (row.every((index) => isPressed[index])) {
        completed++;
      }
    }
    for (var column in columns) {
      if (column.every((index) => isPressed[index])) {
        completed++;
      }
    }
    for (var diagonal in diagonals) {
      if (diagonal.every((index) => isPressed[index])) {
        completed++;
      }
    }

    if (setsCompleted != completed) {
      setState(() {
        setsCompleted = completed;
      });
    }
  }

  int get completedSets => setsCompleted;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
