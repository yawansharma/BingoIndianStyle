import 'package:flutter/material.dart';

class Sevenlogic extends StatefulWidget {
  const Sevenlogic({super.key});

  @override
  State<Sevenlogic> createState() => SevenlogicState();
}

class SevenlogicState extends State<Sevenlogic> {
  int setsCompleted = 0;

  final List<List<int>> rows = [
  [0, 1, 2, 3, 4, 5, 6],
  [7, 8, 9, 10, 11, 12, 13],
  [14, 15, 16, 17, 18, 19, 20],
  [21, 22, 23, 24, 25, 26, 27],
  [28, 29, 30, 31, 32, 33, 34],
  [35, 36, 37, 38, 39, 40, 41],
  [42, 43, 44, 45, 46, 47, 48]
];

final List<List<int>> columns = [
  [0, 7, 14, 21, 28, 35, 42],
  [1, 8, 15, 22, 29, 36, 43],
  [2, 9, 16, 23, 30, 37, 44],
  [3, 10, 17, 24, 31, 38, 45],
  [4, 11, 18, 25, 32, 39, 46],
  [5, 12, 19, 26, 33, 40, 47],
  [6, 13, 20, 27, 34, 41, 48]
];

final List<List<int>> diagonals = [
  [0, 8, 16, 24, 32, 40, 48],
  [6, 12, 18, 24, 30, 36, 42]
];

void buttonPress(List<bool> isPressed){
  setState(() {
    setsCompleted=0;
    for(var row in rows){
        if(row.every((index)=>isPressed[index])){
          setsCompleted++;
        }
      }
      for(var column in columns){
        if(column.every((index)=>isPressed[index])){
          setsCompleted++;
        }
      }
      for(var diagonal in diagonals){
        if(diagonal.every((index)=>isPressed[index])){
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