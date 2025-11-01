// information_screen.dart

import 'package:flutter/material.dart';

// --- Color Palette Constants ---
const Color primaryGreen = Color(0xFF4CAF50);
const Color lightGreen = Color(0xFF8BC34A);
const Color primaryAppDarkGreen = Color(0xFF2E7D32);

// --- Custom Widget for the Information Cards ---
class InfoCard extends StatelessWidget {
  final String title;
  final String body;

  const InfoCard({
    super.key, 
    required this.title, 
    required this.body
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primaryAppDarkGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5, // Improves readability
            ),
          ),
        ],
      ),
    );
  }
}


// --- Information Screen ---
class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});
  
  // Placeholder text
  final String loremIpsum = "Lorem ipsum dolor sit amet. Ea doloremque voluptates eos consectetur aspernatur non facilis rerum qui quidem omnis qui amet tempora. Et dolore voluptates est quia numquam sed ipsam sequi id animi minima aut accusantium veniam.";

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 200;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen green gradient background (top part)
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [lightGreen, primaryGreen],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // 2. Decorative Concentric Circles
          Positioned(
            top: -100,
            right: -100,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _InfoCirclePainter(), 
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === Header (Back button and Title) ===
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        const SizedBox(height: 16),
                        // Title (Using "Information" as seen at the top of the screenshot)
                        const Text(
                          'Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === 1. Terms & Conditions Card ===
                  InfoCard(
                    title: 'Terms & Conditions',
                    body: loremIpsum,
                  ),

                  // === 2. Data Privacy Card ===
                  InfoCard(
                    title: 'Data Privacy',
                    body: loremIpsum,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Circle Painter (reused design, defined locally for independence)
class _InfoCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width * 0.5, size.height * 0.5);

    canvas.drawCircle(center, size.width * 0.45, paint1);
    canvas.drawCircle(center, size.width * 0.35, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}