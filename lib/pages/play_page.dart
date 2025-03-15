// File: lib/pages/play_page.dart

// ignore_for_file: avoid_print

import 'package:bingo_indian_style/grids/Eight/eight.dart';
import 'package:bingo_indian_style/grids/Seven/seven.dart';
import 'package:bingo_indian_style/grids/Six/six.dart';
import 'package:bingo_indian_style/pages/create_join.dart';
import 'package:bingo_indian_style/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:bingo_indian_style/grids/Five/FIveByFive.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bingo_indian_style/services/ad_helper.dart';

class BingoPlayPage extends StatefulWidget {
  final int gridSize;
  final bool isCustom;

  const BingoPlayPage({Key? key, this.gridSize = 5, this.isCustom = false})
      : super(key: key);

  @override
  State<BingoPlayPage> createState() => _BingoPlayPageState();
}

class _BingoPlayPageState extends State<BingoPlayPage> {
  final GameRepository _gameService = GameService();
  List<int> numbers = [];
  List<int> selectedNumbers = [];
  String _roomId = '';
  double _noOfPlayers = 1.0;
  bool _isGridGenerated = false; // Track if the grid has been generated
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();

  late BannerAd _bannerAdLeft;
  late BannerAd _bannerAdRight;

  InterstitialAd? _interstitialAd5x5;
  InterstitialAd? _interstitialAd6x6;
  InterstitialAd? _interstitialAd7x7;
  InterstitialAd? _interstitialAd8x8;

  @override
  void initState() {
    super.initState();
    _bannerAdLeft = BannerAd(
      adUnitId: AdHelper.bannerAdUnitIdLeft,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    );
    _bannerAdRight = BannerAd(
      adUnitId: AdHelper.bannerAdUnitIdRight,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    );
    _bannerAdLeft.load();
    _bannerAdRight.load();

    // Load interstitial ads
    _loadInterstitialAd(5, (ad) => _interstitialAd5x5 = ad);
    _loadInterstitialAd(6, (ad) => _interstitialAd6x6 = ad);
    _loadInterstitialAd(7, (ad) => _interstitialAd7x7 = ad);
    _loadInterstitialAd(8, (ad) => _interstitialAd8x8 = ad);

    if (widget.isCustom) {
      for (int i = 1; i <= widget.gridSize * widget.gridSize; i++) {
        numbers.add(i);
      }
    }
  }

