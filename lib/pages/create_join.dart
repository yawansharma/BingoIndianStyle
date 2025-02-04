import 'package:bingo_indian_style/pages/play_page.dart';
import 'package:bingo_indian_style/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateJoin extends StatefulWidget {
  const CreateJoin({super.key});

  @override
  State<CreateJoin> createState() => _CreateJoinState();
}

class _CreateJoinState extends State<CreateJoin> {
  final roomId = TextEditingController();
  final game = GameService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(350, 100, 0, 0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return BingoPlayPage();
                    }));
                  },
                  child: const Text(
                    'CREATE',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                          Color.fromRGBO(114, 2, 156, 1))),
                ),
              ),
            ),
            const Text(
              'OR',
              style: TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: 200,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    controller: roomId,
                  )),
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: TextButton(
                onPressed: () {
                  game.joinRoom(int.parse(roomId.text), context);
                },
                child: const Text(
                  'JOIN',
                  style: TextStyle(color: Colors.white),
                ),
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                        Color.fromRGBO(114, 2, 156, 1))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
