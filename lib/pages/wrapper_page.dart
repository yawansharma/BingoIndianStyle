// Refactored WrapperPage (Second Correction - Copy Paste Ready)

// File: lib/pages/wrapper_page.dart (Corrected - Copy Paste Ready)

import 'package:bingo_indian_style/pages/login_page.dart'; // Suggestion: Rename main_page.dart to bingo_main_page.dart for consistency
import 'package:bingo_indian_style/pages/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WrapperPage extends StatelessWidget {
  // Suggestion: Rename Wrapper to WrapperPage for consistency
  const WrapperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _buildAuthDependentContent(), // Extracted StreamBuilder logic to a separate method
    );
  }

  Widget _buildAuthDependentContent() {
    // Private method to encapsulate StreamBuilder logic - SRP
    return StreamBuilder<User?>(
      // Explicitly type StreamBuilder for clarity
      stream: FirebaseAuth.instance
          .authStateChanges(), // Stream of authentication state changes
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        // Explicitly type snapshot for clarity
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(); // Extracted loading indicator widget
        } else if (snapshot.hasError) {
          return _buildErrorDisplay(
              snapshot.error); // Extracted error display widget, passing error
        } else {
          return _buildAuthStatusBasedPage(
              snapshot.data); // Extracted page selection based on auth status
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    // Extracted Loading Indicator Widget - Reusability, Readability
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorDisplay(Object? error) {
    // Extracted Error Display Widget - Reusability, Readability, Error Handling
    // Suggestion: Create a more user-friendly error display widget in lib/widgets if needed in multiple places
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(16.0), // Add padding for better readability
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: Colors.red, size: 60), // Error icon for visual cue
            const SizedBox(height: 20),
            Text(
              'Authentication Error Occurred', // More user-friendly error title
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800), // Style error title
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Please try again later. If the issue persists, contact support.', // User guidance
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Suggestion: Add a "Retry" button here if appropriate for your app's error recovery strategy
            // Example (commented out):
            /*
            ElevatedButton(
              onPressed: () {
                // Retry logic - could be to re-initialize the StreamBuilder or try to refresh auth state
                // For this simple example, just rebuilding the WrapperPage might be enough
                // You might need to use a StateKey to force rebuild WrapperPage if needed for retry
              },
              child: const Text('Retry'),
            ),
            */
            if (error !=
                null) // Conditionally display detailed error for debugging (remove in production)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Detailed Error: ${error.toString()}', // Display detailed error for debugging
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthStatusBasedPage(User? user) {
    // Extracted Auth Status Based Page Widget - Readability, Logic Separation
    return user == null
        ? const LoginPage()
        : const BingoMainPage(); // Simple conditional rendering based on user auth state
  }
}