  void _loadInterstitialAd(
      int gridSize, void Function(InterstitialAd?) onAdLoaded) {
    InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(gridSize),
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('InterstitialAd for $gridSize loaded');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd for $gridSize failed to load: $error.');
          onAdLoaded(null);
        },
      ),
    );
  }

  String _getInterstitialAdUnitId(int gridSize) {
    switch (gridSize) {
      case 6:
        return AdHelper.sixBySixInterstitialAdUnitId;
      case 7:
        return AdHelper.sevenBySevenInterstitialAdUnitId;
      case 8:
        return AdHelper.eightByEightInterstitialAdUnitId;
      default:
        return AdHelper.joinRoomInterstitialAdUnitId; // Or a default ad unit
    }
  }

  void _showInterstitialAd(int gridSize) {
    InterstitialAd? ad;
    switch (gridSize) {
      case 5:
        ad = _interstitialAd5x5;
        break;
      case 6:
        ad = _interstitialAd6x6;
        break;
      case 7:
        ad = _interstitialAd7x7;
        break;
      case 8:
        ad = _interstitialAd8x8;
        break;
    }
    if (ad != null) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) =>
            print('ad onAdShowedFullScreenContent'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('$ad onAdDismissedFullScreenContent');
          ad.dispose();
          _navigateToGameRoom(gridSize);
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          _navigateToGameRoom(gridSize);
        },
      );
      ad.show();
    } else {
      _navigateToGameRoom(gridSize); // Navigate if ad wasn't loaded.
    }
  }

  void _generateRoomId() {
    _roomId = _gameService.roomNum();
  }

  void _navigateToGameRoom(int gridSize) {
    _generateRoomId();
    _gameService.createRoom(_roomId, gridSize, _noOfPlayers.toInt()).then((_) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        switch (gridSize) {
          case 5:
            return FiveByFive(roomId: _roomId);
          case 6:
            return SixBySix(roomId: _roomId);
          case 7:
            return SevenBySeven(roomId: _roomId);
          case 8:
            return EightByEight(roomId: _roomId);
          default:
            return FiveByFive(roomId: _roomId);
        }
      }));
      _backgroundMusicPlayer.stop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create room: $error')),
      );
      print("Error creating room and navigating: $error");
    });
  }

  // Handle number selection for custom grid
  void _onNumberTapped(int number) {
    setState(() {
      if (selectedNumbers.contains(number)) {
        selectedNumbers.remove(number);
      } else {
        selectedNumbers.add(number);
      }
    });
  }

  //save the grid
  void _saveCustomGrid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'customGrids': {
          '${widget.gridSize}x${widget.gridSize}': selectedNumbers
        }
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom grid saved!')),
      );
    } catch (e) {
      print("Error saving custom grid: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving custom grid: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: widget.isCustom
            ? Text(
                "Select Numbers for Your ${widget.gridSize}x${widget.gridSize} Grid",
                style: const TextStyle(color: Colors.white),
              )
            : null,
        actions: widget.isCustom
            ? [
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.white),
                  onPressed: _saveCustomGrid,
                ),
              ]
            : null,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0099F7), // Bright blue - Consistent with main pages
              Color.fromARGB(
                  255, 9, 86, 185), // Deep purple - Consistent with main pages
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!widget.isCustom) // If its not a custom page
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.casino_rounded, color: Colors.white),
                      Text(
                        'Create Bingo Room',
                        style: GoogleFonts.anton(
                            textStyle: const TextStyle(
                                fontSize: 42,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                              Shadow(
                                  blurRadius: 3,
                                  color: Colors.black45,
                                  offset: Offset(2, 2))
                            ])),
                      )
                    ],
                  ),
                ),
              if (!widget.isCustom) // If its not a custom page
                const Text(
                  'Number of Players?',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PurplePurse',
                      fontSize: 21,
                      shadows: [
                        Shadow(
                            blurRadius: 2,
                            color: Colors.black38,
                            offset: Offset(1, 1))
                      ]),
                ),
              if (!widget.isCustom) // If its not a custom page
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 16.0),
                    activeTickMarkColor: Colors.white60,
                    inactiveTickMarkColor: Colors.white30,
                    overlayColor: const Color(0x1FFFFFFF),
                    valueIndicatorShape:
                        const PaddleSliderValueIndicatorShape(),
                    activeTrackColor: const Color(
                        0xFFFFD54F), // Muted Gold active track - Kept for slight warmth
                    inactiveTrackColor: Colors.white38,
                    thumbColor: const Color(
                        0xFFFFE082), // Muted Yellow thumb - Kept for slight warmth
                  ),
                  child: SizedBox(
                    width: 500.0,
                    child: Slider(
                      value: _noOfPlayers,
                      max: 7.0,
                      min: 1.0,
                      onChanged: (players) {
                        setState(() {
                          _noOfPlayers = players;
                        });
                        print(_noOfPlayers);
                      },
                      divisions: 6,
                      label: _noOfPlayers.toStringAsFixed(0),
                    ),
                  ),
                ),
              if (!widget.isCustom) const SizedBox(height: 10),
              if (!widget.isCustom) // If its not a custom page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(55, 30, 55, 20),
                      child: SizedBox(
                        width: 800.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGridSizeButton(context,
                                gridSize: 5,
                                buttonColor: const Color(
                                    0xFF64FFDA)), // Teal Accent - Vibrant but fits blue theme
                            _buildGridSizeButton(context,
                                gridSize: 6,
                                buttonColor: const Color(
                                    0xFFBBDEFB)), // Light Blue - Softer blue tone
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (!widget.isCustom) // If its not a custom page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(55, 20, 55, 30),
                      child: SizedBox(
                        width: 800.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGridSizeButton(context,
                                gridSize: 7,
                                buttonColor: const Color(
                                    0xFFFFD740)), // Amber - Warm contrast
                            _buildGridSizeButton(context,
                                gridSize: 8,
                                buttonColor: const Color(
                                    0xFFCE93D8)), // Light Purple - Matches purple in gradient
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (widget.isCustom &&
                  !_isGridGenerated) // If it's a custom grid and the grid hasn't been generated
                _buildCustomGrid(context),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Align(
                    // Left Banner Ad
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: _bannerAdLeft.size.width.toDouble(),
                      height: _bannerAdLeft.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAdLeft),
                    ),
                  ),
                  Align(
                    // Right Banner Ad
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: _bannerAdRight.size.width.toDouble(),
                      height: _bannerAdRight.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAdRight),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridSizeButton(BuildContext context,
      {required int gridSize, required Color buttonColor}) {
    String buttonText = '${gridSize}x$gridSize';
    return SizedBox(
      width: 130.0,
      height: 65.0,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _isGridGenerated = true;
          });
          _showInterstitialAd(
              gridSize); // Set the flag to true when creating a room
          //_navigateToGameRoom(gridSize);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              buttonColor.withOpacity(0.95), // Slightly less opaque
          foregroundColor: Colors
              .black87, // Darker text for better contrast on lighter buttons
          elevation: 8, // Slightly reduced elevation for softer look
          shadowColor: Colors.black38, // More subtle shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(13),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
              fontFamily: 'PurplePurse',
              fontSize: 22,
              fontWeight:
                  FontWeight.w600), // Slightly smaller font, bold font weight
        ),
      )
          .animate()
          .scaleXY(duration: 200.ms, end: 0.96, curve: Curves.easeInOut)
          .then()
          .scaleXY(duration: 100.ms, end: 1.0),
    );
  }

  Widget _buildCustomGrid(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridSize,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: widget.gridSize * widget.gridSize,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onNumberTapped(numbers[index]),
              child: Container(
                decoration: BoxDecoration(
                  color: selectedNumbers.contains(numbers[index])
                      ? Colors.green.withOpacity(0.7)
                      : Colors.white.withOpacity(0.7),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    numbers[index].toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedNumbers.contains(numbers[index])
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
