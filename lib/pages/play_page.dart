// ignore_for_file: avoid_print

import 'package:bingo_indian_style/pages/create_join.dart';
import 'package:bingo_indian_style/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:bingo_indian_style/pages/main_page.dart';
import 'package:bingo_indian_style/grids/Five/FIveByFive.dart';
import 'package:bingo_indian_style/grids/Six/six.dart';
import 'package:bingo_indian_style/grids/Seven/seven.dart';
import 'package:bingo_indian_style/grids/Eight/eight.dart';
// import 'package:bingo/src/screens/create_join.dart';

class BingoPlayPage extends StatelessWidget {
  BingoPlayPage({super.key});
  final game = GameService();
  final roomId = GameService().RoomNum();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(MaterialPageRoute(builder: (context) {
                return const CreateJoin();
              }));
            },
            icon: const Icon(Icons.arrow_back)),
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
                padding: const EdgeInsets.fromLTRB(55, 20, 0, 20),
                child: SizedBox(
                  width: 800,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 81,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            game.createRoom(roomId, 5);
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return FiveByFive(
                                roomId: roomId,
                              );
                            }));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(255, 152, 120, 1),
                            foregroundColor: Colors.white,
                            elevation: 15,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          child: const Text('5x5'),
                        ),
                      ),
                      SizedBox(
                        width: 81,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            game.createRoom(roomId, 6);
                            // Navigator.of(context)
                            //     .push(MaterialPageRoute(builder: (context) {
                            //   return const SixBySix();
                            // }));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(255, 152, 120, 1),
                            foregroundColor: Colors.white,
                            elevation: 15,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          child: const Text('6x6'),
                        ),
                      )
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
                      onPressed: () {
                        game.createRoom(roomId, 7);
                        // Navigator.of(context)
                        //     .push(MaterialPageRoute(builder: (context) {
                        //   return const SevenBySeven();
                        // }));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 152, 120, 1),
                        foregroundColor: Colors.white,
                        elevation: 15,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      child: const Text('7x7'),
                    ),
                  ),
                  SizedBox(
                    width: 81,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        game.createRoom(roomId, 8);
                        // Navigator.of(context)
                        //     .push(MaterialPageRoute(builder: (context) {
                        //   return const EightByEight();
                        // }));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 152, 120, 1),
                        foregroundColor: Colors.white,
                        elevation: 15,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      child: const Text('8x8'),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
