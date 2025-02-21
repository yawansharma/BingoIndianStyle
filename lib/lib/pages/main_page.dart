// Refactored BingoMainPage (Non-Scrollable, Perfect Fit)

// File: lib/pages/bingo_main_page.dart

// ignore_for_file: camel_case_types, avoid_print

import 'package:bingo_indian_style/pages/create_join.dart';
import 'package:bingo_indian_style/pages/settings.dart';
import 'package:flutter/material.dart';

class BingoOptions extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BingoOptions(
      {Key? key, required this.icon, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveHorizontalPadding =
        screenWidth * 0.08; // Further reduced horizontal padding to 8%
    final responsiveIconSize =
        screenWidth * 0.035; // Further reduced icon size to 3.5%
    final responsiveFontSize = screenWidth *
        0.02; // Further reduced font size to 2% (very small screens will have small text)

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: responsiveHorizontalPadding,
            vertical: 6), // Further reduced vertical padding to 6
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: responsiveIconSize > 18
                    ? responsiveIconSize
                    : 18), // Minimum icon size 18 (even smaller)
            SizedBox(
                width: screenWidth *
                    0.008), // Further reduced SizedBox width to 0.8%
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: responsiveFontSize > 16 ? responsiveFontSize : 16,
                    fontFamily:
                        'PurplePurse'), // Minimum font size 16 (very small text on tiny screens)
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

class BingoMainPage extends StatelessWidget {
  const BingoMainPage({super.key});

  void _navigateToCreateJoinPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateJoinPage()),
    );
  }

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Settings()),
    );
  }

  void _handleHomeRulesPressed() {
    print('Home Rules Pressed');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final responsiveTitleFontSize =
        screenWidth * 0.12; // Further reduced title font scaling to 12%
    final responsiveBingoFontSize =
        screenWidth * 0.1; // Further reduced Bingo font scaling to 10%
    final responsiveSpacingHeight = screenHeight *
        0.02; // Further reduced vertical spacing to 2% of screen height (very tight spacing)

    return Scaffold(
      body: Center(
        // Keep Center to center content
        child: ConstrainedBox(
          // Keep ConstrainedBox for max width
          constraints: const BoxConstraints(
              maxWidth: 800), // Example max width, adjust if needed
          child: SizedBox(
            width: double.infinity,
            height: double
                .infinity, // Take full screen height to allow Column to size correctly
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize
                  .max, // Changed to MainAxisSize.max to take full vertical space
              children: [
                _buildBingoTitle(
                    responsiveTitleFontSize, responsiveBingoFontSize),
                SizedBox(height: 0), // Minimum spacing 15 (even tighter)
                Expanded(
                  // Use Expanded to make the options column take remaining vertical space
                  child: _buildOptionsColumn(context, responsiveSpacingHeight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Extracted Bingo Title Widget - Accepts responsive font sizes
  Widget _buildBingoTitle(
      double responsiveTitleFontSize, double responsiveBingoFontSize) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              0, 60, 0, 0), // Further reduced vertical padding in title to 8
          child: Text(
            'INDIAN STYLE',
            style: TextStyle(
              fontFamily: 'Qahiri',
              fontSize: responsiveTitleFontSize > 40
                  ? responsiveTitleFontSize
                  : 40, // Minimum title font size 40 (even smaller)
              color: const Color.fromRGBO(255, 152, 129, 1),
            ),
          ),
        ),
        Text(
          'BINGO',
          style: TextStyle(
            fontFamily: 'Rammetto',
            fontSize: responsiveBingoFontSize > 30
                ? responsiveBingoFontSize
                : 30, // Minimum bingo font size 30 (even smaller)
          ),
        ),
      ],
    );
  }

  // Extracted Options Column Widget - Accepts responsive spacing height
  Widget _buildOptionsColumn(
      BuildContext context, double responsiveSpacingHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment
          .start, // Changed to spaceEvenly to distribute space more evenly
      mainAxisSize: MainAxisSize
          .max, // Changed to MainAxisSize.max to take full vertical space
      children: [
        BingoOptions(
          icon: Icons.play_arrow,
          label: 'Play',
          onTap: () => _navigateToCreateJoinPage(context),
        ),
        SizedBox(
            height: responsiveSpacingHeight > 6
                ? responsiveSpacingHeight
                : 6), // Minimum spacing 6 (very tight spacing)
        BingoOptions(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () => _navigateToSettingsPage(context),
        ),
        SizedBox(
            height: responsiveSpacingHeight > 6 ? responsiveSpacingHeight : 6),
        BingoOptions(
          icon: Icons.menu_book_rounded,
          label: 'Home Rules',
          onTap: _handleHomeRulesPressed,
        ),
      ],
    );
  }
}
