// lib/welcome_screen.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'main.dart'; // Import for color constants

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      body: Stack(
        children: [
          // Background circles (top-left)
          Positioned(
            top: -MediaQuery.of(context).size.width * 0.3,
            left: -MediaQuery.of(context).size.width * 0.3,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAppGreen.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: -MediaQuery.of(context).size.width * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryAppGreen.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                //
                // =================== FIX IS HERE ===================
                //
                mainAxisAlignment: MainAxisAlignment.center, // Center the whole column
                //
                // =================== END OF FIX ===================
                //
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- HEADER GROUP (Circle) ---
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryAppGreen.withOpacity(0.3), width: 1.5),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryAppGreen.withOpacity(0.1), width: 1.5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'CashBack',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: primaryAppDarkGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Smart savings. Brighter future.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //
                  // =================== SPACING ADDED ===================
                  //
                  const SizedBox(height: 80), // Space between circle and buttons
                  //
                  // =================== END OF SPACING ===================
                  //

                  // --- FOOTER GROUP (Buttons) ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/createAccount');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAppGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Create an Account',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/'); // Navigate to Login
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryAppGreen,
                          side: const BorderSide(color: primaryAppGreen, width: 2),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Regulated by the Bangko Sentral ng Pilipinas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Top Left Status Bar content (from your original)
          Positioned(
            top: 50, // Adjust as needed
            left: 20,
            child: Text(
              'Login / Sign Up',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}