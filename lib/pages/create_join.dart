// File: lib/pages/create_join.dart

import 'package:bingo_indian_style/pages/play_page.dart';
import 'package:bingo_indian_style/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bingo_indian_style/services/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CreateOrJoinSection extends StatelessWidget {
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
        _buildAnimatedButton(
          label: 'CREATE ROOM', // More descriptive label
          onPressed: onCreatePressed,
          context: context, // Pass context for responsive sizing
        ),
        const SizedBox(height: 16), // Increased spacing
        orSeparator,
        const SizedBox(height: 16), // Increased spacing
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 30.0), // Increased horizontal padding
          child: joinRoomTextField,
        ),
        const SizedBox(height: 16), // Increased spacing
        _buildAnimatedButton(
          label: 'JOIN ROOM', // More descriptive label
          onPressed: () {
            HapticFeedback.mediumImpact();
            final state =
                context.findAncestorStateOfType<_CreateJoinPageState>();
            if (state != null) {
              state._joinGameRoom();
            } else {
              //Handle the case where the state is not found.
              print("Error: Could not find the CreateJoinPageState");
            } // Vibration feedback on button press
          },
          context: context, // Pass context for responsive sizing
        ),
      ],
    );
  }

  Widget _buildAnimatedButton(
      {required String label,
      required VoidCallback onPressed,
      required BuildContext context}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth * 0.025; // Responsive font size

    return SizedBox(
      width: screenWidth * 0.6 > 300
          ? 300
          : screenWidth * 0.6, // Responsive width with max width
      height: 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color.fromRGBO(114, 2, 156, 1)
              .withOpacity(0.8), // Slightly transparent button
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)), // More rounded buttons
        ),
        child: Text(
          label,
          style: TextStyle(
              color: Colors.white,
              fontSize: responsiveFontSize > 18
                  ? responsiveFontSize
                  : 18, // Responsive font size with minimum
              fontFamily: 'PurplePurse'), // Using PurplePurse font for buttons
        ),
      ).animate().fadeIn(duration: 600.ms).scaleXY(
          begin: 0.95,
          end: 1.0,
          duration: 500.ms,
          curve: Curves
              .easeOutBack), // Reduced scale animation and removed shimmer
    );
  }
}

class CreateJoinPage extends StatefulWidget {
  const CreateJoinPage({super.key});

  @override
  State<CreateJoinPage> createState() => _CreateJoinPageState();
}

class _CreateJoinPageState extends State<CreateJoinPage> {
  final TextEditingController _roomIdController = TextEditingController();
  final GameRepository _gameService = GameService();

  InterstitialAd? _interstitialAd;

  void initState() {
    super.initState();
    InterstitialAd.load(
      adUnitId: AdHelper.joinRoomInterstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          print('Interstitial ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _interstitialAd?.dispose();
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

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            print('ad showed full screen content'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent');
          ad.dispose();
          _interstitialAd = null;
          // Navigate after ad is dismissed.
          _gameService.joinRoom(roomCode, context).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to join room: $error')),
            );
          });
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _interstitialAd = null;
          //Handle the error or navigate without showing the ad.
          _gameService.joinRoom(roomCode, context).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to join room: $error')),
            );
          });
        },
      );
      _interstitialAd!.show();
    } else {
      //If ad failed to load, navigate directly (consider showing a message).
      _gameService.joinRoom(roomCode, context).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join room: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // FIX: Cast 400 to double to ensure responsiveContainerWidth is double
    final responsiveContainerWidth = screenWidth * 0.8 > 400
        ? 400.0
        : screenWidth * 0.8; // Responsive container width
    final responsiveContainerHeight = screenHeight * 0.7 > 500
        ? 500
        : screenHeight * 0.7; // Responsive container height
    final responsivePaddingVertical =
        screenHeight * 0.1; // Responsive vertical padding

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0099F7), // Bright blue
                  Color.fromARGB(255, 9, 86, 185), // Deep purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical:
                      responsivePaddingVertical), // Responsive vertical padding
              child: Container(
                width: responsiveContainerWidth, // Responsive width
                // height: responsiveContainerHeight, // Responsive height - Removed fixed height for better content fitting
                padding: const EdgeInsets.all(
                    24), // Increased padding inside container
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.1), // Semi-transparent white container
                  borderRadius:
                      BorderRadius.circular(24), // More rounded corners
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2)), // White border
                ),
                child: CreateOrJoinSection(
                  onCreatePressed: _navigateToBingoPlayPage,
                  orSeparator: const Text(
                    'OR',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontFamily: 'PurplePurse'), // Updated OR style
                  ),
                  joinRoomTextField:
                      _buildNeonTextField(context), // Pass context
                  joinRoomButton: _buildJoinButton(context), // Pass context
                ),
              ).animate().fadeIn(duration: 1000.ms).slideY(
                  begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOut),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonTextField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth * 0.025; // Responsive font size

    return TextField(
      controller: _roomIdController,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: InputDecoration(
        hintText: 'Enter Room ID',
        hintStyle: TextStyle(
            color: Colors.white70,
            fontSize: responsiveFontSize > 16
                ? responsiveFontSize
                : 16), // Responsive hint text size
        filled: true,
        fillColor: Colors.black.withOpacity(0.1), // More subtle fill color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), // Rounded border
          borderSide: BorderSide(
              color: Colors.white.withOpacity(0.3), width: 1.5), // White border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2), width: 1.5), // White border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Colors.white, width: 2), // White focused border
        ),
      ),
      style: TextStyle(
          color: Colors.white,
          fontSize: responsiveFontSize > 16
              ? responsiveFontSize
              : 16), // Responsive text size
    );
  }

  Widget _buildJoinButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth * 0.025; // Responsive font size

    return SizedBox(
      width: screenWidth * 0.6 > 300
          ? 300
          : screenWidth * 0.6, // Responsive width with max width
      height: 50,
      child: TextButton(
        onPressed: _joinGameRoom,
        style: TextButton.styleFrom(
          backgroundColor: const Color.fromRGBO(114, 2, 156, 1)
              .withOpacity(0.8), // Slightly transparent button
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)), // More rounded buttons
        ),
        child: Text(
          'JOIN ROOM', // More descriptive label
          style: TextStyle(
              color: Colors.white,
              fontSize: responsiveFontSize > 18
                  ? responsiveFontSize
                  : 18, // Responsive font size with minimum
              fontFamily: 'PurplePurse',
              fontWeight:
                  FontWeight.normal), // Using PurplePurse font, removed bold
        ),
      ).animate().fadeIn(duration: 600.ms).scaleXY(
          begin: 0.95,
          end: 1.0,
          duration: 500.ms,
          curve: Curves
              .easeOutBack), // Reduced scale animation and removed shimmer
    );
  }
}
