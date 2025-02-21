// Refactored BingoCoverPage

// File: lib/pages/bingo_cover_page.dart

import 'package:bingo_indian_style/pages/wrapper_page.dart'; // Suggestion: Rename wrapper.dart to wrapper_page.dart for consistency
import 'package:flutter/material.dart';
import 'package:blinking_text/blinking_text.dart';

class BingoCoverPage extends StatelessWidget {
  const BingoCoverPage({super.key});

  void _navigateToWrapper(BuildContext context) {
    // Extracted navigation logic
    Navigator.of(context).pushReplacement(
      // Use pushReplacement for cover page
      MaterialPageRoute(
          builder: (context) => const WrapperPage()), // Navigate to WrapperPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior
            .opaque, // More performant than transparent for full-screen tap
        onTap: () =>
            _navigateToWrapper(context), // Call navigation method on tap
        child: Container(
          // Use Container instead of SizedBox for background color or more styling
          width: double.infinity,
          height: double.infinity,
          color: Colors
              .white, // Example: Set white background color, remove if not needed from SizedBox
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment
                .center, // Center text horizontally within Column
            children: [
              _buildBingoTitle(), // Extracted Bingo Title Stack to a separate widget method
              const SizedBox(
                  height: 30), // Added spacing between title and blinking text
              _buildTapToContinueText(), // Extracted Blinking Text to a separate widget method
            ],
          ),
        ),
      ),
    );
  }

  // Extracted Bingo Title Widget
  Widget _buildBingoTitle() {
    return const Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'INDIAN STYLE',
            style: const TextStyle(
              // Use const for TextStyle
              fontFamily: 'Qahiri',
              fontSize: 100,
              color: Color.fromRGBO(255, 152, 129, 1),
            ),
          ),
        ),
        const SizedBox(height: 0), // No need for SizedBox with height 0
        Text(
          'BINGO',
          style: const TextStyle(
            // Use const for TextStyle
            fontFamily: 'Rammetto',
            fontSize: 70,
          ),
        ),
      ],
    );
  }

  // Extracted Blinking Text Widget
  Widget _buildTapToContinueText() {
    return const BlinkText(
      'Tap anywhere on screen to continue',
      style: const TextStyle(
          color: Color.fromRGBO(128, 128, 128, 0.5)), // Use const for TextStyle
      beginColor: const Color.fromRGBO(128, 128, 128,
          0.5), // Optional: Define beginColor explicitly if needed
      endColor: Colors.transparent, // Blink to transparent for fading effect
      duration: const Duration(seconds: 1), // Adjust blink duration if needed
    );
  }
}
