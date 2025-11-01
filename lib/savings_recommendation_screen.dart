// lib/savings_recommendation_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart' as db;
import 'app_colors.dart'; // Import main.dart for color constants

// Assuming a secondary green for gradient
const secondaryAppGreen = Color(0xFF388E3C);

class SavingsRecommendationScreen extends StatefulWidget {
  final db.User user;
  const SavingsRecommendationScreen({super.key, required this.user});

  @override
  State<SavingsRecommendationScreen> createState() => _SavingsRecommendationScreenState();
}

class _SavingsRecommendationScreenState extends State<SavingsRecommendationScreen> {
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  Map<String, double> _expensesByCategory = {};
  
  bool _isLoading = true;
  String _advice = '';
  List<Widget> _recommendations = [];

  final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
  final percentFormat = NumberFormat.percentPattern()
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 0;

  @override
  void initState() {
    super.initState();
    _fetchDataAndGenerateRecommendations();
  }

  Future<void> _fetchDataAndGenerateRecommendations() async {
    if (widget.user.id == null) {
      setState(() => _isLoading = false);
      return;
    }

    _totalIncome = await db.DatabaseHelper().getTotalAmount(widget.user.id!, 'Income');
    _totalExpense = await db.DatabaseHelper().getTotalAmount(widget.user.id!, 'Expense');
    _expensesByCategory = await db.DatabaseHelper().getExpensesByCategory(widget.user.id!);
    
    _generate503020Recommendations();

    setState(() => _isLoading = false);
  }

  void _generate503020Recommendations() {
    if (_totalIncome == 0) {
      _advice = "You don't have any income logged for this month. Please add your income in the 'Personal Finance' section to get recommendations.";
      _recommendations = [];
      return;
    }
    
    _advice = "Here is your spending breakdown based on the 50/30/20 rule (Needs/Wants/Savings).";
      
    // Define actual categories
    double actualNeeds = (_expensesByCategory['Housing'] ?? 0.0) +
                         (_expensesByCategory['Utilities'] ?? 0.0) +
                         (_expensesByCategory['Transport'] ?? 0.0) +
                         (_expensesByCategory['Groceries'] ?? 0.0);
    double actualWants = (_expensesByCategory['Food'] ?? 0.0) +
                         (_expensesByCategory['Entertainment'] ?? 0.0) +
                         (_expensesByCategory['Subscriptions'] ?? 0.0) +
                         (_expensesByCategory['Shopping'] ?? 0.0);
    double actualSavings = _totalIncome - _totalExpense;

    // Define target categories
    double targetNeeds = _totalIncome * 0.50;
    double targetWants = _totalIncome * 0.30;
    double targetSavings = _totalIncome * 0.20;

    _recommendations = [
      _buildRecommendationCard(
        title: 'Needs (50%)',
        actual: actualNeeds,
        target: targetNeeds,
      ),
      _buildRecommendationCard(
        title: 'Wants (30%)',
        actual: actualWants,
        target: targetWants,
      ),
      _buildRecommendationCard(
        title: 'Savings (20%)',
        actual: actualSavings,
        target: targetSavings,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Get the top padding (status bar height)
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        // Full-screen gradient background
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryAppGreen, secondaryAppGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title below arrow
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, topPadding + kToolbarHeight, 16.0, 16.0),
                    child: const Text(
                      'Savings Recommendations',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Content area
                  Expanded(
                    child: _recommendations.isEmpty
                        ? _buildEmptyState()
                        : _buildRecommendationsBody(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 80, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              _advice, // This shows the "No Income" message
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      children: [
        // Advice Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Changed to white
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.yellow[700], size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Your 50/30/20 Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryAppGreen, // Changed to green
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _advice,
                style: const TextStyle(fontSize: 16, color: Colors.black54), // Changed to dark text
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Recommendation Cards
        ..._recommendations,
      ],
    );
  }
  
  Widget _buildRecommendationCard({
    required String title,
    required double actual,
    required double target,
  }) {
    final double difference = actual - target;
    final bool isOver = difference > 0;
    Color diffColor = isOver ? Colors.red : primaryAppGreen;
    if (actual == 0 && target == 0) diffColor = Colors.grey;
    if (title.contains('Savings') && isOver) diffColor = primaryAppGreen; // Good to be over on savings
    if (title.contains('Savings') && !isOver) diffColor = Colors.red; // Bad to be under on savings

    // Changed from Card to Container for white UI
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('Your Spending', actual, Colors.black87),
              _buildStatColumn('Your Target', target, Colors.black87),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.contains('Savings')
                    ? (isOver ? 'Surplus' : 'Shortfall')
                    : (isOver ? 'Over Target' : 'Under Target'),
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                '${isOver ? '+' : ''}${currencyFormat.format(difference.abs())}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: diffColor),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatColumn(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(amount),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}