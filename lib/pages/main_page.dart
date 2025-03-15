import 'dart:math';
import 'dart:io';

import 'package:bingo_indian_style/pages/create_join.dart';
import 'package:bingo_indian_style/pages/settings.dart';
import 'package:bingo_indian_style/services/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zwidget/zwidget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';

class BingoOptions extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BingoOptions({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveHorizontalPadding = screenWidth * 0.08;
    final responsiveIconSize = screenWidth * 0.035;
    final responsiveFontSize = screenWidth * 0.02;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: responsiveHorizontalPadding, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: responsiveIconSize > 18 ? responsiveIconSize : 18),
            SizedBox(width: screenWidth * 0.008),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: responsiveFontSize > 16 ? responsiveFontSize : 16,
                    fontFamily: 'PurplePurse'),
                overflow: TextOverflow.fade,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BingoMainPage extends StatefulWidget {
  const BingoMainPage({super.key});

  @override
  State<BingoMainPage> createState() => _BingoMainPageState();
}

class _BingoMainPageState extends State<BingoMainPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bannerAd?.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final adUnitId = AdHelper.bannerAdUnitId;

    if (adUnitId.isEmpty) {
      print('Ad unit ID is empty. Skipping ad loading.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdReady = true;
          });
          print('Banner Ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          print('Failed to load a banner ad: ${error.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd?.load();
  }

  void _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('pop-268648.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _navigateToCreateJoinPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CreateJoinPage()));
  }

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Settings()));
  }

  void _handleHomeRulesPressed() {
    print('Home Rules Pressed');
  }

  Widget _buildBingoTitle(
      double responsiveTitleFontSize, double responsiveBingoFontSize) {
    final linearGradient = const LinearGradient(
      colors: [
        Color(0xFFFFE17B),
        Color(0xFFF6B042),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    final textGradient = const LinearGradient(
      colors: [
        Color(0xFFFFC371),
        Color(0xFFFF5F6D),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ZWidget.forwards(
          depth: 10,
          rotationY: -pi / 10,
          rotationX: pi / 22,
          midChild: Stack(
            children: [
              Text(
                'BINGO',
                style: TextStyle(
                  fontFamily: 'Rammetto',
                  fontSize: responsiveBingoFontSize > 30
                      ? responsiveBingoFontSize
                      : 30,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6
                    ..color = const Color.fromRGBO(98, 27, 59, 1),
                ),
              ),
              Text(
                'BINGO',
                style: TextStyle(
                  fontFamily: 'Rammetto',
                  fontSize: responsiveBingoFontSize > 30
                      ? responsiveBingoFontSize
                      : 30,
                  foreground: Paint()..shader = linearGradient,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 3000.ms)
              .animate(
                onPlay: (controller) => controller.repeat(period: 2000.ms),
              )
              .shimmer(duration: 4000.ms, color: Colors.lightBlue.shade100)
              .scaleXY(end: 1.1)
              .then()
              .scaleXY(end: 1 / 1.1),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: ZWidget.backwards(
            depth: 10,
            rotationX: pi / 22,
            rotationY: pi / 10,
            midChild: Stack(
              children: [
                Positioned(
                  left: 4,
                  top: 4,
                  child: Text(
                    'INDIAN STYLE',
                    style: TextStyle(
                      fontFamily: 'Qahiri',
                      fontSize: responsiveTitleFontSize > 40
                          ? responsiveTitleFontSize
                          : 40,
                      color: Colors.brown.shade900,
                    ),
                  ),
                ),
                Positioned(
                  left: 2,
                  top: 2,
                  child: Text(
                    'INDIAN STYLE',
                    style: TextStyle(
                      fontFamily: 'Qahiri',
                      fontSize: responsiveTitleFontSize > 40
                          ? responsiveTitleFontSize
                          : 40,
                      color: Colors.brown.shade500,
                    ),
                  ),
                ),
                Text(
                  'INDIAN STYLE',
                  style: TextStyle(
                    fontFamily: 'Qahiri',
                    fontSize: responsiveTitleFontSize > 40
                        ? responsiveTitleFontSize
                        : 40,
                    foreground: Paint()..shader = textGradient,
                  ),
                ),
              ],
            )
                .animate()
                .then(delay: 2000.ms)
                .fadeIn(duration: 1000.ms, curve: Curves.easeIn)
                .then()
                .animate(
                    onPlay: (controller) =>
                        controller.repeat(period: 10.seconds))
                .shake(
                    duration: 2000.ms, curve: Curves.easeInOutCubicEmphasized),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsColumn(
      BuildContext context, double responsiveSpacingHeight) {
    return Padding(
      padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.25),
      child: Row(
        // Changed from Column to Row
        mainAxisAlignment: MainAxisAlignment.center, // Center the row
        mainAxisSize: MainAxisSize.max,
        children: [
          // Image on left side.
          Image.asset(
            'assets/howToPlay.png', // Replace with your image path
            width: MediaQuery.of(context).size.width * 0.15,
            fit: BoxFit.contain,
          )
              .animate()
              .then(delay: 5000.ms)
              .fadeIn(duration: 1000.ms, curve: Curves.linear)
              .scaleXY(end: 1.1)
              .then()
              .animate(
                  onPlay: (controller) => controller.repeat(period: 4000.ms))
              .moveX(end: -10, duration: 500.ms, curve: Curves.easeInOut)
              .then()
              .moveX(end: 10, duration: 500.ms, curve: Curves.easeInOut),

          Padding(
            padding: const EdgeInsets.fromLTRB(100, 0, 0, 0),
            child: Column(
              //column for the buttons
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedButton(
                  context,
                  icon: Icons.play_arrow,
                  label: 'Play',
                  onTap: () async {
                    _playSound();
                    await Future.delayed(const Duration(milliseconds: 200));
                    _navigateToCreateJoinPage(context);
                  },
                  delay: 5000.ms,
                ),
                SizedBox(
                    height: responsiveSpacingHeight > 6
                        ? responsiveSpacingHeight
                        : 6),
                _buildAnimatedButton(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () async {
                    _playSound();
                    await Future.delayed(const Duration(milliseconds: 200));
                    _navigateToSettingsPage(context);
                  },
                  delay: 5500.ms,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Duration delay}) {
    return BingoOptions(
      icon: icon,
      label: label,
      onTap: () {
        onTap();
        HapticFeedback.mediumImpact();
      },
    )
        .animate()
        .then(delay: delay)
        .fadeIn(duration: 800.ms)
        .scaleXY(
            begin: 0.9,
            end: 1.0,
            duration: 500.ms,
            curve: Curves.easeOutBack) // ✅ FIXED HERE
        .then()
        .animate(onPlay: (controller) => controller.repeat(period: 8000.ms))
        .moveY(
            begin: -2,
            end: 2,
            duration: 500.ms,
            curve: Curves.easeInOut) // Floating effect
        .shakeY(duration: 500.ms); // Slight shake effect
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final responsiveTitleFontSize = screenWidth * 0.12;
    final responsiveBingoFontSize = screenWidth * 0.1;
    final responsiveSpacingHeight = screenHeight * 0.02;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0099F7),
                  Color.fromARGB(255, 9, 86, 185),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildBingoTitle(
                        responsiveTitleFontSize, responsiveBingoFontSize),
                    const SizedBox(height: 0),
                    Expanded(
                      child:
                          _buildOptionsColumn(context, responsiveSpacingHeight),
                    ),
                    if (_isBannerAdReady && _bannerAd != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: SizedBox(
                            height: 60, child: AdWidget(ad: _bannerAd!)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
