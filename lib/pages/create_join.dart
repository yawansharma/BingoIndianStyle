// Refactored CreateJoinPage (Second Iteration)

// File: lib/pages/create_join_page.dart (Suggestion: Rename to create_join_page.dart for consistency)

import 'package:bingo_indian_style/pages/play_page.dart';
import 'package:bingo_indian_style/services/game_service.dart'; // Using GameRepository interface
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Suggestion: Create a folder 'widgets' and move reusable widgets like CreateOrJoinSection to it
// For now, keeping it in the same file for easier copy-paste

class CreateOrJoinSection extends StatelessWidget {
  // Extracted Create/Join Section as a Widget
  final VoidCallback onCreatePressed;
  final Widget orSeparator;
  final Widget joinRoomTextField;
  final Widget joinRoomButton;

  const CreateOrJoinSection({
    Key? key,
    required this.onCreatePressed,
    required this.orSeparator,
    required this.joinRoomTextField,
    required this.joinRoomButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 200,
            height: 50,
            child: TextButton(
              onPressed: onCreatePressed,
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(114, 2, 156, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'CREATE',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        orSeparator,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(width: 200, child: joinRoomTextField),
        ),
        SizedBox(width: 200, height: 50, child: joinRoomButton),
      ],
    );
  }
}

class CreateJoinPage extends StatefulWidget {
  // Suggestion: Rename to CreateJoinPage for consistency
  const CreateJoinPage({super.key});

  @override
  State<CreateJoinPage> createState() =>
      _CreateJoinPageState(); // Suggestion: Rename to _CreateJoinPageState for consistency
}

class _CreateJoinPageState extends State<CreateJoinPage> {
  // Suggestion: Rename to _CreateJoinPageState for consistency
  final TextEditingController _roomIdController = TextEditingController();
  final GameRepository _gameService = GameService();

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _navigateToBingoPlayPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return BingoPlayPage();
    }));
  }

  void _joinGameRoom() {
    String roomIdText = _roomIdController.text;
    if (roomIdText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Room ID')),
      );
      return;
    }

    int? roomCode = int.tryParse(roomIdText);
    if (roomCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Invalid Room ID format. Please enter numbers only.')),
      );
      return;
    }

    _gameService.joinRoom(roomCode, context).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join room: $error')),
      );
      print("Error joining room: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 350.0, vertical: 80.0),
          child: CreateOrJoinSection(
            // Using the extracted CreateOrJoinSection widget
            onCreatePressed: _navigateToBingoPlayPage,
            orSeparator: const Text(
              'OR',
              style: TextStyle(color: Colors.grey),
            ),
            joinRoomTextField: TextField(
              controller: _roomIdController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                hintText: 'Enter Room ID',
                border: OutlineInputBorder(),
              ),
            ),
            joinRoomButton: TextButton(
              onPressed: _joinGameRoom,
              style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(114, 2, 156, 1),
                  foregroundColor: Colors.white),
              child: const Text(
                'JOIN',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
