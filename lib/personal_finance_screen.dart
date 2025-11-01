// lib/personal_finance_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for currency formatting
import 'database_helper.dart' as db;
import 'app_colors.dart';

// --- Custom Finance Display Card ---
class FinanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String ctaText; // Call-to-action text
  final VoidCallback onTap;

  const FinanceCard({
    super.key,
    required this.title,
    required this.amount,
    required this.ctaText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        //
        // =================== FIX IS HERE ===================
        //
        color: primaryGreen, // <-- Now correctly finds the constant
        //
        // =================== END OF FIX ===================
        //
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top part with Title and Amount
          Container(
            padding: const EdgeInsets.fromLTRB(24.0, 30.0, 24.0, 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom part with "View Information" link
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              decoration: BoxDecoration(
                //
                // =================== FIX IS HERE ===================
                //
                color: primaryAppDarkGreen.withOpacity(0.6), // <-- Now correctly finds the constant
                //
                // =================== END OF FIX ===================
                //
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ctaText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Personal Finance Screen (UPDATED to StatefulWidget) ---
class PersonalFinanceScreen extends StatefulWidget {
  final db.User user;

  const PersonalFinanceScreen({super.key, required this.user});

  @override
  State<PersonalFinanceScreen> createState() => _PersonalFinanceScreenState();
}

class _PersonalFinanceScreenState extends State<PersonalFinanceScreen> {
  
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  bool _isLoading = true;

  // Currency formatter
  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch or refresh the total amounts from the database
  Future<void> _fetchData() async {
    if (widget.user.id == null) return;
    
    final income = await db.DatabaseHelper().getTotalAmount(widget.user.id!, 'Income');
    final expense = await db.DatabaseHelper().getTotalAmount(widget.user.id!, 'Expense');
    
    if (mounted) {
      setState(() {
        _totalIncome = income;
        _totalExpense = expense;
        _isLoading = false;
      });
    }
  }

  // Navigate and then refresh data when the user returns
  Future<void> _navigateToTransactionList(String type) async {
    // This should navigate to the LIST screen, not the VIEW screen.
    await Navigator.pushNamed(
      context, 
      '/transactionChoose', // <-- This is the correct route for a list
      arguments: {'user': widget.user, 'type': type}
    );
    
    // When the user returns from the view screen (where they might have added/edited),
    // refresh the totals on this screen.
    _fetchData();
  }

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
                //
                // =================== FIX IS HERE ===================
                //
                colors: [lightGreen, primaryGreen], // <-- Now correctly finds the constants
                //
                // =================== END OF FIX ===================
                //
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
              painter: _FinanceCirclePainter(),
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
                        // Title
                        const Text(
                          'Personal Finance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === 1. Total Income Card ===
                  FinanceCard(
                    title: 'Total Income',
                    amount: _isLoading ? "..." : currencyFormat.format(_totalIncome),
                    ctaText: 'View Income Information',
                    onTap: () => _navigateToTransactionList('Income'),
                  ),

                  const SizedBox(height: 24),

                  // === 2. Total Expense Card ===
                  FinanceCard(
                    title: 'Total Expense',
                    amount: _isLoading ? "..." : currencyFormat.format(_totalExpense),
                    ctaText: 'View Expense Information',
                    onTap: () => _navigateToTransactionList('Expense'),
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
class _FinanceCirclePainter extends CustomPainter {
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