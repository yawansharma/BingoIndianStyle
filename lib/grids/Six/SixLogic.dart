import 'package:flutter/material.dart';

class Sixlogic extends StatefulWidget {
  const Sixlogic({super.key});

  @override
  State<Sixlogic> createState() => SixlogicState();
}

class SixlogicState extends State<Sixlogic> {
  int setsCompleted = 0;

  final List<List<int>> diagonals = [
    [0, 7, 14, 21, 28, 35], 
    [5, 10, 15, 20, 25, 30]
  ];
  
  final List<List<int>> columns = [
  [0, 6, 12, 18, 24, 30],
  [1, 7, 13, 19, 25, 31],
  [2, 8, 14, 20, 26, 32],
  [3, 9, 15, 21, 27, 33],
  [4, 10, 16, 22, 28, 34],
  [5, 11, 17, 23, 29, 35]
];

final List<List<int>> rows = [
  [0, 1, 2, 3, 4, 5],
  [6, 7, 8, 9, 10, 11],
  [12, 13, 14, 15, 16, 17],
  [18, 19, 20, 21, 22, 23],
  [24, 25, 26, 27, 28, 29],
  [30, 31, 32, 33, 34, 35]
];

void buttonPress(List<bool> isPressed){
  setState(() {
    setsCompleted = 0;
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