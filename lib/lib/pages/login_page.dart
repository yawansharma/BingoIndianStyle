// Refactored LoginPage (Second Iteration)

// File: lib/pages/login_page.dart

import 'package:bingo_indian_style/pages/main_page.dart'; // Suggestion: Rename signup.dart to signup_page.dart for consistency
import 'package:bingo_indian_style/services/auth_service.dart'; // Using BaseAuthService interface
import 'package:flutter/material.dart';

// Suggestion: Move GoogleSignInButton to lib/widgets/google_sign_in_button.dart if not already done

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState(); // Corrected: _LoginPageState
}

class _LoginPageState extends State<LoginPage> {
  // Corrected: _LoginPageState
  // Suggestion: Consider using a Form widget and FormField for email/password input if adding email/password login
  // final TextEditingController _emailController = TextEditingController(); // For future email/password login
  // final TextEditingController _passwordController = TextEditingController(); // For future email/password login
  final BaseAuthService _authService =
      AuthService(); // Use BaseAuthService interface

  // No need to dispose controllers in this simple example as they are not used,
  // but keep dispose() method for future email/password login implementation

  Future<void> _handleGoogleLogin() async {
    // More descriptive method name
    try {
      await _authService.loginWithGoogle();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BingoMainPage()),
        );
      }
    } catch (e) {
      // Handle Google Login errors - Show SnackBar to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Login failed: ${e.toString()}')),
      );
      print(
          "Google Login error: ${e.toString()}"); // Keep logging for detailed errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Center content
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 350.0, vertical: 100.0),
          child: Row(
            children: [
              Column(
                // Left side - Login options
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GoogleSignInButton(
                    // Reusing extracted GoogleSignInButton widget
                    onPressed:
                        _handleGoogleLogin, // Using more descriptive handler method
                  ),
                  // Suggestion: Add Email/Password Login UI here if needed in future
                  // Example (commented out):
                  /*
                  const SizedBox(height: 20),
                  const Text("Or login with email and password:", style: TextStyle(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Implement email/password login logic using _authService.signIn()
                    },
                    child: const Text('Login with Email'),
                  ),
                  */
                ],
              ),
              // Suggestion: Add a visual separator or side image here if desired
              // Example (commented out):
              /*
              const SizedBox(width: 50),
              const Expanded(
                child: VerticalDivider(width: 2, color: Colors.grey), // Example separator
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}

// --- GoogleSignInButton Widget (Assuming this is in the same file or in lib/widgets/google_sign_in_button.dart) ---
class GoogleSignInButton extends StatelessWidget {
  // Reusing extracted Google Sign-In Button as a Widget
  final VoidCallback onPressed;

  const GoogleSignInButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Using ElevatedButton.icon for better styling and icon positioning
      onPressed: onPressed,
      icon: const Icon(Icons.g_mobiledata_rounded,
          color: Colors.white), // White icon for better visibility
      label: const Text('Sign in with Google',
          style: TextStyle(color: Colors.white)), // White text color
      style: ElevatedButton.styleFrom(
        // Using ElevatedButton.styleFrom for cleaner styling
        backgroundColor:
            const Color.fromRGBO(66, 133, 244, 1), // Google blue color
        foregroundColor: Colors.white, // Text and icon color
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 12), // Adjust padding for button size
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)), // Rounded corners
        elevation: 2, // Add a slight shadow
      ),
    );
  }
}
