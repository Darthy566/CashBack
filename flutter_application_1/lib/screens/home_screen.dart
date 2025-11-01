import 'package:flutter/material.dart';

// Define custom colors based on the prototype
const Color _primaryGreen = Color(0xFF4CD964); // Bright Green
const Color _darkGreen = Color(0xFF00A347);   // Darker green
const Color _lightGrey = Color(0xFFE0E0E0);  // Light grey for Secondary buttons
const Color _inputFillColor = Color(0xFFF0FFF0); // Very light green for input fields
const Color _inputBorderColor = Color(0xFFC0E0C0); // Light green border
const Color _regulatoryTextColor = Color(0xFF6C6C6C); // Darker grey for regulatory text
const Color _goalCardShadowColor = Color(0xFF1E8A38); // Darker green for goal card shadow

// --- HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background (white)
          Container(
            height: MediaQuery.of(context).size.height, // Full screen height
            color: Colors.white,
          ),
          // Adding the subtle graphic circles to the top (copied from WelcomeScreen's LogoAndCircles helper)
          Positioned(
            top: -200,
            left: -100,
            right: -100,
            child: Opacity(
              opacity: 0.5,
              child: Transform.rotate(
                angle: -0.3, // slight rotation for effect
                child: const LogoAndCircles(),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- 1. Top Logo ---
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: LogoAndSubtitle(),
                  ),

                  // --- 2. Goal Card ---
                  const GoalCard(
                    goalName: 'ASUS ROG',
                    amount: '₱51,560',
                    time: '2 months',
                  ),

                  // --- 3. Pager Dots (for multiple goals) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(true), // Active dot
                        _buildDot(false),
                        _buildDot(false),
                      ],
                    ),
                  ),

                  // --- 4. Menu Buttons ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                    child: Column(
                      children: [
                        MenuButton(
                          text: 'Profile',
                          onPressed: () => Navigator.pushNamed(context, '/profile', arguments: null),
                        ),
                        const MenuButton(text: 'Personal Finance'),
                        const MenuButton(text: 'Savings Recommendation'),
                        const MenuButton(text: 'Goal Management'),
                        const MenuButton(text: 'Investment Simulator'),
                        const SizedBox(height: 40), // Bottom padding
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        color: isActive ? _primaryGreen : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

// Widget for Logo and Subtitle only (reused from WelcomeScreen)
class LogoAndSubtitle extends StatelessWidget {
  const LogoAndSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Cash',
                style: TextStyle(
                  color: _darkGreen,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Back',
                style: TextStyle(
                  color: _primaryGreen,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4.0),
        const Text(
          'Smart savings. Brighter future.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// --- GOAL CARD WIDGET ---
class GoalCard extends StatelessWidget {
  final String goalName;
  final String amount;
  final String time;

  const GoalCard({
    required this.goalName,
    required this.amount,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            // Darker, vertical shadow mimicking the prototype's depth effect
            BoxShadow(
              color: _goalCardShadowColor.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 15,
              offset: const Offset(0, 8), // Shadow pushes down
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: _primaryGreen,
            borderRadius: BorderRadius.circular(20.0),
            // Inner shadow for the light/glow effect at the top (optional but visually accurate)
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '$goalName : $amount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Estimated Time : $time',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MENU BUTTON WIDGET ---
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const MenuButton({required this.text, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            // Subtle shadow for the action buttons
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed ?? () => debugPrint('$text tapped'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0, // Shadow is handled by the Container decoration
            minimumSize: const Size(double.infinity, 0), // Full width
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

// Reused Logo and Circles Widget (from WelcomeScreen)
class LogoAndCircles extends StatelessWidget {
  const LogoAndCircles({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.8;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        _buildCircle(size * 1.0, _primaryGreen.withOpacity(0.1), 0.0),
        _buildCircle(size * 0.9, _primaryGreen.withOpacity(0.15), 0.0),
        _buildCircle(size * 0.85, Colors.transparent, 2.0, _primaryGreen),
        _buildCircle(size * 0.78, Colors.transparent, 2.0, _darkGreen.withOpacity(0.8)),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Cash',
                    style: TextStyle(
                      color: _darkGreen,
                      fontSize: 42.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
                  ),
                  TextSpan(
                    text: 'Back',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontSize: 42.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Smart savings. Brighter future.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircle(double size, Color color, double borderWidth, [Color? borderColor]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? color,
                width: borderWidth,
              )
            : null,
      ),
    );
  }
}
